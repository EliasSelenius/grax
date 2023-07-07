#version 330 core

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Tint;

out V2F {
    vec2 uv;
    vec4 tint;
} v2f;

uniform float aspect = 9.0 / 16.0;
uniform vec2 view_pos;

void main() {
    v2f.uv = a_Uv;
    v2f.tint = a_Tint;

    vec2 pos = a_Pos - view_pos;
    pos.x *= aspect;

    gl_Position = vec4(pos, 0.0, 1.0);
}