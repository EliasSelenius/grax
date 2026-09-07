
#include "../grax/shaders/common.glsl"
#include "../grax/shaders/app.glsl"


uniform sampler2D u_hdr_buffer;
uniform float u_exposure = 1.0;
// uniform int u_output_mode = 0;




#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void main() {
    gl_Position = screen_covering_quad(gl_VertexID);
}
#endif



#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out vec3 FragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / ViewportSize;

    int lods = textureQueryLevels(u_hdr_buffer);

    int lod = 0;
    vec2 size = textureSize(u_hdr_buffer, lod);
    vec3 hdr = texelFetch(u_hdr_buffer, ivec2(uv*size), lod).rgb;

    // vec3 hdr = texture(u_hdr_buffer, uv).rgb;
    // vec3 hdr = textureLod(u_hdr_buffer, uv, 10.0).rgb;

    // vec3 hdr = vec3(0.0);
    // for (int i = 0; i < lods; i++) {
    //     vec2 size = textureSize(u_hdr_buffer, i);
    //     hdr += texelFetch(u_hdr_buffer, ivec2(uv*size), i).rgb;
    // }
    // hdr /= lods;

    vec3 ldr = vec3(1.0) - exp(-hdr * u_exposure);

    ldr = pow(ldr, vec3(1.0 / 2.2));

    FragColor = ldr;

    // switch (u_output_mode) {
    //     case 0: { // Normal
            
    //     } break;
    // }


    // vec3 avg_color = vec3((ldr.r + ldr.g + ldr.b) / 3.0);
    // FragColor = avg_color;
    // FragColor = (ldr + avg_color * 5.0) / 6.0;
}
#endif