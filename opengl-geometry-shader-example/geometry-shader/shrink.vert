//
// shrink.vert
//
//

#version 120

attribute vec3 in_position;

uniform mat4 modelViewProjectionMatrix;
uniform vec3 color;

varying vec3 color_g;

void main() {
    gl_Position = modelViewProjectionMatrix * vec4(in_position, 1.0);
    color_g = color;
}
