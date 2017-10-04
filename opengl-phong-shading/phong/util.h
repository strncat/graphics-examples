//
// utilities
//

#ifndef UTIL_H
#define UTIL_H

#include <math.h>

struct vec3f {
    float x, y, z;

    vec3f() { x = 0.;  y = 0.; z = 0.; }
    vec3f(float _x, float _y, float _z) { x = _x; y = _y; z = _z;}

    vec3f operator*(float s) { return vec3f(x*s, y*s, y*z); }
    vec3f operator-() { return vec3f(-x, -y, -z); }
    vec3f operator-(vec3f const o) { return vec3f(x - o.x, y - o.y, z - o.z); }
    vec3f operator+(vec3f const o) { return vec3f(x + o.x, y + o.y, z + o.z); }
    float length() { return sqrtf(x*x + y*y + z*z); }
    void normalize() {
        float l = length();
        x = x/l;
        y = y/l;
        z = z/l;
    }
};

void cross(vec3f *result, vec3f* lhs, vec3f* rhs);
void multiply4x4(float *result, float *mat1, float *mat2);

#endif
