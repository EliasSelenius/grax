
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/lights.glsl"
#include "../grax/shaders/noise.glsl"
#include "../grax/shaders/app.glsl"


IO FragData {
    vec2 uv;
} v2f;


uniform vec3 dirlight_direction;
uniform vec3 dirlight_radiance;
uniform float dirlight_ambient_factor;

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;


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


#include "../grax/shaders/scq.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out vec3 FragColor;

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
    // vec3 ambient = vec3(1, 0, 0);

    // FragColor = calc_point_light(vec3(-30, 10, 0), vec3(40, 0, 0), g);
    FragColor = calc_dir_light(dirlight_direction, dirlight_radiance, g) + ambient;


    vec3 wpos = (inverse(camera.view) * vec4(view_pos, 1.0)).xyz;
    if (wpos.y < 0 && false) { // water
        float b = 0.005;
        FragColor = mix(FragColor, vec3(0.1, 0.4, 0.7), 1 - exp(-length(view_pos)*b));

        float max_depth = 200;
        float light_atten = 1.0 - clamp(-wpos.y, 0, max_depth) / max_depth;

        FragColor *= light_atten;

    } else { // atmosphere

        float sun_amount = maxdot(normalize(view_pos), normalize(mat3(camera.view) * dirlight_direction));
        vec3 fog_color = mix(vec3(0.5, 0.6, 0.7), // blue
                             vec3(1.0, 0.9, 0.7), // yellow
                             pow(sun_amount, 8.0));

        float b = 0.0005;
        FragColor = mix(FragColor, fog_color, 1 - exp(-length(view_pos)*b));


        // float b = 0.0005;
        // FragColor = mix(FragColor, vec3(0.5, 0.6, 0.7), 1 - exp(-length(view_pos)*b));
    }



    if (false) { // sky
        vec3 sky_dir = reflect(normalize(g.view_pos), view_normal);
        vec3 sky = skybox_color(mat3(inverse(camera.view)) * sky_dir);
        FragColor += max(sky, vec3(0.0));
    }
}
#endif
