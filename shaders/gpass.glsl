
#extension GL_ARB_bindless_texture : require

#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/common.glsl"


#define IO_Data FragData {\
    vec3 view_pos;\
    vec3 world_normal;\
    vec3 view_normal;\
    vec2 uv;\
    flat int instance_id;\
}\

struct InstanceData {
    mat4 model;
    vec4 uv_offset_scale;
    vec4 albedo_color;
    vec2 metallic_roughness;
    sampler2D albedo_texture;
};

// struct Material {
//     vec4 albedo_color;
//     vec2 metallic_roughness;
//     sampler2D albedo_texture;
// };

layout (std140) readonly buffer Instances {
    InstanceData instances[];
};

// std430
layout (std140) readonly buffer Textures {
    sampler2D textures[];
};


#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec2 a_Uv;

out IO_Data vert_output;

void main() {
    InstanceData data = instances[gl_InstanceID];

    mat4 model = data.model;
    mat4 view_model = camera.view * model;
    vec4 view_pos = view_model * vec4(a_Pos, 1.0);

    vec2 uv_offset = data.uv_offset_scale.xy;
    vec2 uv_scale  = data.uv_offset_scale.zw;


    vert_output.view_pos = view_pos.xyz;
    vert_output.world_normal = mat3(model) * a_Normal;
    vert_output.view_normal = mat3(view_model) * a_Normal;
    vert_output.uv = uv_offset + a_Uv * uv_scale;
    vert_output.instance_id = gl_InstanceID;

    gl_Position = camera.projection * view_pos;
}
#endif


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (location = 0) out vec4 FragPos_Metallic;
layout (location = 1) out vec4 FragNormal_Roughness;
layout (location = 2) out vec3 FragColor;

in IO_Data frag_input;

void main() {
    InstanceData data = instances[frag_input.instance_id];

    float metallic  = data.metallic_roughness.x;
    float roughness = data.metallic_roughness.y;

    sampler2D tex = sampler2D(data.albedo_texture);
    // sampler2D tex = textures[frag_input.instance_id];
    // sampler2D tex = albedo_texture;

    vec3 world_normal = normalize(frag_input.world_normal);
    vec3 normal = mat3(camera.view) * normal_from_sampler(tex, frag_input.uv, world_normal);
    // vec3 normal = frag_input.view_normal;
    if (!gl_FrontFacing)  normal = -normal;

    vec4 tex_color = texture(tex, frag_input.uv);
    if (tex_color.a == 0.0) discard;

    FragColor = tex_color.rgb * data.albedo_color.rgb;
    // FragColor = albedo_color;
    // FragColor = normal;

    FragPos_Metallic = vec4(frag_input.view_pos, metallic);
    FragNormal_Roughness = vec4(normalize(normal), roughness);
}
#endif

