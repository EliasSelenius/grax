
#ifndef LIGHTS_IMPL
#define LIGHTS_IMPL

#include "../grax/shaders/common.glsl"

struct Geometry {
    vec3 view_pos;
    vec3 view_normal;
    vec3 albedo;
    vec3 F0;
    float roughness;
    float metallic;
};

struct Material {
    vec3 albedo;
    vec3 F0;
    float roughness;
    float metallic;
};

struct LightRay {
    vec3 dir;
    vec3 radiance;
};

LightRay point_light(vec3 pos, vec3 color, Geometry g) {
    pos = (camera.view * vec4(pos, 1.0)).xyz;

    LightRay ray;
    ray.dir = normalize(pos - g.view_pos);
    float attenuation = 1.0 / sq(length(pos - g.view_pos));
    ray.radiance = color * attenuation;
    return ray;
}

LightRay dir_light(vec3 dir, vec3 color) {
    LightRay ray;
    ray.dir = normalize(mat3(camera.view) * dir);
    ray.radiance = color;
    return ray;
}

vec3 calc_base_reflectivity(vec3 albedo, float metallic) {
    return mix(vec3(0.04), albedo, metallic);
}

/*
Complete IBL with diffuse and specular contribution.
Adapted from (https://learnopengl.com/PBR/IBL/Specular-IBL)
Last chapter named "Completing the IBL reflectance"


    vec3 F = FresnelSchlickRoughness(NoV, F0, roughness);

    vec3 kD = (1.0 - F) * (1.0 - metallic);
    vec3 irradiance = texture(irradianceMap, N).rgb;
    vec3 diffuse    = irradiance * albedo * kD;

    const float MAX_REFLECTION_LOD = 4.0;
    vec3 prefilteredColor = textureLod(prefilterMap, reflect(-V, N), roughness * MAX_REFLECTION_LOD).rgb;
    vec2 envBRDF          = texture(brdfLUT, vec2(NoV, roughness)).rg;
    vec3 specular         = prefilteredColor * (F * envBRDF.x + envBRDF.y);

    vec3 ambient = (diffuse + specular) * ao;

*/

float schlick_GGX(float num, float roughness) {
    float k = sq(sq(roughness + 1.0)) / 8.0;
    return num / (num * (1.0 - k) + k);
}

/*
    I - incoming light
    N - surface normal
    R - reflected direction
*/
vec3 cook_torrance_BRDF(vec3 I, vec3 N, vec3 R, vec3 light_radiance, Material mat) {
    vec3 H = normalize(R + I);
    float NoR = maxdot(N, R);
    float NoI = maxdot(N, I);
    float NoH = maxdot(N, H);
    float HoR = maxdot(H, R);


    // Trowbridge-Reitz GGX  normal distribution function
    float r = sq(sq(mat.roughness)); // ^4 instead of just squareing, because I heard disney and epic games said so...
    float distribution = r / (Pi * sq(sq(NoH) * (r - 1.0) + 1.0));

    // geometry overshadowing
    float geometry = schlick_GGX(NoR, mat.roughness) * schlick_GGX(NoI, mat.roughness); // smith's method


    mat.F0 = calc_base_reflectivity(mat.albedo, mat.metallic);
    // fresnel schlick
    vec3 fresnel = mat.F0 + (1.0 - mat.F0) * pow(1.0 - HoR, 5.0);


    // cook torrance BRDF, specular term...
    vec3 specular = (distribution * geometry * fresnel) / max(4.0 * NoR * NoI, 0.0001);

    vec3 diffuse = (vec3(1.0) - fresnel) * (1.0 - mat.metallic);
    vec3 lambert = diffuse * mat.albedo / Pi;

    return (lambert + specular) * light_radiance * NoI;
}

vec3 cook_torrance_BRDF(LightRay light, Geometry g) {
    vec3 I = light.dir;
    vec3 N = g.view_normal;
    vec3 R = normalize(-g.view_pos);

    Material material;
    material.albedo    = g.albedo;
    material.F0        = g.F0;
    material.roughness = g.roughness;
    material.metallic  = g.metallic;

    return cook_torrance_BRDF(I, N, R, light.radiance, material);
}

vec3 calc_point_light(vec3 pos, vec3 color, Geometry g) {
    return cook_torrance_BRDF(point_light(pos, color, g), g);
}

vec3 calc_dir_light(vec3 dir, vec3 color, Geometry g) {
    return cook_torrance_BRDF(dir_light(dir, color), g);
}

#endif
