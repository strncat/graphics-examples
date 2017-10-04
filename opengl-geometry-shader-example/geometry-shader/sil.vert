//
// sil.vert
//
//

#version 120

attribute vec3 in_position;
attribute vec3 in_normal;

uniform vec3 color;
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

varying vec3 color_g;
varying vec3 eyeNormal_g;

void main() {
    gl_Position = vec4(in_position, 1.0);
    color_g = color;
    // normal vector
    eyeNormal_g = normalize(normalMatrix * in_normal);
}
