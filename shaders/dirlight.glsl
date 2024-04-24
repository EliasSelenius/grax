
IO FragData {
    vec2 uv;
} v2f;


#include "../grax/shaders/scq.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

layout(binding = 0) uniform sampler2D g_buffer_pos;
layout(binding = 1) uniform sampler2D g_buffer_normal;
layout(binding = 2) uniform sampler2D g_buffer_albedo;

out vec3 FragColor;

void main() {
    vec3 pos    = texture(g_buffer_pos,    v2f.uv).rgb;
    vec3 normal = texture(g_buffer_normal, v2f.uv).rgb;
    vec3 albedo = texture(g_buffer_albedo, v2f.uv).rgb;

    FragColor = albedo;
}

#endif