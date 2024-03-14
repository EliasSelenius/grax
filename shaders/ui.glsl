

IO FragData {
    vec2 uv;
    vec4 tint;
} v2f;

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/app.glsl"

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Tint;

void main() {
    v2f.uv = a_Uv;
    v2f.tint = a_Tint;

    vec2 pos = a_Pos;
    pos.x *= Aspect;

    gl_Position = vec4(pos, 0.0, 1.0);
}

#endif
#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

out vec4 FragColor;

uniform sampler2D tex;


void main() {
    // float c = texture(tex, v2f.uv).r;
    // float aaf = fwidth(c); // |dc/dx| + |dc/dy|
    // float alpha = smoothstep(0.5 - aaf, 0.5 + aaf, c);
    // FragColor = vec4(v2f.tint.rgb, alpha);

    FragColor = texture(tex, v2f.uv) * v2f.tint;
}

#endif