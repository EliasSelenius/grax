
IO FragData {
    vec2 uv;
} v2f;


#include "../grax/shaders/scq.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;

out vec3 FragColor;

void main() {
    vec3 pos    = texture(g_buffer_pos,    v2f.uv).rgb;
    vec3 normal = texture(g_buffer_normal, v2f.uv).rgb;
    vec3 albedo = texture(g_buffer_albedo, v2f.uv).rgb;


    Geometry g;
    g.pos = pos;
    g.normal = normal;
    g.albedo = albedo;
    g.roughness = 0.5;
    g.metallic = 0.1;

    FragColor = calc_dir_light(vec3(1, 1, 1), vec3(3, 3, 3), g);
    // FragColor = calc_point_light(vec3(-30, 10, 0), vec3(40, 0, 0), g);

}

#endif