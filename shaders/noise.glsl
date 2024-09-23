

vec3 hash(vec3 p) {
	p = vec3(dot(p,vec3(127.1,311.7, 74.7)),
			 dot(p,vec3(269.5,183.3,246.1)),
			 dot(p,vec3(113.5,271.9,124.6)));

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

    return mix(mix(mix(dot(hash(i + p000), f - p000),
                       dot(hash(i + p100), f - p100), u.x),
                   mix(dot(hash(i + p010), f - p010),
                       dot(hash(i + p110), f - p110), u.x), u.y),
               mix(mix(dot(hash(i + p001), f - p001),
                       dot(hash(i + p101), f - p101), u.x),
                   mix(dot(hash(i + p011), f - p011),
                       dot(hash(i + p111), f - p111), u.x), u.y), u.z);
}
