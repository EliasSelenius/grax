
#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/app.glsl"

uniform vec3 u_sky_color = vec3(0.1, 0.5, 0.9);
uniform vec3 u_grond_color = vec3(0.5, 0.6, 0.7);

#define Data_Block FragData {\
    vec3 pos;\
}\



#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

layout (location = 0) in vec3 a_Pos;
out Data_Block vertex_output;

void main() {
    vertex_output.pos = a_Pos;

    vec4 clip_pos = camera.projection * mat4(mat3(camera.view)) * vec4(a_Pos, 1);
    gl_Position = clip_pos.xyww;
}
#endif




#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

in Data_Block frag_input;
out vec4 FragColor;

float calc_mie_phase(vec3 sun, vec3 sky) {
    float fCos = dot(sun, -sky);
    // float g = -0.95;
    float g = -0.995;
    float g2 = g*g;
    float MiePhase = 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos*fCos) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);
    return MiePhase;
}

void main() {
    vec3 sun_dir      = camera.sun_dir.xyz;
    vec3 sun_radiance = camera.sun_radiance.xyz;

    vec3 sky_dir = normalize(frag_input.pos);

    float mie = calc_mie_phase(sun_dir, sky_dir);
    vec3 sky = u_sky_color + sun_radiance * mie;
    vec3 ground = u_grond_color;

    float e = 0.1;
    float t = smoothstep(-e, e, dot(sky_dir, vec3(0,1,0)));
    FragColor = vec4(mix(ground, sky, t), 1);
}
#endif



// FragColor.rgb = acc_color * (v3InvWavelength * fKrESun + vec3(fMiePhase * fKmESun));