#version 330 core

in V2F {
    vec2 uv;
    vec4 tint;
} v2f;

out vec4 FragColor;

uniform sampler2D tex;

void main() {
    FragColor = texture(tex, v2f.uv) * v2f.tint;
}