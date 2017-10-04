//
// shrink.frag
//
//

#version 120
#extension GL_EXT_geometry_shader4: enable

#define NUM_LIGHTS 2

varying in vec3 eyeNormal_g[3];
varying in vec3 color_g[3];
varying in vec3 eyeDirection_g[3];
varying in vec3 lightDirection_g[3][NUM_LIGHTS];

varying out vec3 eyeNormal_f;
varying out vec3 color_f;
varying out vec3 eyeDirection_f;
varying out vec3 lightDirection_f[NUM_LIGHTS];

void main() {
    for (int i = 0; i < gl_VerticesIn; i++) {
        gl_Position = gl_PositionIn[i];
        eyeNormal_f = eyeNormal_g[i];
        color_f = color_g[i];
        eyeDirection_f = eyeDirection_g[i];
        lightDirection_f[0] = lightDirection_g[i][0];
        lightDirection_f[1] = lightDirection_g[i][1];
        EmitVertex();
    }
    EndPrimitive();

    for (int i = 0; i < gl_VerticesIn; i++) {
        gl_Position = gl_PositionIn[i] + vec4(22.0, 0.0, 0.0, 0.0);
        eyeNormal_f = eyeNormal_g[i];
        color_f = color_g[i];
        eyeDirection_f = eyeDirection_g[i];
        lightDirection_f[0] = lightDirection_g[i][0];
        lightDirection_f[1] = lightDirection_g[i][1];
        EmitVertex();
    }
    EndPrimitive();

    for (int i = 0; i < gl_VerticesIn; i++) {
        gl_Position = gl_PositionIn[i] + vec4(-22.0, 0.0, 0.0, 0.0);
        eyeNormal_f = eyeNormal_g[i];
        color_f = color_g[i];
        eyeDirection_f = eyeDirection_g[i];
        lightDirection_f[0] = lightDirection_g[i][0];
        lightDirection_f[1] = lightDirection_g[i][1];
        EmitVertex();
    }
    EndPrimitive();
}
