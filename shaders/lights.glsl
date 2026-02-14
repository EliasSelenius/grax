
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

vec3 cook_torrance_BRDF(LightRay light, Geometry g) {
    vec3 N = g.view_normal;
    vec3 V = normalize(-g.view_pos);
    vec3 L = light.dir;
    vec3 H = normalize(V + L);

    float NoV = maxdot(N, V);
    float NoL = maxdot(N, L);
    float NoH = maxdot(N, H);
    float HoV = maxdot(H, V);


    // Trowbridge-Reitz GGX  normal distribution function
    float r = sq(sq(g.roughness)); // ^4 instead of just squareing, because I heard disney and epic games said so...
    float distribution = r / (Pi * sq(sq(NoH) * (r - 1.0) + 1.0));

    // geometry overshadowing
    float k = sq(sq(g.roughness + 1.0)) / 8.0;
    #define schlick_GGX(num) (num / (num * (1.0 - k) + k))
    float geometry = schlick_GGX(NoV) * schlick_GGX(NoL); // smith's method
    #undef schlick_GGX

    g.F0 = calc_base_reflectivity(g.albedo, g.metallic);
    // fresnel schlick
    vec3 fresnel = g.F0 + (1.0 - g.F0) * pow(1.0 - HoV, 5.0);


    // cook torrance BRDF, specular term...
    vec3 specular = (distribution * geometry * fresnel) / max(4.0 * NoV * NoL, 0.0001);

    vec3 diffuse = (vec3(1.0) - fresnel) * (1.0 - g.metallic);
    vec3 lambert = diffuse * g.albedo / Pi;

    return (lambert + specular) * light.radiance * NoL;
}

vec3 calc_point_light(vec3 pos, vec3 color, Geometry g) {
    return cook_torrance_BRDF(point_light(pos, color, g), g);
}

vec3 calc_dir_light(vec3 dir, vec3 color, Geometry g) {
    return cook_torrance_BRDF(dir_light(dir, color), g);
}

#endif
