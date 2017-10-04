Geometry Shader Examples in OpenGL
==============

#### Demo ####

<p align="center"><img src="https://github.com/fbroom/subdivision-algorithms/blob/master/images/ds.png" width="300"></p>

<p align="center"><img src="https://github.com/fbroom/subdivision-algorithms/blob/master/images/ds.png" width="300"></p>

#### Enabling the Shader ####

* We first need to load the geometry shader. ```In SimpleShaderProgram.h``` we add a method to load our geometry shader.

```
void LoadGeometryShader(const std::string& filename) {
    ...
    shaderG = glCreateShader(GL_GEOMETRY_SHADER_EXT);
    glShaderSource(shaderG, 1, &ptr, NULL);
    glCompileShader(shaderG);
    GLint result = 0;
    glGetShaderiv(shaderG, GL_COMPILE_STATUS, &result);
    ....
}
```

This method will be called in main.cpp: setup():

```
void setup() {
    shader = new SimpleShaderProgram();
    shader->LoadVertexShader(vertexShader);
    shader->LoadFragmentShader(fragmentShader);

    if (geometryShaderEnable) {
        shader->geometry_shader_enabled = true;
        shader->geometry_out_type = geometryShaderOutputType;
        shader->LoadGeometryShader(geometryShader);
    }
    shader->attached_and_link_shaders();
    ...
}

```

#### Shrink Shader ####


```
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

```

#### Tessellation Shader ####


* Vector of faces where each face references one of the half edges belonging to that faces

```
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

```





