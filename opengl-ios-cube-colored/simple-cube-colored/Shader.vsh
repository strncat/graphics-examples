//
//  Shader.c
//
//  Created by Fatima B on 6/16/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#version 300 es

in vec4 position;
uniform mat4 modelViewProjectionMatrix;
in vec4 sourceColor;
out vec4 destColor;

void main() {
    destColor = sourceColor;
    gl_Position = modelViewProjectionMatrix * position;
}
