
#ifndef COMMON_IMPL
#define COMMON_IMPL

#define Pi 3.14159265359
#define Half_Pi (Pi / 2.0)
#define Tau (2.0 * Pi)

#define deg2rad (Pi / 180.0)
#define rad2deg (180.0 / Pi)

float maxdot(vec3 a, vec3 b) { return max(0.0, dot(a, b)); }
float sq(float x) { return x*x; }


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


#endif
