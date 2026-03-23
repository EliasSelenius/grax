
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

void main() {
    vec3 sun_dir      = camera.sun_dir.xyz;
    vec3 sun_radiance = camera.sun_radiance.xyz;

    vec3 sky_dir = normalize(frag_input.pos);

    vec3 light = skybox_light(sun_dir, sun_radiance, sky_dir, u_sky_color);
    FragColor = vec4(light, 1.0);
}
#endif



// FragColor.rgb = acc_color * (v3InvWavelength * fKrESun + vec3(fMiePhase * fKmESun));