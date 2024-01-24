

IO FragData {
    vec3 normal;
    vec2 uv;
} v2f;

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/camera.glsl"

layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec2 a_Uv;

void main() {

    v2f.normal = a_Normal;
    v2f.uv = a_Uv;

    gl_Position = camera.projection * camera.view * vec4(a_Pos, 1.0);
}

#endif
#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D albedo_texture;

out vec4 FragColor;

void main() {

    vec4 albedo = texture(albedo_texture, v2f.uv);
    if (albedo.a < 0.1) discard;

    vec3 light_dir = normalize(vec3(1,1,1));
    float brightness = max(0.2, dot(normalize(v2f.normal), light_dir));

    FragColor = albedo * brightness;

}

#endif