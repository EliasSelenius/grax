
#ifndef CAM_IMPL
#define CAM_IMPL

layout (std140) uniform Camera {
    mat4 view;
    mat4 projection;
    vec4 sun_dir;
    vec4 sun_radiance;
} camera;


#endif