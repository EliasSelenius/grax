

#include "../grax/shaders/app.glsl"
#include "../grax/shaders/common.glsl"

#define IO_Data FragData {\
    vec2 uv;\
    vec4 tint;\
    vec3 color_v;\
    vec2 pos;\
}\

uniform vec2  u_cam_pos = vec2(0.0);
uniform float u_cam_rot = 0;
uniform float u_zoom = 1.0;
uniform sampler2D u_texture;


#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Tint;

out IO_Data vert_output;

void main() {
    vert_output.uv = a_Uv;
    vert_output.tint = a_Tint;

    int vertex_id = gl_VertexID % 4;

    vec3 colors[] = {vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 1.0)};
    vert_output.color_v = colors[vertex_id];

    float p = 1;
    float n = -p;
    vec2 vert_positions[] = {vec2(n,n), vec2(p,n), vec2(n,p), vec2(p,p)};
    vert_output.pos = vert_positions[vertex_id];

    vec3 v = vec3(a_Pos, 1);
    v *= create_mat3_inv(u_cam_pos, u_cam_rot, vec2(u_zoom));
    v.x *= Aspect;

    gl_Position = vec4(v.xy, 0.0, 1.0);
}
#endif



#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
in IO_Data frag_input;
out vec4 FragColor;

void main() {
    // float c = texture(u_texture, frag_input.uv).r;
    // float aaf = fwidth(c); // |dc/dx| + |dc/dy|
    // float alpha = smoothstep(0.5 - aaf, 0.5 + aaf, c);
    // FragColor = vec4(frag_input.tint.rgb, alpha);


    vec2 pos = frag_input.pos;

    float radius = 0.2;

    vec2 p = vec2(1.0 - radius);
    float d = length(max(abs(pos), p) - p) - radius;

    float thickness = 0.1;
    float alpha = smoothstep(0.0, thickness, -d);


    vec4 color_tex = texture(u_texture, frag_input.uv);
    vec4 tint = frag_input.tint;
    // FragColor = vec4(mix(color_tex.rgb, tint.rgb, tint.a), color_tex.a);

    vec4 color_v = vec4(frag_input.color_v, 1.0);

    FragColor = color_tex * tint * vec4(vec3(1.0), alpha);
}
#endif