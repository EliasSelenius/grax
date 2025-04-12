
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
uniform float dirlight_ambient_factor;

#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"

float oct_noise(vec3 dir) {
    float value = 0;
    for (int i = 1; i <= 8; i++) {
        float f = pow(2, i);
        value += noise(dir * f);
    }

    return value;
}

vec3 skybox_color(vec3 dir) {
    // return vec3(
    //     noise(vec3(0)    + dir * sin(Time*0.005) * 30),
    //     noise(vec3(100)  + dir * sin(Time*0.005 + 100) * 30),
    //     noise(vec3(1000) + dir * sin(Time*0.005 + 1000) * 30));

    return vec3(oct_noise(dir), 0.0, oct_noise(vec3(100) + dir * 10));

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


    // FragColor = calc_point_light(vec3(-30, 10, 0), vec3(40, 0, 0), g);
    FragColor = calc_dir_light(dirlight_direction, dirlight_radiance, g);
    FragColor += albedo * dirlight_radiance * dirlight_ambient_factor;


    if (false) { // sky
        vec3 sky_dir = reflect(normalize(g.pos), normal);
        vec3 sky = skybox_color(mat3(inverse(camera.view)) * sky_dir);
        FragColor += max(sky, vec3(0.0));
    }
}

#endif