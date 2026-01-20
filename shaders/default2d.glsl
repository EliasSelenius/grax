
#include "../grax/shaders/app.glsl"
#include "../grax/shaders/common.glsl"

#define IO_Data FragData {\
    vec3 pos;\
    vec2 uv;\
    vec4 color;\
    vec4 color_factor;\
    vec4 color_additive;\
    vec4 color_outline;\
}\

uniform vec2  u_cam_pos = vec2(0.0);
uniform float u_cam_rot = 0;
uniform float u_zoom = 1.0;
uniform sampler2D u_sampler;

struct InstanceData {
    vec4 pos_rot;
    vec4 scale_healthprcnt;
    vec4 uv_offset_scale;
    vec4 color_factor;
    vec4 color_additive;
    vec4 color_outline;
};

layout (std430) readonly buffer Instances2D {
    InstanceData instance_data[];
};

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Color;

out IO_Data vert_output;

void main() {
    InstanceData inst = instance_data[gl_InstanceID];

    vec2 uv_offset = inst.uv_offset_scale.xy;
    vec2 uv_scale  = inst.uv_offset_scale.zw;

    vert_output.uv = uv_offset + a_Uv * uv_scale;
    vert_output.color = a_Color;

    vert_output.color_factor   = inst.color_factor;
    vert_output.color_additive = inst.color_additive;
    vert_output.color_outline  = inst.color_outline;

    vec3  pos   = inst.pos_rot.xyz;
    float rot   = inst.pos_rot.w;
    vec2  scale = inst.scale_healthprcnt.xy;
    float health = inst.scale_healthprcnt.z;

    vec3 v = vec3(a_Pos, 1)
        * create_mat3(pos.xy, rot, scale)
        * create_mat3_inv(u_cam_pos, u_cam_rot, vec2(u_zoom))
        * vec3(Aspect, 1, 1);

    vert_output.pos = pos;
    gl_Position = vec4(v.xy, pos.z, 1.0 + pos.z);
}
#endif



#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

in IO_Data frag_input;
out vec4 FragColor;

void main() {
    vec4 color_factor = frag_input.color_factor;
    vec4 color_additive = frag_input.color_additive;
    vec4 color_outline = frag_input.color_outline;

    vec2 uv = frag_input.uv;

    vec4 tex_color = texture(u_sampler, uv) * frag_input.color;
    if (tex_color.a == 0.0) {
        vec2 size = 1.0 / textureSize(u_sampler, 0);

        float e = texture(u_sampler, uv + size*vec2( 1, 0)).a;
        float w = texture(u_sampler, uv + size*vec2(-1, 0)).a;
        float n = texture(u_sampler, uv + size*vec2( 0, 1)).a;
        float s = texture(u_sampler, uv + size*vec2( 0,-1)).a;

        if (e != 0.0)      tex_color = color_outline;
        else if (w != 0.0) tex_color = color_outline;
        else if (n != 0.0) tex_color = color_outline;
        else if (s != 0.0) tex_color = color_outline;

        if (tex_color.a == 0.0) discard;
    } else {
        tex_color = tex_color * color_factor + color_additive;
    }


    FragColor = tex_color;
}
#endif