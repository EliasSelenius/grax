
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"

// #define WATER

#ifdef WATER
// #include "shaders/wave.glsl"
#endif


uniform uint u_fog_enabled = 0;

uniform vec3 dirlight_direction;
uniform vec3 dirlight_radiance;
uniform float dirlight_ambient_factor;

uniform float u_fog_distance;
uniform float u_water_color_strength = 0.15;

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;


#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {
    gl_Position = screen_covering_quad(gl_VertexID);
}
#endif


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out vec3 FragColor;


vec3 apply_fog(vec3 light, vec3 view_pos, vec3 unlit_fog, vec3 lit_fog) {
    vec3 V = normalize(view_pos);
    vec3 I = normalize(mat3(camera.view) * dirlight_direction);

    float sun_amount = maxdot(V, I);
    vec3 fog_color = mix(unlit_fog, lit_fog, pow(sun_amount, 8.0));

    float view_dist = length(view_pos);
    float max_dist = 100000*u_fog_distance;
    return mix(light, fog_color, 1 - exp(-view_dist / max_dist));
}

vec3 water_transmittance(float dist) {
    vec3 extinction = vec3(0.45, 0.12, 0.05);

    vec3 optical_depth = extinction * dist * u_water_color_strength;
    vec3 transmittance = exp(-optical_depth);
    return transmittance;
}

void main() {
    vec2 uv = gl_FragCoord.xy / ViewportSize;

    vec4 pos_metallic     = texture(g_buffer_pos,    uv);
    vec4 normal_roughness = texture(g_buffer_normal, uv);
    vec3 albedo = texture(g_buffer_albedo, uv).rgb;

    vec3 view_pos = pos_metallic.xyz;
    vec3 view_normal = normal_roughness.xyz;

    Geometry g;
    g.view_pos = view_pos;
    g.view_normal = view_normal;
    g.albedo = albedo;
    g.roughness = normal_roughness.w;
    g.metallic  = pos_metallic.w;

    Material mat;
    mat.albedo    = albedo;
    mat.roughness = normal_roughness.w;
    mat.metallic  = pos_metallic.w;
    // mat.F0        = ;

    vec3 world_pos = (inverse(camera.view) * vec4(view_pos, 1.0)).xyz;
    vec3 world_normal = inverse(mat3(camera.view)) * view_normal;

    vec3 radiance = dirlight_radiance;// * max(0.0, dot(dirlight_direction, vec3(0,1,0)));

    // vec3 ambient = albedo * radiance * dirlight_ambient_factor;
    // vec3 light = ambient + calc_dir_light(dirlight_direction, radiance, g);

    vec3 I = mat3(camera.view) * dirlight_direction;
    vec3 N = view_normal; // world_normal;
    vec3 R = -normalize(view_pos);

    // vec3 light = cook_torrance_BRDF(I, N, R, radiance, mat);

    vec3 world_pos_camera_origin = (inverse(camera.view) * vec4(view_pos, 0.0)).xyz;
    vec3 ray_dir = normalize(world_pos_camera_origin);
    // camera_ray();
    Skybox sky = make_skybox(dirlight_direction);
    // vec3 atmo = atmosphere(ray_dir, sky);

    float view_dist = length(view_pos);
    float max_dist = 2000;
    // light = mix(light, atmo, clamp01(1 - exp(-view_dist / max_dist)));

    // vec3 sky_irradiance = skybox_irradiance(world_normal, sky);
    // vec3 sky_irradiance = skybox_radiance(world_normal, sky);
    // light = max(vec3(0.0), sky_irradiance) * albedo;

    vec3 sun_radiance = skybox_radiance(dirlight_direction, sky);
    vec3 light = vec3(0.0);
    light += cook_torrance_BRDF(I, N, R, sun_radiance, mat);
    light += cook_torrance_BRDF(N, N, R, skybox_radiance(world_normal, sky), mat);

    // vec3 r = reflect(-R, N);
    // light += cook_torrance_BRDF(r, N, R, skybox_radiance(inverse(mat3(camera.view)) * r, sky), mat);

    light = max(vec3(0.0), light);

    if (u_fog_enabled != 0) {
        if (world_pos.y < 0) { // water

            vec3 dir = dirlight_direction;
            float dist = ray_plane_intersects(world_pos, dir, vec3(0.0), vec3(0.0, -1.0, 0.0));
            if (dist < 0.0) dist = Infinity;
            vec3 water_plane_pos = world_pos + dir*dist;

            #ifdef WATER
            vec3 water_offset = vec3(0, 0, 0);
            vec2 coord = water_plane_pos.xz;
            float depth = 10000.0; // -world_pos.y;
            vec3 normal = vec3(0, 1, 0);
            ocean(coord, depth, Time, water_offset, normal);

            dist += dot(dir, water_offset)*2.0;
            #endif

            float max_dist = 100;
            float sun_atten = exp(-dist / max_dist);

            float view_dist = length(view_pos);
            float view_atten = exp(-view_dist / max_dist);
            vec3 color_blue = vec3(0.1, 0.4, 0.7);
            // light = mix(color_blue, light, view_atten) * sun_atten;

            vec3 color = light * water_transmittance(dist);

            light = color * water_transmittance(view_dist);

        } else { // atmosphere

            vec3 blueish    = vec3(0.3, 0.4, 0.8);
            vec3 yellowish  = vec3(1.0, 1.0, 0.3);

            // vec3 blueish    = vec3(0,0,1);
            // vec3 yellowish  = vec3(1,0,0);
            // light = apply_fog(light, view_pos, blueish, yellowish);
        }
    }


    FragColor = light;
}
#endif
