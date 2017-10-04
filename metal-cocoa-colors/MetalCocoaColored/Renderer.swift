//
//  Renderer.swift
//  MetalCocoaColored
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

    var objectToDraw: Triangle!

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
        objectToDraw = Triangle(device: device)

        super.init()

        view.delegate = self
        view.device = device
    }

    func draw(in view: MTKView) {
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        let currentDrawable = view.currentDrawable
        if (currentDrawable == nil) { return; }

        objectToDraw.render(commandQueue: commandQueue,
                            pipelineState: renderPipelineState,
                            renderPassDescriptor: renderPassDescriptor,
                            drawable: currentDrawable!)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawableSizeWillChange")
    }
}
