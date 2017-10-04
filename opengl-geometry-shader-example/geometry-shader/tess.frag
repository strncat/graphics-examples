//
// phong.frag
//
//

#version 120

#define NUM_LIGHTS 2

varying vec3 color_f;
varying vec3 eyeNormal_f;
varying vec3 eyeDirection_f;
varying vec3 lightDirection_f[NUM_LIGHTS];

uniform vec3 Ka;
uniform vec3 Kd;
uniform vec3 Ks;
float shininess = 100.0f;

void main() {
    vec3 N = normalize(eyeNormal_f);
    vec3 V = normalize(eyeDirection_f);

    vec3 ambient = Ka * color_f;
    vec3 color = ambient;

    for (int i = 0; i < NUM_LIGHTS; i++) {
        vec3 L = normalize(lightDirection_f[i]);
        vec3 H = normalize(L+V); // using the half vector instead of dot(V,R)

        float diffuseLight = max(dot(N, L), 0);
        vec3 diffuse = Kd * color_f * diffuseLight;

        float specularLight = pow(max(dot(N, H), 0.0), shininess);
        if (diffuseLight < 0) { specularLight = 0; }
        vec3 specular = Ks * color_f * specularLight;

        color += (diffuse + specular);
    }
    gl_FragColor = vec4(color, 1.0);
}
