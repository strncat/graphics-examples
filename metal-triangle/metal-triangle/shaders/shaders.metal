//
//  vertex.metal
//  metal-triangle
//
//  Created by Fatima B on 12/18/15.
//  Copyright © 2015 Fatima B. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

// vertex_main will run on each vertex
vertex Vertex vertex_main(device Vertex *vertices[[buffer(0)]],
                          uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
