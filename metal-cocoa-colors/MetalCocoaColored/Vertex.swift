//
//  Vertex.swift
//  MetalCocoaColored
//
//  Copyright © 2017 FB. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data

    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
}

