
#include "../grax/shaders/app.glsl"
#include "../grax/shaders/common.glsl"

#ifndef CAM_IMPL
#define CAM_IMPL

layout (std140) uniform Camera {
    mat4 view;
    mat4 projection;
    vec4 sun_dir;
    vec4 sun_radiance;
} camera;


vec3 camera_ray(vec2 ndc) {

    float fov = 90.0 * deg2rad;
    float near_plane = 0.1;
    mat4 view = camera.view;

    float half_near_plane_height = near_plane / tan(Half_Pi - fov / 2.0);
    float half_near_plane_width = half_near_plane_height * (Width / Height);

    vec3 p = vec3(
        ndc.x * half_near_plane_width,
        ndc.y * half_near_plane_height,
        -near_plane);

    mat3 m = transpose(mat3(view));
    vec3 ray = normalize(m * p);
    return ray;
}

#endif