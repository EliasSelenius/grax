
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

layout (location = 0) out vec3 FragPos;
layout (location = 1) out vec3 FragNormal;
layout (location = 2) out vec3 FragColor;

void main() {
    FragPos = v2f.pos;
    FragNormal = normalize(v2f.normal);
    FragColor = texture(albedo_texture, v2f.uv).rgb;
}

#endif