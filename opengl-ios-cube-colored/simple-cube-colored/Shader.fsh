//
//  Shader.c
//
//  Created by Fatima B on 6/16/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#version 300 es

in lowp vec4 destColor;
out lowp vec4 color;

void main() {
    color = destColor;
}
