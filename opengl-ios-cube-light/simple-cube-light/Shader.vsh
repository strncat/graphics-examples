//
//  Shader.c
//
//  Created by Fatima B on 6/16/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#version 300 es

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

in vec4 position;
in vec4 sourceColor;
in vec3 normal;

out vec4 destColor;

void main() {
    // diffuse lighting = dot product between the e and l
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    float dot = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    destColor = sourceColor * dot;

    // 
    gl_Position = modelViewProjectionMatrix * position;
}
