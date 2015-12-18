//
//  MetalView.m
//  metal-triangle
//
//  Created by Fatima B on 12/18/15.
//  Copyright © 2015 Fatima B. All rights reserved.
//

#import "MetalView.h"
@import Metal;
@import simd;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} Vertex;

@interface MetalView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@end

@implementation MetalView

// by overriding layerClass we change the type of layer UIView instantiates
// A CAMetalLayer object is a Core Animation layer that manages a pool of Metal
// textures for rendering its content using Metal, to render the actuall content we use nextDrawable
+ (Class)layerClass
{
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        // a device is an abstraction to the GPU, provides methods for creating command queues, render states and libraries
        [self makeDevice];
        [self makeBuffers];
        [self makePipeline];
    }
    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.superview) {
        // core animation provides CADisplayLink which is synchronized with the display loop of the device
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink
{
    [self redraw];
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (void)makeDevice
{
    _device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)makePipeline
{
    // unlike OpenGL, Metal state is built into pre-compiled objects
    // shaders are grouped in a library
    id<MTLLibrary> library = [_device newDefaultLibrary];

    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];

    // configuration options for the pipeline
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunc; // setting the vertex shader
    pipelineDescriptor.fragmentFunction = fragmentFunc; // setting the fragment shader

    NSError *error = nil;
    _pipeline = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                       error:&error];

    if (!_pipeline) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }

    _commandQueue = [_device newCommandQueue];
}

- (void)makeBuffers
{
    // defining vertex data in homogeneous coordinates
    static const Vertex vertices[] = {
        { .position = { 0.0,  0.5, 0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {-0.5, -0.5, 0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { 0.5, -0.5, 0, 1 }, .color = { 0, 0, 1, 1 } }
    };

    _vertexBuffer = [_device newBufferWithBytes:vertices
                                        length:sizeof(vertices)
                                       options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)redraw
{
    // nextDrawable retrieves a texture, then uses it as a render target in a Metal rendering pipeline.
    // After rendering each frame, you present the new content for display with
    // the presentDrawable: or presentDrawable:atTime: method of the command buffer you used for rendering.

    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;

    if (drawable) {
        // a render pass descriptor tells Metal what actions to take while the image is being rendered
        MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        passDescriptor.colorAttachments[0].texture = framebufferTexture;
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
        passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore; // clear or retained
        passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;  // store or discard

        // a collection of render commands to be executed as a unit
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

        // encode graphics rendering state and commands into a command buffer
        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        [commandEncoder setRenderPipelineState:self.pipeline];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [commandEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit]; // ready to be executed by the GPU
    }
}

@end
