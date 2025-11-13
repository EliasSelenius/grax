
#ifndef NOISE_IMPL
#define NOISE_IMPL

vec3 hash(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7,  74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}


vec2 hash(in vec2 x)   // this hash is not production ready, please
{                        // replace this by something better
    const vec2 k = vec2( 0.3183099, 0.3678794 );
    x = x*k + k.yx;
    return -1.0 + 2.0*fract( 16.0 * k*fract( x.x*x.y*(x.x+x.y)) );
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

// from Inigo Quilez: https://iquilezles.org/articles/gradientnoise/
// returns 3D gradient noise (in .w) and its derivatives (in .xyz)
vec4 noised3(in vec3 x) {
    // grid
    vec3 i = floor(x);
    vec3 f = fract(x);

    // quintic interpolant
    vec3 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec3 du = 30.0*f*f*(f*(f-2.0)+1.0);

    // gradients
    vec3 ga = hash( i+vec3(0.0,0.0,0.0) );
    vec3 gb = hash( i+vec3(1.0,0.0,0.0) );
    vec3 gc = hash( i+vec3(0.0,1.0,0.0) );
    vec3 gd = hash( i+vec3(1.0,1.0,0.0) );
    vec3 ge = hash( i+vec3(0.0,0.0,1.0) );
    vec3 gf = hash( i+vec3(1.0,0.0,1.0) );
    vec3 gg = hash( i+vec3(0.0,1.0,1.0) );
    vec3 gh = hash( i+vec3(1.0,1.0,1.0) );

    // projections
    float va = dot( ga, f-vec3(0.0,0.0,0.0) );
    float vb = dot( gb, f-vec3(1.0,0.0,0.0) );
    float vc = dot( gc, f-vec3(0.0,1.0,0.0) );
    float vd = dot( gd, f-vec3(1.0,1.0,0.0) );
    float ve = dot( ge, f-vec3(0.0,0.0,1.0) );
    float vf = dot( gf, f-vec3(1.0,0.0,1.0) );
    float vg = dot( gg, f-vec3(0.0,1.0,1.0) );
    float vh = dot( gh, f-vec3(1.0,1.0,1.0) );

    // interpolation
    float v = va +
              u.x*(vb-va) +
              u.y*(vc-va) +
              u.z*(ve-va) +
              u.x*u.y*(va-vb-vc+vd) +
              u.y*u.z*(va-vc-ve+vg) +
              u.z*u.x*(va-vb-ve+vf) +
              u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);

    vec3 d = ga +
             u.x*(gb-ga) +
             u.y*(gc-ga) +
             u.z*(ge-ga) +
             u.x*u.y*(ga-gb-gc+gd) +
             u.y*u.z*(ga-gc-ge+gg) +
             u.z*u.x*(ga-gb-ge+gf) +
             u.x*u.y*u.z*(-ga+gb+gc-gd+ge-gf-gg+gh) +

             du * (vec3(vb-va,vc-va,ve-va) +
                   u.yzx*vec3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf) +
                   u.zxy*vec3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg) +
                   u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh) );

    return vec4(d, v);
}

// returns gradient noise (in .z) and its derivatives (in .xy)
vec3 noised2( in vec2 x ) {
    vec2 i = floor( x );
    vec2 f = fract( x );

    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec2 du = 30.0*f*f*(f*(f-2.0)+1.0);

    vec2 ga = hash( i + vec2(0.0,0.0) );
    vec2 gb = hash( i + vec2(1.0,0.0) );
    vec2 gc = hash( i + vec2(0.0,1.0) );
    vec2 gd = hash( i + vec2(1.0,1.0) );

    float va = dot( ga, f - vec2(0.0,0.0) );
    float vb = dot( gb, f - vec2(1.0,0.0) );
    float vc = dot( gc, f - vec2(0.0,1.0) );
    float vd = dot( gd, f - vec2(1.0,1.0) );

    float v = va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd);
    vec2 d = ga + u.x*(gb-ga) + u.y*(gc-ga) + u.x*u.y*(ga-gb-gc+gd) +
                 du * (u.yx*(va-vb-vc+vd) + vec2(vb,vc) - va);

    return vec3(d, v);
}

// https://iquilezles.org/articles/smoothvoronoi/
float voronoi(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);

    float res = 8.0;
    for(int j=-1; j<=1; j++)
    for(int i=-1; i<=1; i++) {
        vec2 b = vec2(i, j);

        vec2  r = b - f + (hash(p + b)+1.0)/2.0;
        float d = dot(r, r);
        res = min(res, d);
    }

    return sqrt(res);
}


#endif // NOISE_IMPL