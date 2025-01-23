
IO FragData {
    vec3 pos;
    vec2 uv;
    vec4 color;
    vec4 color_factor;
    vec4 color_additive;
} v2f;

uniform vec2 cam_pos = vec2(0.0);
uniform float cam_rot = 0;
uniform float zoom = 1.0;

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/app.glsl"
#include "../grax/shaders/common.glsl"

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Color;

layout (location = 3) in vec3  a_Instance_Pos;
layout (location = 4) in float a_Instance_Rot;
layout (location = 5) in vec2  a_Instance_Scale;
layout (location = 6) in vec2  a_Instance_uv_offset;
layout (location = 7) in vec2  a_Instance_uv_scale;
layout (location = 8) in vec4  a_Instance_color_factor;
layout (location = 9) in vec4  a_Instance_color_additive;

void main() {

    v2f.uv = a_Instance_uv_offset + a_Uv * a_Instance_uv_scale;
    v2f.color = a_Color;

    v2f.color_factor = a_Instance_color_factor;
    v2f.color_additive = a_Instance_color_additive;

    vec3  pos   = a_Instance_Pos;
    float rot   = a_Instance_Rot;
    vec2  scale = a_Instance_Scale;

    vec3 v = vec3(a_Pos, 1);
    v *= create_mat3(pos.xy, rot, scale);
    v *= create_mat3_inv(cam_pos, cam_rot, vec2(zoom));
    v.x *= Aspect;

    v2f.pos = pos;
    gl_Position = vec4(v.xy, pos.z, 1.0 + pos.z);
}

#endif
#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D tex;

// TODO: color_factor and color_additive could just be computed in the vertex shader and assigned to vertex color
uniform vec4 color_factor = vec4(1.0);
uniform vec4 color_additive = vec4(0.0);

const vec3 background_color = vec3(0.1);

out vec4 FragColor;

void main() {
    vec4 tex_color = texture(tex, v2f.uv) * v2f.color;
    if (tex_color.a == 0.0) discard;

    FragColor = vec4(mix(tex_color.rgb, background_color, v2f.pos.z), tex_color.a);
    // FragColor = tex_color;

    FragColor *= v2f.color_factor;
    FragColor += v2f.color_additive;
}

#endif