//
// Assignment 3
//

#ifndef UTIL_H
#define UTIL_H

#include <math.h>
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"

// a 3D float Vector
struct Vector3f {
    float x, y, z;

    Vector3f() { x = 0.;  y = 0.; z = 0.; }
    Vector3f(float _x, float _y, float _z) { x = _x; y = _y; z = _z;}

    Vector3f operator*(float s) { return Vector3f(x*s, y*s, y*z); }
    Vector3f operator-() { return Vector3f(-x, -y, -z); }
    Vector3f operator-(Vector3f const o) { return Vector3f(x - o.x, y - o.y, z - o.z); }
    Vector3f operator+(Vector3f const o) { return Vector3f(x + o.x, y + o.y, z + o.z); }
    float length() { return sqrtf(x*x + y*y + z*z); }
    void normalize() {
        float l = length();
        x = x/l;
        y = y/l;
        z = z/l;
    }
};

void cross(Vector3f *result, Vector3f* lhs, Vector3f* rhs);

struct Point {
    unsigned int v;
    unsigned int vt;
    unsigned int vn;
    Point() { v = 0; vt = 0; vn = 0; }
    Point(unsigned int _v, unsigned int _vt, unsigned int _vn) { v = _v; vt = _vt; vn = _vn;}
};

struct Face {
    Point a, b, c;
    Face() { a = Point(); b = Point(); c = Point(); }
    Face(Point _a, Point _b, Point _c) { a = _a; b = _b; c = _c; }
};

/*
void printMatrix(float *matrix) { // debug transformation matrices
    //GLfloat matrix[16];
    //glGetFloatv (GL_MODELVIEW_MATRIX, matrix);
    //print(matrix);
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            printf("%.2f  ", matrix[(j*4)+i]);
        }
        printf("\n");
    }
    printf("\n");
}
 */

#endif
