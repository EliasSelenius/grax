
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"

// #define WATER

#ifdef WATER
// #include "shaders/wave.glsl"
#endif

IO FragData {
    vec2 uv;
} v2f;


uniform uint u_fog_enabled = 0;

uniform vec3 dirlight_direction;
uniform vec3 dirlight_radiance;
uniform float dirlight_ambient_factor;

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;


#include "../grax/shaders/scq.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out vec3 FragColor;


vec3 apply_fog(vec3 light, vec3 view_pos, vec3 unlit_fog, vec3 lit_fog) {
    vec3 V = normalize(view_pos);
    vec3 I = normalize(mat3(camera.view) * dirlight_direction);

    float sun_amount = maxdot(V, I);
    vec3 fog_color = mix(unlit_fog, lit_fog, pow(sun_amount, 8.0));

    float view_dist = length(view_pos);
    float max_dist = 2000;
    return mix(light, fog_color, 1 - exp(-view_dist / max_dist));
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


    vec3 ambient = albedo * dirlight_radiance * dirlight_ambient_factor;
    vec3 light = ambient + calc_dir_light(dirlight_direction, dirlight_radiance, g);


    if (u_fog_enabled != 0) {
        vec3 wpos = (inverse(camera.view) * vec4(view_pos, 1.0)).xyz;
        if (wpos.y < 0) { // water

            vec3 dir = dirlight_direction;
            float dist = ray_plane_intersects(wpos, dir, vec3(0.0), vec3(0.0, -1.0, 0.0));
            vec3 water_plane_pos = wpos + dir*dist;

            #ifdef WATER
            vec3 water_offset = vec3(0, 0, 0);
            vec2 coord = water_plane_pos.xz;
            float depth = 10000.0; // -wpos.y;
            vec3 normal = vec3(0, 1, 0);
            ocean(coord, depth, Time, water_offset, normal);

            dist += dot(dir, water_offset)*2.0;
            #endif

            float max_dist = 100;
            float sun_atten = exp(-dist / max_dist);

            float view_dist = length(view_pos);
            float view_atten = exp(-view_dist / max_dist);
            vec3 color_blue = vec3(0.1, 0.4, 0.7);
            light = mix(color_blue, light, view_atten) * sun_atten;

        } else { // atmosphere

            vec3 blueish    = vec3(0.5, 0.6, 0.7);
            vec3 yellowish  = vec3(1.0, 0.9, 0.7);
            light = apply_fog(light, view_pos, blueish, yellowish);
        }
    }


    FragColor = light;
}
#endif
