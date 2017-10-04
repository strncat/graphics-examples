//
//  Renderer.swift
//  MetalCocoa
//
//  Copyright © 2017 FB. All rights reserved.
//

import Cocoa
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

    weak var view: MTKView!

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    let renderPipelineDescriptor : MTLRenderPipelineDescriptor
    let renderPipelineState: MTLRenderPipelineState

    var vertexBuffer: MTLBuffer!

    // TODO: temp, should move to another class
    let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]

    init?(mtkView: MTKView) {

        // we will render into this view
        view = mtkView;

        // create a device
        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            device = defaultDevice
        } else {
            print("Metal is not supported")
            return nil
        }
        // create a command queue
        commandQueue = device.makeCommandQueue()!

        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")

        // create a render pipeline descripter
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // create a render pipeline state using the render pipeline descriptor
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }  catch {
            print("couldn't create render pipeline state")
            return nil
        }

        // prepare data
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // in bytes
        vertexBuffer = device.makeBuffer(bytes: vertexData,
                                         length: dataSize,
                                         options: []) // make new buffer on the device/GPU pass in vertex data

        super.init()

        view.delegate = self
        view.device = device
    }


    func draw(in view: MTKView) {
        // create the render pass descriptor
        let renderPassDescriptor = view.currentRenderPassDescriptor! // sets texture, loadAction, clearColor

        // create the command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()!

        // create a render command encoder using the render pass descriptor to encode the commands in the buffer
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()

        // commit the command buffer
        let drawable = view.currentDrawable!
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawableSizeWillChange")
    }
}
