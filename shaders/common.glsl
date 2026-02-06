
#ifndef COMMON_IMPL
#define COMMON_IMPL

#define Pi 3.14159265359
#define Half_Pi (Pi / 2.0)
#define Tau (2.0 * Pi)

#define deg2rad (Pi / 180.0)
#define rad2deg (180.0 / Pi)

float maxdot(vec3 a, vec3 b) { return max(0.0, dot(a, b)); }
float sq(float x) { return x*x; }


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

vec3 normal_from_sampler(sampler2D sam, vec2 uv, vec3 surface_normal) {
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

    vec2 size = textureSize(sam, 0);
    float pix = 1.0 / size.x;

    float b0 = dot(texture(sam, uv+vec2(0.0, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float b1 = dot(texture(sam, uv+vec2(pix, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float b2 = dot(texture(sam, uv+vec2(0.0, pix)).rgb, vec3(0.299, 0.587, 0.114));

    vec2 grad = vec2(b1 - b0, b2 - b0);// / (pix*100.0);
    vec3 norm = normalize(vec3(-grad.x, 1, -grad.y));

    if (surface_normal.y < 0) norm = -norm;

    vec3 cro = cross(vec3(0,1,0), surface_normal);
    vec4 q = quat_from_axis_angle(noz(cro), length(cro));
    return rotate_by_quat(q, norm);
}

#endif
