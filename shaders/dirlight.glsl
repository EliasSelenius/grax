
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"



uniform vec3  u_dirlight_direction;
uniform vec3  u_dirlight_radiance;
uniform float u_dirlight_ambient_factor;

uniform uint  u_fog_enabled = 0;
uniform float u_fog_distance;
uniform float u_water_color_strength = 0.15;

uniform Skybox u_sky = Skybox(
        vec3(0,1,0),
        22.0,
        6371e3,
        6471e3,
        vec3(5.5e-6, 13.0e-6, 22.4e-6),
        21e-6,
        8e3,
        1200.0,
        0.95);

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
    vec3 I = normalize(mat3(camera.view) * u_dirlight_direction);

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

    vec2 ndc = uv*2.0 - 1.0;
    vec3 view_ray = camera_ray(ndc);

    vec4 pos_metallic     = texture(g_buffer_pos,    uv);
    vec4 normal_roughness = texture(g_buffer_normal, uv);
    vec3 albedo = texture(g_buffer_albedo, uv).rgb;

    mat4 view  = camera.view;
    mat3 view3 = mat3(view);
    mat4 inv_view = inverse(view);

    vec3 view_pos    = pos_metallic.xyz;
    vec3 view_normal = normal_roughness.xyz;
    vec3 world_pos    = (inv_view * vec4(view_pos, 1.0)).xyz;
    vec3 world_normal = inverse(view3) * view_normal;

    float view_dist = length(view_pos);

    Material mat;
    mat.albedo    = albedo;
    mat.roughness = normal_roughness.w;
    mat.metallic  = pos_metallic.w;
    // mat.F0        = ;


    vec3 sun_dir  = u_dirlight_direction;

    vec3 world_camera_pos = (inv_view * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    vec3 I = normalize(view3 * sun_dir);
    vec3 N = view_normal; // world_normal;
    vec3 R = -normalize(view_pos);

    // Skybox sky = make_skybox(sun_dir);
    Skybox sky = u_sky;
    sky.sun_dir = sun_dir;

    bool draw_sky = view_dist == 0.0;
    if (draw_sky)  view_dist = Infinity;

    vec3 total_transmittance = vec3(0.0);
    vec3 atmos_radiance = atmosphere(view_ray, view_dist, sky, total_transmittance);


    vec3 light = vec3(0.0);
    vec3 sun_radiance = skybox_radiance(sun_dir, sky);
    light += max(vec3(0.0), cook_torrance_BRDF(I, N, R, sun_radiance, mat));
    light += max(vec3(0.0), cook_torrance_BRDF(N, N, R, skybox_radiance(world_normal, sky), mat));

    // vec3 r = reflect(-R, N);
    // light += cook_torrance_BRDF(r, N, R, skybox_radiance(inverse(view3) * r, sky), mat);

    light = max(vec3(0.0), light);

    light = light * total_transmittance + atmos_radiance;


    // if (u_fog_enabled != 0) {
    //     if (world_pos.y < 0) { // water

    //         vec3 dir = sun_dir;
    //         float dist = ray_plane_intersects(world_pos, dir, vec3(0.0), vec3(0.0, -1.0, 0.0));
    //         if (dist < 0.0) dist = Infinity;
    //         vec3 water_plane_pos = world_pos + dir*dist;


    //         dir = normalize(world_camera_pos - world_pos);
    //         float dist2 = ray_plane_intersects(world_pos, dir, vec3(0.0), vec3(0.0, 1.0, 0.0));

    //         vec3 color = light * water_transmittance(dist);

    //         light = color * water_transmittance(dist2);

    //     } else { // atmosphere

    //         vec3 blueish    = vec3(0.3, 0.4, 0.8);
    //         vec3 yellowish  = vec3(1.0, 1.0, 0.3);

    //         // vec3 blueish    = vec3(0,0,1);
    //         // vec3 yellowish  = vec3(1,0,0);
    //         // light = apply_fog(light, view_pos, blueish, yellowish);
    //     }
    // }


    FragColor = light;
}
#endif
