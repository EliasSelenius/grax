
IO FragData {
    vec3 pos;
} v2f;

#ifdef VertexShader /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/camera.glsl"

layout (location = 0) in vec3 a_Pos;

void main() {
    v2f.pos = a_Pos;

    vec4 clip_pos = camera.projection * mat4(mat3(camera.view)) * vec4(a_Pos, 1);

    // Note the xyww trick here that ensures the depth value of the rendered fragments always end up at 1.0, the maximum
    // depth value, as described in the cubemap chapter of learnOpenGL.com.
    // Do note that we need to change the depth comparison function to GL_LEQUAL:
    gl_Position = clip_pos.xyww;
}

#endif


#ifdef FragmentShader ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../grax/shaders/noise.glsl"

#include "../grax/shaders/app.glsl"

uniform samplerCube cubemap;

out vec4 FragColor;

float oct_noise(vec3 dir, int octaves) {
    float value = 0;
    for (int i = 1; i <= octaves; i++) {
        float f = pow(2, i);
        value += (noise(dir * f) + 1.0) / 2.0;
    }

    return value / octaves;
}

vec3 skybox_color(vec3 dir) {
    // return vec3(
    //     noise(vec3(0)    + dir * sin(Time*0.005) * 30),
    //     noise(vec3(100)  + dir * sin(Time*0.005 + 100) * 30),
    //     noise(vec3(1000) + dir * sin(Time*0.005 + 1000) * 30));

    // vec3 purple = vec3(1, 0.01, 1) * oct_noise(dir * oct_noise(dir) * 0.01) / 16;
    // vec3 blue   = vec3(0.1, 0.01, 1) * oct_noise(vec3(100) + dir * 10);
    // return purple;// + blue;

    float d = oct_noise(dir + vec3((oct_noise(dir*1, 10)+1.0) * 1), 2);
    if (d < 0.5) return vec3(0.0);
    return vec3(0.6, 0.01, 1) * d;

    // return (dir);
}

void main() {
    vec3 dir = normalize(v2f.pos);

    // FragColor = texture(cubemap, dir);
    FragColor = vec4(skybox_color(dir), 1);
}

#endif