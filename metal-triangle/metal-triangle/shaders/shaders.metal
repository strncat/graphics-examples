//
//  vertex.metal
//  metal-triangle
//  Source: Metal By Example - Warren Moore
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

// each metal function is prefixed with "vertex, fragment or kernal qualifier"

// vertex_main will run on each vertex
vertex Vertex vertex_main(device Vertex *vertices[[buffer(0)]],
                          uint vid [[vertex_id]]) {
    return vertices[vid]; // return a copy
}

// after the vertex shader, the rasterizer takes the values returned by the vertex
// function and interpolates them to produce a value for each possible pixel (fragment

fragment float4 fragment_main(Vertex inVertex [[stage_in]]) {
    return inVertex.color;
}
