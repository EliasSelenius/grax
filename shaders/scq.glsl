
#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

vec2 positions[] = vec2[](
    vec2(-1, -1), vec2(1, -1), vec2(-1, 1),
    vec2(1, -1), vec2(1, 1), vec2(-1, 1)
);

void main() {
    vec2 pos = positions[gl_VertexID];
    v2f.uv = (pos + vec2(1.0)) * 0.5;
    gl_Position = vec4(pos, 0.0, 1.0);
}

#endif