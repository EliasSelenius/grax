

IO FragData {
    vec2 uv;
} v2f;


#include "../grax/shaders/scq.glsl"


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D hdr_buffer;

out vec3 FragColor;

void main() {
    vec3 hdr_color = texture(hdr_buffer, v2f.uv).rgb;

    float exposure = 1.0;
    vec3 ldr_color = vec3(1.0) - exp(-hdr_color * exposure);

    FragColor = ldr_color;
}

#endif