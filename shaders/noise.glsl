
#ifndef NOISE_IMPL
#define NOISE_IMPL

vec3 hash(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7,  74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
	vec3 u = f*f*(3.0-2.0*f);

    vec3 p000 = vec3(0.0, 0.0, 0.0);
    vec3 p100 = vec3(1.0, 0.0, 0.0);
    vec3 p010 = vec3(0.0, 1.0, 0.0);
    vec3 p110 = vec3(1.0, 1.0, 0.0);
    vec3 p001 = vec3(0.0, 0.0, 1.0);
    vec3 p101 = vec3(1.0, 0.0, 1.0);
    vec3 p011 = vec3(0.0, 1.0, 1.0);
    vec3 p111 = vec3(1.0, 1.0, 1.0);

    float d000 = dot(hash(i + p000), f - p000);
    float d100 = dot(hash(i + p100), f - p100);
    float d010 = dot(hash(i + p010), f - p010);
    float d110 = dot(hash(i + p110), f - p110);
    float d001 = dot(hash(i + p001), f - p001);
    float d101 = dot(hash(i + p101), f - p101);
    float d011 = dot(hash(i + p011), f - p011);
    float d111 = dot(hash(i + p111), f - p111);

    float a = mix(d000, d100, u.x);
    float b = mix(d010, d110, u.x);
    float c = mix(d001, d101, u.x);
    float d = mix(d011, d111, u.x);

    return mix(mix(a, b, u.y), mix(c, d, u.y), u.z);
}


#endif // NOISE_IMPL