//
//  Node.swift
//  MetalCocoaColored
//
//  Copyright © 2017 FB. All rights reserved.
//

import Foundation
import MetalKit

class Node {
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer

    init(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        // 1 collect vertices in an array
        var vertexData = Array<Float>()
        for vertex in vertices {
            vertexData += vertex.floatBuffer()
        }

        // 2 make a vertex buffer to hold the array
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!

        self.name = name
        self.device = device
        vertexCount = vertices.count
    }

    func render(commandQueue: MTLCommandQueue,
                pipelineState: MTLRenderPipelineState,
                renderPassDescriptor: MTLRenderPassDescriptor,
                drawable: CAMetalDrawable) {

        let commandBuffer = commandQueue.makeCommandBuffer()!

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount/3)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

