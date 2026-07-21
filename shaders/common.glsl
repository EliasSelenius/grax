
#ifndef COMMON_IMPL
#define COMMON_IMPL

#define Pi 3.14159265359
#define Half_Pi (Pi / 2.0)
#define Tau (2.0 * Pi)

#define Infinity (1.0 / 0.0)

#define deg2rad (Pi / 180.0)
#define rad2deg (180.0 / Pi)

float maxdot(vec3 a, vec3 b) { return max(0.0, dot(a, b)); }
float sq(float x) { return x*x; }

float min_axis(vec2 v) { return min(v.x, v.y); }
float max_axis(vec2 v) { return max(v.x, v.y); }

float min_axis(vec3 v) { return min(v.x, min(v.y, v.z)); }
float max_axis(vec3 v) { return max(v.x, max(v.y, v.z)); }

int min_axis(ivec3 v) { return min(v.x, min(v.y, v.z)); }
int max_axis(ivec3 v) { return max(v.x, max(v.y, v.z)); }


vec2 rot90deg_ccw(vec2 v) {return vec2(-v.y, v.x);}
vec2 rot90deg_cw(vec2 v)  {return vec2(v.y, -v.x);}

vec3 noz(vec3 v) {
    float l = length(v);
    if (l == 0.0) return v;
    return normalize(v);
}


mat3 create_mat3(vec2 pos, float rot, vec2 scale) {
    float c = cos(rot);
    float s = sin(rot);
    return mat3(
        c * scale.x, s * scale.y, pos.x,
        -s * scale.x, c * scale.y, pos.y,
        0, 0, 1
    );
}

mat3 create_mat3_inv(vec2 pos, float rot, vec2 scale) {
    float c = cos(rot) / scale.x; // TODO: the scalings here must certanly be wrong, look at create_mat3()
    float s = sin(rot) / scale.y;
    return mat3(
        c, -s, -dot(pos, vec2(c, -s)),
        s,  c, -dot(pos, vec2(s, c)),
        0,  0, 1
    );
}

vec4 quat_from_axis_angle(vec3 axis, float angle) {
    float ha = angle / 2.0;
    return vec4(axis * sin(ha), cos(ha));
}

vec4 quat_mul(vec4 l, vec4 r) {
    float a = l.w;
    float b = l.x;
    float c = l.y;
    float d = l.z;
    float e = r.w;
    float f = r.x;
    float g = r.y;
    float h = r.z;

    return vec4(
        b*e + a*f + c*h - d*g,
        a*g - b*h + c*e + d*f,
        a*h + b*g - c*f + d*e,
        a*e - b*f - c*g - d*h
    );
}

vec3 rotate_by_quat(vec4 q, vec3 v) {
    vec4 conj = vec4(-q.xyz, q.w);
    return quat_mul(quat_mul(q, vec4(v, 0.0)), conj).xyz;
}


vec3 normal_from_sampler(sampler2D sam, vec2 uv, vec2 uv_offset, vec2 uv_scale, vec3 surface_normal) {
    /*
    // random github. luma
    return dot(color, vec3(0.299, 0.587, 0.114));

    // learnopengl.com
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    */

    // vec3 color = texture(sam, uv).rgb;
    // float b = dot(color, vec3(0.299, 0.587, 0.114));
    // float b = dot(color, vec3(0.2126, 0.7152, 0.0722));
    // vec2 grad = vec2(dFdx(b), dFdy(b));

    vec2 size = textureSize(sam, 0) * uv_scale;
    float pix = 1.0 / size.x;

    float b0 = dot(texture(sam, uv_offset + fract(uv+vec2(0.0, 0.0)) * uv_scale).rgb, vec3(0.299, 0.587, 0.114));
    float b1 = dot(texture(sam, uv_offset + fract(uv+vec2(pix, 0.0)) * uv_scale).rgb, vec3(0.299, 0.587, 0.114));
    float b2 = dot(texture(sam, uv_offset + fract(uv+vec2(0.0, pix)) * uv_scale).rgb, vec3(0.299, 0.587, 0.114));

    vec2 grad = vec2(b1 - b0, b2 - b0);// / (pix*100.0);
    vec3 norm = normalize(vec3(-grad.x, 1, -grad.y));

    if (surface_normal.y < 0) norm = -norm;

    vec3 cro = cross(vec3(0,1,0), surface_normal);
    vec4 q = quat_from_axis_angle(noz(cro), length(cro));
    return rotate_by_quat(q, norm);
}

vec3 normal_from_sampler(sampler2D sam, vec2 uv, vec3 surface_normal) {
    return normal_from_sampler(sam, uv, vec2(0.0), vec2(1.0), surface_normal);
}





// https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
float ray_plane_intersects(vec3 o, vec3 d, vec3 p, vec3 n) {
    float enumerator = dot(p - o, n);
    float denominator = dot(d, n);
    return enumerator / denominator;

    // if (denominator == 0.0)  return false; // line and plane are parallel
    // if  (enumerator == 0.0)  return false; // line is contained in plane

    // dist = enumerator / denominator;
    // if (dist < 0.0) return false; // ray points in opposite direction of plane
    // return true;
}

vec2 ray_aabb_intersects(vec3 o, vec3 r, vec3 l, vec3 h) {
    vec3 t_low  = (l - o) / r;
    vec3 t_high = (h - o) / r;
    vec3 t_close = min(t_low, t_high);
    vec3 t_far   = max(t_low, t_high);

    return vec2(max_axis(t_close), min_axis(t_far));
}

bool ray_sphere_intersects(vec3 o, vec3 d, vec3 c, float radius, inout float dist) {
    float delta = sq(dot(d, o - c)) - (sq(length(o - c)) - sq(radius));

    dist = -dot(d, o - c) - sqrt(delta);

    return delta >= 0 && dist >= 0;
}


/*
    r0: rayorigin
    rd: raydirection
    sr: sphere radius

    vec2 ts = raycast_sphere(r0, rd, sr)
    if ts.x <= ts.y then: ray hit otherwise: ray miss
*/
vec2 raycast_sphere(vec3 r0, vec3 rd, float sr) {
    float a = dot(rd, rd);
    float b = 2.0 * dot(rd, r0);
    float c = dot(r0, r0) - (sr * sr);
    float d = b*b - 4.0*a*c;

    if (d < 0.0) return vec2(1e5, -1e5); // d < 0 -> negative squareroot -> no intersection, returning

    return vec2(-b - sqrt(d), -b + sqrt(d)) / (2.0*a);
}

vec2 raycast_sphere(vec3 r0, vec3 rd, vec3 center, float sr) {
    return raycast_sphere(r0 - center, rd, sr);
}



float calc_mie_phase(vec3 sun, vec3 sky) {
    float fCos = dot(sun, -sky);
    // float g = -0.95;
    float g = -0.995;
    float g2 = g*g;
    float MiePhase = 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos*fCos) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);
    return MiePhase;
}

vec3 skybox_light(vec3 sun_dir, vec3 sun_color, vec3 sky_dir, vec3 sky_color) {
    float mie = calc_mie_phase(sun_dir, sky_dir);
    vec3 sky = sky_color + sun_color * mie;

    float e = 0.1;
    float t = smoothstep(-e, e, dot(sky_dir, vec3(0,1,0)));

    return sky*t;
}


struct Skybox {
    vec3  sun_dir;           // normalized sun direction
    float sun_intensity;     // e.g. 22.0
    float planet_radius;     // e.g. 6371e3
    float atmos_radius;      // e.g. 6471e3 (planet + ~100km)
    vec3  rlh_coff;          // e.g. vec3(5.5e-6, 13.0e-6, 22.4e-6)
    float mie_coff;          // e.g. 21e-6
    float rlh_height;        // e.g. 8e3
    float mie_height;        // e.g. 1.2e3
    float mie_g;             // asymmetry (Henyey-Greenstein), e.g. 0.758
};

Skybox make_skybox(vec3 sun_dir) {
    Skybox sky;
    sky.sun_dir         = normalize(sun_dir);
    sky.sun_intensity   = 22.0;
    sky.planet_radius   = 6371e3;
    sky.atmos_radius    = 6471e3;
    sky.rlh_coff        = vec3(5.5e-6, 13.0e-6, 22.4e-6);
    sky.mie_coff        = 21e-6;
    sky.rlh_height      = 8e3;
    sky.mie_height      = 1200.0;
    sky.mie_g           = 0.95;
    return sky;
}

vec3 atmosphere(vec3 view_dir, Skybox sky) {
    const int Primary_Ray_Stepcount   = 16;
    const int Secondary_Ray_Stepcount = 8;

    vec3 r0 = vec3(0.0, sky.planet_radius + 2.0, 0.0); // eye slightly above ground

    sky.sun_dir = normalize(sky.sun_dir);
    view_dir    = normalize(view_dir);

    vec2 dists_atmos = raycast_sphere(r0, view_dir, sky.atmos_radius);
    if (dists_atmos.x > dists_atmos.y) return vec3(100,0,0);

    float dist_planet = raycast_sphere(r0, view_dir, sky.planet_radius).x;
    float dist = min(dists_atmos.y, dist_planet);
    float i_step = (dist - dists_atmos.x) / float(Primary_Ray_Stepcount);

    vec3 rlh_total = vec3(0,0,0); // accumulators for Rayleigh and Mie scattering.
    vec3 mie_total = vec3(0,0,0);

    float i_optical_depth_rlh = 0.0; // optical depth accumulators for the primary ray.
    float i_optical_depth_mie = 0.0;

    for (int i = 0; i < Primary_Ray_Stepcount; i++) {
        vec3 pos = r0 + view_dir * (i_step*i + i_step * 0.5);

        float j_optical_depth_rlh = 0.0; // optical depth accumulators for the secondary ray.
        float j_optical_depth_mie = 0.0;

        float j_step = raycast_sphere(pos, sky.sun_dir, sky.atmos_radius).y / float(Secondary_Ray_Stepcount);
        for (int j = 0; j < Secondary_Ray_Stepcount; j++) {
            float t = j_step*j  +  j_step*0.5;
            float height = length(pos + sky.sun_dir * t) - sky.planet_radius;
            j_optical_depth_rlh += exp(-max(0.0, height / sky.rlh_height)) * j_step;
            j_optical_depth_mie += exp(-max(0.0, height / sky.mie_height)) * j_step;
        }

        // Calculate the optical depth of the Rayleigh and Mie scattering for this step.
        float height = length(pos) - sky.planet_radius;
        float rlh_od_step = exp(-max(0.0, height / sky.rlh_height)) * i_step;
        float mie_od_step = exp(-max(0.0, height / sky.mie_height)) * i_step;

        i_optical_depth_rlh += rlh_od_step;
        i_optical_depth_mie += mie_od_step;

        vec3 optical_depth  = sky.mie_coff * (i_optical_depth_mie + j_optical_depth_mie)
                            + sky.rlh_coff * (i_optical_depth_rlh + j_optical_depth_rlh);
        vec3 attn = exp(-optical_depth);

        // Accumulate scattering.
        rlh_total += rlh_od_step * attn;
        mie_total += mie_od_step * attn;
    }


    float mu = dot(view_dir, sky.sun_dir);
    float mumu = mu * mu;
    float rlh_p = 3.0 * (1.0 + mumu) / (16.0 * Pi);

    float g  = sky.mie_g;
    float gg = g * g;
    float mie_p = 3.0 / (8.0 * Pi) * (1.0 - gg) * (mumu + 1.0) / (pow(1.0 + gg - 2.0*mu*g, 1.5) * (2.0 + gg));

    vec3 rlh_final = rlh_p * sky.rlh_coff * rlh_total;
    vec3 mie_final = mie_p * sky.mie_coff * mie_total;
    return sky.sun_intensity * (rlh_final + mie_final);
}

vec3 skybox_radiance(vec3 dir, Skybox sky) {
    return atmosphere(dir, sky);
}

vec3 skybox_irradiance(vec3 normal, Skybox sky) {
    const int Samples = 32;

    normal = normalize(normal);
    vec3 irradiance = vec3(0.0);

    vec3 up    = abs(normal.z) < 0.999 ? vec3(0,0,1) : vec3(1,0,0);
    vec3 right = normalize(cross(up, normal));
         up    = cross(normal, right);

    for (int i = 0; i < Samples; i++) {
        // Simple stratified + golden ratio for better distribution
        float u1 = (float(i) + 0.5) / Samples;
        float u2 = fract(i * 0.6180339887);

        float phi = 2.0 * Pi * u2;
        float cos_theta = sqrt(1.0 - u1); // cosine weighted
        float sin_theta = sqrt(u1);

        vec3 dir = right  * sin_theta * cos(phi)
                 + up     * sin_theta * sin(phi)
                 + normal * cos_theta;

        irradiance += skybox_radiance(dir, sky) * cos_theta;
    }

    return irradiance * 2.0 * Pi / Samples;
}


struct Draw_Elements_Indirect_Command {
    uint count;           // number of indices
    uint instance_count;  // number of instances, useful to set it to zero to disable rendering
    uint first_index;     // offset into ebo
    int  base_vertex;
    uint base_instance;   // gl_InstanceID is unaffected by this. It only controls per instance attributes
};


uint z_order_index(uint x, uint y, uint z) {
    uint morton = 0;
    for (uint i = 0; i < 32; i++) {  // Enough for most practical sizes
        morton |= ((x & (1 << i)) << (2 * i)) |
                  ((y & (1 << i)) << (2 * i + 1)) |
                  ((z & (1 << i)) << (2 * i + 2));
    }
    return morton;
}

uint z_order_index(uvec3 c) {
    return z_order_index(c.x, c.y, c.z);
}

#endif
