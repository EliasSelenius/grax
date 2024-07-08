
IO FragData {
    vec2 uv;
    vec4 color;
} v2f;

uniform vec2 cam_pos = vec2(0.0);
uniform float cam_rot = 0;
uniform float zoom = 1.0;

uniform vec3 entity_pos;
uniform float entity_rot = 0;
uniform vec2 entity_scale = vec2(1, 1);

uniform vec2 uv_offset = vec2(0.0);
uniform vec2 uv_scale  = vec2(1.0);

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/app.glsl"
#include "../grax/shaders/common.glsl"

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Color;

void main() {
    v2f.uv = uv_offset + a_Uv * uv_scale;
    v2f.color = a_Color;

    vec3 v = vec3(a_Pos, 1);
    v *= create_mat3(entity_pos.xy, entity_rot, entity_scale);
    v *= create_mat3_inv(cam_pos, cam_rot, vec2(zoom));

    v.x *= Aspect;
    gl_Position = vec4(v.xy, entity_pos.z, 1.0 + entity_pos.z);
}

#endif
#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D tex;
uniform vec4 color_factor = vec4(1.0);

const vec3 background_color = vec3(0.1);

out vec4 FragColor;

void main() {


    vec4 color = texture(tex, v2f.uv) * v2f.color;
    FragColor = vec4(mix(color.rgb, background_color, entity_pos.z), color.a) * color_factor;

    gl_FragDepth = gl_FragCoord.z;
    if (color.a < 0.01) gl_FragDepth = 1.0;
}

#endif