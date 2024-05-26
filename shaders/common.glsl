
#ifndef COMMON_IMPL
#define COMMON_IMPL

#define Pi 3.14159265359
#define Tau (2.0 * Pi)

float maxdot(vec3 a, vec3 b) { return max(0.0, dot(a, b)); }
float sq(float x) { return x*x; }

#endif
