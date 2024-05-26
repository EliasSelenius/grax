

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

    ldr_color = pow(ldr_color, vec3(1.0 / 2.2));

    FragColor = ldr_color;


    // vec3 avg_color = vec3((ldr_color.r + ldr_color.g + ldr_color.b) / 3.0);
    // FragColor = avg_color;
    // FragColor = (ldr_color + avg_color * 5.0) / 6.0;
}

#endif