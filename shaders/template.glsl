

#define FragData_Block FragData {\
    vec3 pos;\
    vec3 normal;\
}\

#ifdef VertexShader // Per Vertex ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
out FragData_Block out_vertex;

void main() {
    gl_Position = vec4(0.0);
}
#endif



#ifdef TessControl // Per Patch ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (vertices = 4) out;

void main() {
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    gl_TessLevelOuter[0] = 1;
    gl_TessLevelOuter[1] = 1;
    gl_TessLevelOuter[2] = 1;
    gl_TessLevelOuter[3] = 1;

    gl_TessLevelInner[0] = 1;
    gl_TessLevelInner[1] = 1;
}
#endif


#ifdef TessEval // Per Vertex from tesselated patch ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
layout (quads, equal_spacing, ccw) in;

out FragData_Block out_vertex;

void main() {
    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;
    vec4 p2 = gl_in[2].gl_Position;
    vec4 p3 = gl_in[3].gl_Position;

    // vec2 uv = gl_TessCoord.xy;
    vec4 vert_pos = mix(mix(p0, p1, gl_TessCoord.x),
                        mix(p2, p3, gl_TessCoord.x),
                        gl_TessCoord.y);

}
#endif

#ifdef FragmentShader // Per Fragment /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
in FragData_Block input;
out vec4 FragColor;

void main() {
    FragColor = vec4(1.0);
}
#endif