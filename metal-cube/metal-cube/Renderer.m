
//
//  Renderer.m
//  metal-cube
//  Source: Metal By Example - Warren Moore
//

#import "Renderer.h"
#import "MetalView.h"
#import "MathUtils.h"

@import Metal;
@import QuartzCore.CAMetalLayer;
@import simd;

static const NSInteger InFlightBufferCount = 3;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} Vertex;

typedef struct {
    matrix_float4x4 modelViewProjectionMatrix;
} Uniforms;


@interface Renderer()
@property (nonatomic, strong) id<MTLDevice> device; // our GPU
@property (strong) id<MTLRenderPipelineState> renderPipelineState; // defines the state of the graphics rendering pipeline
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue; // queue for our command buffers
@property (nonatomic, strong) CADisplayLink *displayLink; // timer synchronized with the display

@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer; // our index buffer

@property (assign) NSInteger bufferIndex;

@property (strong) dispatch_semaphore_t displaySemaphore;

@property (assign) float rotationX, rotationY, time;
@end

@implementation Renderer

- (instancetype)init {
    if ((self = [super init])) {
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(InFlightBufferCount);
        [self makePipeline];
        [self makeBuffers];
    }
    return self;
}

- (void)makePipeline {
    // create the command queue
    self.commandQueue = [self.device newCommandQueue];

    // the library where we attach the vertex and fragment shaders
    id<MTLLibrary> library = [self.device newDefaultLibrary];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_project"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_flatcolor"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

    NSError *error = nil;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                           error:&error];
    if (!self.renderPipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
}

- (void)makeBuffers {
    static const Vertex vertices[] = {
        { .position = { -1,  1,  1, 1 }, .color = { 0, 1, 1, 1 } },
        { .position = { -1, -1,  1, 1 }, .color = { 0, 0, 1, 1 } },
        { .position = {  1, -1,  1, 1 }, .color = { 1, 0, 1, 1 } },
        { .position = {  1,  1,  1, 1 }, .color = { 1, 1, 1, 1 } },
        { .position = { -1,  1, -1, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -1, -1, -1, 1 }, .color = { 0, 0, 0, 1 } },
        { .position = {  1, -1, -1, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {  1,  1, -1, 1 }, .color = { 1, 1, 0, 1 } }
    };
    static const uint16_t indices[] = {
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    };

    _vertexBuffer = [self.device newBufferWithBytes:vertices
                                             length:sizeof(vertices)
                                            options:MTLResourceOptionCPUCacheModeDefault];
    [_vertexBuffer setLabel:@"Vertices"];

    _indexBuffer = [self.device newBufferWithBytes:indices
                                            length:sizeof(indices)
                                           options:MTLResourceOptionCPUCacheModeDefault];
    [_indexBuffer setLabel:@"Indices"];

    _uniformBuffer = [self.device newBufferWithLength:sizeof(Uniforms) * InFlightBufferCount
                                              options:MTLResourceOptionCPUCacheModeDefault];
    [_uniformBuffer setLabel:@"Uniforms"];
}

- (void)updateUniformsForView:(MetalView *)view duration:(NSTimeInterval)duration {

    // we use the duration to find the Cube's next position by figuring out the right
    // matrices to multiply with

    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    float scaleFactor = sinf(5 * self.time) * 0.25 + 1;

    const vector_float3 xAxis = {1, 0, 0};
    const vector_float3 yAxis = {0, 1, 0};

    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);

    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    // the model matrix as a result of rotation the object by the right amount based on the frame duration
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    // how far are we from the camera
    const vector_float3 cameraTranslation = {0, 0, -5};
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;

    // prespective projection
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);

    Uniforms uniforms;
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));

    const NSUInteger uniformBufferOffset = sizeof(Uniforms) * self.bufferIndex;
    memcpy([self.uniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

- (void)drawInView:(MetalView *)view {
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);

    view.clearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);

    // update the projection matrix
    [self updateUniformsForView:view duration:view.frameDuration];

    // (1) create a new command buffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    // (2) get the current pass descriptor
    MTLRenderPassDescriptor *passDescriptor = [view currentRenderPassDescriptor];

    // (3) create the command encoder using the current pass descriptor
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];

    // (a) use our pipeline state created earlier
    [commandEncoder setRenderPipelineState:self.renderPipelineState];

    // (b) set the fixed-function render options (depth state, culling, fillmode, can also set viewport)
    [commandEncoder setDepthStencilState:self.depthStencilState];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [commandEncoder setCullMode:MTLCullModeBack];

    // (c) specify the locations of the vertex buffer and the uniforms
    const NSUInteger uniformBufferOffset = sizeof(Uniforms) * self.bufferIndex;
    [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [commandEncoder setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];

    // draw graphics with the command encoder
    [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[self.indexBuffer length] / sizeof(uint16_t)
                            indexType:MTLIndexTypeUInt16
                          indexBuffer:self.indexBuffer
                    indexBufferOffset:0];
    [commandEncoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];

    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % InFlightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];

    [commandBuffer commit];
}
@end
