//
//  Shader.c
//
//  Created by Fatima B on 6/16/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#version 300 es

in vec4 position;
uniform mat4 modelViewProjectionMatrix;
out mediump vec2 outTexCoordinates;
in mediump vec2 texCoordinates;

void main() {
    gl_Position = modelViewProjectionMatrix * position;
    outTexCoordinates = texCoordinates;
}
