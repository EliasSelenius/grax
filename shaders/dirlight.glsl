
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

uniform vec3 dirlight_direction;
uniform vec3 dirlight_radiance;

#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"
vec3 skybox_color(vec3 dir) {
    return vec3(noise(dir), 0.0, noise(vec3(100) + dir * 10));
    // return (dir);
}

void main() {
    vec4 pos_metallic     = texture(g_buffer_pos,    v2f.uv);
    vec4 normal_roughness = texture(g_buffer_normal, v2f.uv);
    vec3 albedo = texture(g_buffer_albedo, v2f.uv).rgb;

    vec3 pos = pos_metallic.xyz;
    vec3 normal = normal_roughness.xyz;


    Geometry g;
    g.pos = pos;
    g.normal = normal;
    g.albedo = albedo;
    g.roughness = normal_roughness.w;
    g.metallic  = pos_metallic.w;


    FragColor = calc_dir_light(dirlight_direction, dirlight_radiance, g);
    // FragColor = calc_point_light(vec3(-30, 10, 0), vec3(40, 0, 0), g);


    if (false) { // sky
        vec3 sky_dir = reflect(normalize(g.pos), normal);
        vec3 sky = skybox_color(mat3(inverse(camera.view)) * sky_dir);
        FragColor += max(sky, vec3(0.0));
    }
}

#endif