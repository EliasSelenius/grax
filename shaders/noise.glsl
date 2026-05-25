
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




const int sdnoise_perm_table[512] = int[512](
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
);


vec3 grad3(int hash) {
    /*
        Gradient directions for 3D.
        These vectors are based on the midpoints of the 12 edges of a cube.
        A larger array of random unit length vectors would also do the job,
        but these 12 (including 4 repeats to make the array length a power
        of two) work better. They are not random, they are carefully chosen
        to represent a small, isotropic set of directions.
    */

    vec3 grad3lut[16] = vec3[16](
        vec3( 1.0,  0.0,  1.0), vec3( 0.0,  1.0,  1.0), // 12 cube edges
        vec3(-1.0,  0.0,  1.0), vec3( 0.0, -1.0,  1.0),
        vec3( 1.0,  0.0, -1.0), vec3( 0.0,  1.0, -1.0),
        vec3(-1.0,  0.0, -1.0), vec3( 0.0, -1.0, -1.0),
        vec3( 1.0, -1.0,  0.0), vec3( 1.0,  1.0,  0.0),
        vec3(-1.0,  1.0,  0.0), vec3(-1.0, -1.0,  0.0),
        vec3( 1.0,  0.0,  1.0), vec3(-1.0,  0.0,  1.0), // 4 repeats to make 16
        vec3( 0.0,  1.0, -1.0), vec3( 0.0, -1.0, -1.0)
    );

    return grad3lut[hash & 15];
}

float sdnoise(vec3 v, out vec3 gradient) {
    const float F3 = 0.333333333; // F3 = 1/3
    const float G3 = 0.166666667; // G3 = 1/6

    // Skew the input space to determine which simplex cell we're in
    float s = (v.x + v.y + v.z) * F3; // Very nice and simple skew factor for 3D
    vec3 ijk = floor(v + vec3(s));

    float t = (ijk.x + ijk.y + ijk.z) * G3;
    vec3 p0 = v - ijk + vec3(t); // The x,y,z distances from the cell origin

    /* For the 3D case, the simplex shape is a slightly irregular tetrahedron.
     * Determine which simplex we are in. */
    int i1, j1, k1; /* Offsets for second corner of simplex in (i,j,k) coords */
    int i2, j2, k2; /* Offsets for third corner of simplex in (i,j,k) coords */

    /* TODO: This code would benefit from a backport from the GLSL version! */
    if (p0.x>=p0.y) {
             if (p0.y >= p0.z) { i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; } /* X Y Z order */
        else if (p0.x >= p0.z) { i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; } /* X Z Y order */
        else                   { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; } /* Z X Y order */
    } else { // p0.x < p0.y
             if (p0.y < p0.z)  { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; } /* Z Y X order */
        else if (p0.x < p0.z)  { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; } /* Y Z X order */
        else                   { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; } /* Y X Z order */
    }

    /* A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
     * a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
     * a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
     * c = 1/6.   */

    vec3 p1 = p0 - vec3(i1,j1,k1) + vec3(G3);     // Offsets for second corner in (x,y,z) coords
    vec3 p2 = p0 - vec3(i2,j2,k2) + vec3(G3*2.0); // Offsets for third corner in (x,y,z) coords
    vec3 p3 = p0 - vec3(1.0)      + vec3(G3*3.0); // Offsets for last corner in (x,y,z) coords

    /* Wrap the integer indices at 256, to avoid indexing perm[] out of bounds */
    int ii = int(ijk.x) & 0xff;
    int jj = int(ijk.y) & 0xff;
    int kk = int(ijk.z) & 0xff;

    // Calculate the contribution from the four corners
    float t0 = max(0.5 - dot(p0,p0), 0.0);
    float t1 = max(0.5 - dot(p1,p1), 0.0);
    float t2 = max(0.5 - dot(p2,p2), 0.0);
    float t3 = max(0.5 - dot(p3,p3), 0.0);

    float t20=t0*t0, t40=t20*t20;
    float t21=t1*t1, t41=t21*t21;
    float t22=t2*t2, t42=t22*t22;
    float t23=t3*t3, t43=t23*t23;

    // Gradients at simplex corners
    vec3 g0 = grad3(sdnoise_perm_table[ii      + sdnoise_perm_table[jj      + sdnoise_perm_table[kk]]]);
    vec3 g1 = grad3(sdnoise_perm_table[ii + i1 + sdnoise_perm_table[jj + j1 + sdnoise_perm_table[kk + k1]]]);
    vec3 g2 = grad3(sdnoise_perm_table[ii + i2 + sdnoise_perm_table[jj + j2 + sdnoise_perm_table[kk + k2]]]);
    vec3 g3 = grad3(sdnoise_perm_table[ii + 1  + sdnoise_perm_table[jj + 1  + sdnoise_perm_table[kk + 1]]]);

    { // gradient
        float temp0 = t20 * t0 * dot(g0, p0);
        float temp1 = t21 * t1 * dot(g1, p1);
        float temp2 = t22 * t2 * dot(g2, p2);
        float temp3 = t23 * t3 * dot(g3, p3);

        vec3 ps = (temp0*p0 + temp1*p1 + temp2*p2 + temp3*p3) * -8.0;
        vec3 gs = t40*g0 + t41*g1 + t42*g2 + t43*g3;

        gradient = (ps + gs) * 72.0; // Scale derivative to match the noise scaling
    }

    // Noise contributions from the four simplex corners
    float n0 = t40 * dot(g0, p0);
    float n1 = t41 * dot(g1, p1);
    float n2 = t42 * dot(g2, p2);
    float n3 = t43 * dot(g3, p3);

    // Add contributions from each corner to get the final noise value.
    // The result is scaled to return values in the range [-1,1]
    return 72.0 * (n0 + n1 + n2 + n3);
}



#endif // NOISE_IMPL