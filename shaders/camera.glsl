
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

// LightRay get_sun_lightray() {
    
// }

vec3 camera_ray(vec2 ndc) {

    // TODO: ...
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


float get_fragdepth_from_view_space_point(vec3 view_point) {
    vec4 clip_pos = camera.projection * vec4(view_point, 1.0);
    vec3 clip = clip_pos.xyz / clip_pos.w;
    return (clip.z + 1.0) * 0.5;
}

float get_fragdepth_from_world_space_point(vec3 world_point) {
    vec3 view_point = (camera.view * vec4(world_point, 1.0)).xyz;
    return get_fragdepth_from_view_space_point(view_point);
}


#endif