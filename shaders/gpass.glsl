
#extension GL_ARB_bindless_texture : require

#include "../grax/shaders/camera.glsl"
#include "../grax/shaders/common.glsl"


#define IO_Data FragData {\
    vec3 pos;\
    vec3 world_normal;\
    vec3 view_normal;\
    vec2 uv;\
    flat int instance_id;\
}\

layout (std140) uniform Instances {
    mat4 transform[16];
} instances;

layout (std430) readonly buffer Textures {
    sampler2D textures[];
};

uniform sampler2D albedo_texture;
uniform vec3  albedo_color;
uniform float metallic;
uniform float roughness;



#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (location = 0) in vec3 a_Pos;
layout (location = 1) in vec3 a_Normal;
layout (location = 2) in vec2 a_Uv;

out IO_Data vert_output;

void main() {
    mat4 model = instances.transform[gl_InstanceID];
    mat4 view_model = camera.view * model;
    vec4 pos = view_model * vec4(a_Pos, 1.0);

    vert_output.pos = pos.xyz;
    vert_output.world_normal = mat3(model) * a_Normal;
    vert_output.view_normal = mat3(view_model) * a_Normal;
    vert_output.uv = a_Uv;
    vert_output.instance_id = gl_InstanceID;

    gl_Position = camera.projection * pos;
}
#endif


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

vec4 quat_from_axis_angle(vec3 axis, float angle) {
    float ha = angle / 2.0;
    return vec4(axis * sin(ha), cos(ha));
}

vec4 quat_mul(vec4 l, vec4 r) {
    float a = l.w;
    float b = l.x;
    float c = l.y;
    float d = l.z;
    float e = r.w;
    float f = r.x;
    float g = r.y;
    float h = r.z;

    return vec4(
        b*e + a*f + c*h - d*g,
        a*g - b*h + c*e + d*f,
        a*h + b*g - c*f + d*e,
        a*e - b*f - c*g - d*h
    );
}

vec3 rotate_by_quat(vec4 q, vec3 v) {
    vec4 conj = vec4(-q.xyz, q.w);
    return quat_mul(quat_mul(q, vec4(v, 0.0)), conj).xyz;
}

vec3 normal_from_sampler(sampler2D sam, vec2 uv, vec3 surface_normal) {
    /*
    // random github. luma
    return dot(color, vec3(0.299, 0.587, 0.114));

    // learnopengl.com
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    */

    // vec3 color = texture(sam, uv).rgb;
    // float b = dot(color, vec3(0.299, 0.587, 0.114));
    // float b = dot(color, vec3(0.2126, 0.7152, 0.0722));
    // vec2 grad = vec2(dFdx(b), dFdy(b));

    vec2 size = textureSize(sam, 0);
    float run = 1.0 / size.x;

    float b0 = dot(texture(sam, uv+vec2(0.0, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float b1 = dot(texture(sam, uv+vec2(run, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float b2 = dot(texture(sam, uv+vec2(0.0, run)).rgb, vec3(0.299, 0.587, 0.114));

    vec2 grad = vec2(b1 - b0, b2 - b0) / (run*100.0);

    vec3 norm = normalize(vec3(-grad.x, 1, -grad.y));

    vec3 cro = cross(vec3(0,1,0), surface_normal);
    vec4 q = quat_from_axis_angle(noz(cro), length(cro));
    return rotate_by_quat(q, norm);

    // return norm;
}

layout (location = 0) out vec4 FragPos_Metallic;
layout (location = 1) out vec4 FragNormal_Roughness;
layout (location = 2) out vec3 FragColor;

in IO_Data frag_input;

void main() {

    // sampler2D tex = textures[frag_input.instance_id];
    sampler2D tex = albedo_texture;

    vec3 norm = mat3(camera.view) * normal_from_sampler(tex, frag_input.uv, frag_input.world_normal);
    FragColor = norm;

    FragPos_Metallic.xyz = frag_input.pos;
    FragPos_Metallic.w   = metallic;

    vec3 normal = norm;
    // vec3 normal = frag_input.view_normal;
    if (!gl_FrontFacing)  normal = -normal;
    FragNormal_Roughness.xyz = normalize(normal);
    FragNormal_Roughness.w   = roughness;

    FragColor = texture(tex, frag_input.uv).rgb * albedo_color;
    // FragColor = albedo_color;
}
#endif