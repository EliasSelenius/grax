
IO FragData {
    vec3 pos;
    vec3 normal;
    vec2 uv;
} v2f;


#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "../grax/shaders/camera.glsl"

layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec2 a_Uv;

layout (std140) uniform Instances {
    mat4 transform[16];
} instances;

void main() {
    mat4 model = instances.transform[gl_InstanceID];
    mat4 view_model = camera.view * model;
    vec4 pos = view_model * vec4(a_Pos, 1.0);

    v2f.pos = pos.xyz;
    v2f.normal = mat3(view_model) * a_Normal;
    v2f.uv = a_Uv;

    gl_Position = camera.projection * pos;
}

#endif



#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D albedo_texture;
uniform vec3  albedo_color;
uniform float metallic;
uniform float roughness;

layout (location = 0) out vec4 FragPos_Metallic;
layout (location = 1) out vec4 FragNormal_Roughness;
layout (location = 2) out vec3 FragColor;

void main() {
    FragPos_Metallic.xyz = v2f.pos;
    FragPos_Metallic.w   = metallic;

    FragNormal_Roughness.xyz = normalize(v2f.normal);
    FragNormal_Roughness.w   = roughness;

    FragColor = texture(albedo_texture, v2f.uv).rgb * albedo_color;
}

#endif