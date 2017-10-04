//
//  Shader.c
//
//  Created by Fatima B on 6/16/15.
//  Copyright (c) 2015 nemo. All rights reserved.
//

#version 300 es

uniform sampler2D TextureSampler; /* new */
out mediump vec4 color;
in mediump vec2 outTexCoordinates;

void main() {
    color = texture(TextureSampler, outTexCoordinates);
}
