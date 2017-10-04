//
//  util.cpp
//  Reference: Assignment 3

#include "util.h"

void cross(vec3f *result, vec3f* lhs, vec3f* rhs) {
    result->x = lhs->y * rhs->z - lhs->z * rhs->y;
    result->y = lhs->z * rhs->x - lhs->x * rhs->z;
    result->z = lhs->x * rhs->y - lhs->y * rhs->x;
}

void multiply4x4(float *result, float *mat1, float *mat2) {
    // each matrix is an array of 16 elements
    // [ 0  4  8  12 ]   [ 0  4  8  12 ]   [ 0  4  8   12 ]
    // [ 1  5  9  13 ] * [ 1  5  9  13 ] = [ 1  5  9   13 ]
    // [ 2  6  10 14 ]   [ 2  6  10 14 ]   [ 2  6  10  14 ]
    // [ 3  7  11 15 ]   [ 3  7  11 15 ]   [ 3  7  11  15 ]

    // result[0] = mat1[0]*mat2[0] + mat1[4]*mat2[1] + mat1[8]*mat2[2] + mat1[12]*mat2[3]

    result[0] = mat1[0]*mat2[0] + mat1[4]*mat2[1] + mat1[8]*mat2[2] + mat1[12]*mat2[3];

    result[1] = mat1[1]*mat2[0] + mat1[5]*mat2[1] + mat1[9]*mat2[2] + mat1[13]*mat2[3];
    result[2] = mat1[2]*mat2[0] + mat1[6]*mat2[1] + mat1[10]*mat2[2] + mat1[14]*mat2[3];
    result[3] = mat1[3]*mat2[0] + mat1[7]*mat2[1] + mat1[11]*mat2[2] + mat1[15]*mat2[3];

    result[4] = mat1[0]*mat2[4] + mat1[4]*mat2[5] + mat1[8]*mat2[6] + mat1[12]*mat2[7];
    result[5] = mat1[1]*mat2[4] + mat1[5]*mat2[5] + mat1[9]*mat2[6] + mat1[13]*mat2[7];
    result[6] = mat1[2]*mat2[4] + mat1[6]*mat2[5] + mat1[10]*mat2[6] + mat1[14]*mat2[7];
    result[7] = mat1[3]*mat2[4] + mat1[7]*mat2[5] + mat1[11]*mat2[6] + mat1[15]*mat2[7];

    result[8] = mat1[0]*mat2[8] + mat1[4]*mat2[9] + mat1[8]*mat2[10] + mat1[12]*mat2[11];
    result[9] = mat1[1]*mat2[8] + mat1[5]*mat2[9] + mat1[9]*mat2[10] + mat1[13]*mat2[11];
    result[10] = mat1[2]*mat2[8] + mat1[6]*mat2[9] + mat1[10]*mat2[10] + mat1[14]*mat2[11];
    result[11] = mat1[3]*mat2[8] + mat1[7]*mat2[9] + mat1[11]*mat2[10] + mat1[15]*mat2[11];

    result[12] = mat1[0]*mat2[12] + mat1[4]*mat2[13] + mat1[8]*mat2[14] + mat1[12]*mat2[15];
    result[13] = mat1[1]*mat2[12] + mat1[5]*mat2[13] + mat1[9]*mat2[14] + mat1[13]*mat2[15];
    result[14] = mat1[2]*mat2[12] + mat1[6]*mat2[13] + mat1[10]*mat2[14] + mat1[14]*mat2[15];
    result[15] = mat1[3]*mat2[12] + mat1[7]*mat2[13] + mat1[11]*mat2[14] + mat1[15]*mat2[15];
}
