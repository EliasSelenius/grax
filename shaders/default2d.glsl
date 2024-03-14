
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

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/app.glsl"

mat3 createMatrix(vec2 pos, float rot, vec2 scale) {
    float c = cos(rot);
    float s = sin(rot);
    return mat3(
        c * scale.x, s * scale.y, pos.x,
        -s * scale.x, c * scale.y, pos.y,
        0, 0, 1
    );
}

mat3 createMatrixInv(vec2 pos, float rot, vec2 scale) {
    float c = cos(rot) / scale.x; // TODO: the scalings here must certanly be wrong, look at createMatrix()
    float s = sin(rot) / scale.y;
    return mat3(
        c, -s, -dot(pos, vec2(c, -s)),
        s,  c, -dot(pos, vec2(s, c)),
        0,  0, 1
    );
}

layout (location = 0) in vec2 a_Pos;
layout (location = 1) in vec2 a_Uv;
layout (location = 2) in vec4 a_Color;

void main() {
    v2f.uv = a_Uv;
    v2f.color = a_Color;

    vec3 v = vec3(a_Pos, 1);
    v *= createMatrix(entity_pos.xy, entity_rot, entity_scale);
    v *= createMatrixInv(cam_pos, cam_rot, vec2(zoom));

    v.x *= Aspect;
    gl_Position = vec4(v.xy, entity_pos.z, 1.0 + entity_pos.z);
}

#endif
#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform sampler2D tex;
uniform vec4 color_factor;

const vec3 background_color = vec3(0.1);

out vec4 FragColor;

void main() {


    vec4 color = texture(tex, v2f.uv) * v2f.color;
    FragColor = vec4(mix(color.rgb, background_color, entity_pos.z), color.a) * color_factor;

    gl_FragDepth = gl_FragCoord.z;
    if (color.a < 0.01) gl_FragDepth = 1.0;
}

#endif