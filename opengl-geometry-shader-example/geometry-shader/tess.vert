//
// phong.vert
//
//

#version 120

#define NUM_LIGHTS 2

attribute vec3 in_position;
attribute vec3 in_normal;

uniform mat3 normalMatrix;
uniform mat4 modelViewProjectionMatrix;

uniform vec3 eyePosition;
uniform vec3 lightPosition[NUM_LIGHTS];
uniform vec3 color;

varying vec3 color_g;
varying vec3 eyeNormal_g;
varying vec3 eyeDirection_g;
varying vec3 lightDirection_g[NUM_LIGHTS];

void main() {
    gl_Position = modelViewProjectionMatrix * vec4(in_position, 1.0);
    eyeNormal_g = normalize(normalMatrix * in_normal);
    color_g = color;
    eyeDirection_g = normalize(eyePosition - in_position);
    for (int i = 0; i < NUM_LIGHTS; i++) {
        lightDirection_g[i] = normalize(lightPosition[i] - in_position);
    }
}
