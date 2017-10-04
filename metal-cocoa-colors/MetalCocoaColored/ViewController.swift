//
//  ViewController.swift
//  MetalCocoaColored
//
//  Copyright © 2017 FB. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var renderer : Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()

        let metalView = self.view as! MTKView
        renderer = Renderer(mtkView: metalView)
    }
}
