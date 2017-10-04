//
// sil.frag
//
//

#version 120

varying vec3 color_f;

void main() {
    gl_FragColor = vec4(color_f, 1.0);
}
