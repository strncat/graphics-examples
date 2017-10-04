//
// shrink.frag
//
//

#version 120
#extension GL_EXT_geometry_shader4: enable

varying in vec3 color_g[3];
varying out vec3 color_f;

void main() {
    vec4 V[3];
    vec4 CG;
    float uShrink = 0.6;

    V[0] = gl_PositionIn[0];
    V[1] = gl_PositionIn[1];
    V[2] = gl_PositionIn[2];
    CG = (V[0] + V[1] + V[2])/3;

    gl_Position = CG + uShrink * (V[0] - CG);
    color_f = color_g[0];
    EmitVertex();

    gl_Position = CG + uShrink * (V[1] - CG);
    color_f = color_g[1];
    EmitVertex();

    gl_Position = CG + uShrink * (V[2] - CG);
    color_f = color_g[2];
    EmitVertex();

    EndPrimitive();
}
