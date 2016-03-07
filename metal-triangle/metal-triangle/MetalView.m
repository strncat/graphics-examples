//
//  MetalView.m
//  metal-triangle
//  Source: Metal By Example -- Warren Moore
//  Also https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221-CH1-SW1
//

/* "Previous generations of graphics libraries have led us to think of graphics hardware as a state machine:
 you set some state (like where to pull data from, and whether draw calls should write to the depth buffer), 
 and that state affects the draw calls you issue afterward.
 Metal provides a somewhat different model. Rather than calling API that acts on some global “context” object, 
 much of Metal’s state is built into pre-compiled objects comprising a virtual pipeline that takes vertex data 
 from one end and produces a rasterized image on the other end.
 Why does this matter? By requiring expensive state changes to be frozen in precompiled render state, Metal can 
 perform validation up-front that would otherwise have to be done every draw call." */

#import "MetalView.h"
@import Metal;
@import simd;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} Vertex;

@interface MetalView ()
@property (nonatomic, strong) CADisplayLink *displayLink;

// The MTLDevice protocol defines the interface to a single graphics processor (GPU)
// You use an object that conforms to this protocol to query the capabilities of
// the processor and to allocate objects used to access those capabilities
@property (nonatomic, strong) id<MTLDevice> device;

@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;

// The MTLCommandQueue protocol defines the interface for an object that can queue
// an ordered list of command buffers for a Metal device to execute
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

// an allocation of unformatted, device-accessible memory that can contain any type of data
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@end

@implementation MetalView

// by overriding layerClass we change the type of layer UIView instantiates
// A CAMetalLayer object is a Core Animation layer. It maintains an internal
// pool of textures for displaying layer content, each wrapped in a
// CAMetalDrawable object. Use nextDrawable to retrieve the next available texture
// from the pool. Next, use a MTLRenderCommandEncoder object to render into the texture,
// then present it for display (typically with the presentDrawable: method of a
// command buffer). While one drawable is being presented, you can call the
// nextDrawable method again to begin rendering to another.
// After you present another drawable, replacing the last one presented,
// the layer can preserve the superseded drawable’s underlying MTLTexture object for reuse.
+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)init {
    if ((self = [super init])) {
        [self makeDevice];
        [self makeBuffers];
        [self makePipeline];
    }
    return self;
}

// to load from a story board we need initWithCoder
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self makeDevice];
        [self makeBuffers];
        [self makePipeline];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        // A CADisplayLink object is a timer object that allows your application to synchronize its drawing to the
        // refresh rate of the display. Your application creates a new display link, providing a target object and
        // a selector to be called when the screen is updated. Next, your application adds the display link to a run loop.
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    [self redraw];
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (void)makeDevice {
    //  A MTLDevice object represents a GPU that can execute commands
    _device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)makePipeline {
    // unlike OpenGL, Metal state is built into pre-compiled objects shaders are grouped in a (library)
    id<MTLLibrary> library = [_device newDefaultLibrary];

    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];

    // The MTLRenderPipelineDescriptor object specifies the rendering configuration
    // state used during a graphics rendering pass, including rasterization
    // (such as multisampling), visibility, blending, and graphics shader function state.
    // Use standard allocation and initialization techniques to create a
    // This is
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];

    // When drawing, we can target many different kinds of attachments.
    // Attachments describe the textures into which the results of drawing are written
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

    pipelineDescriptor.vertexFunction = vertexFunc; // setting the vertex shader
    pipelineDescriptor.fragmentFunction = fragmentFunc; // setting the fragment shader


    // use the pipeline descriptor to create the render pipeline state
    // "The pipeline state encapsulates the compiled and linked shader program derived from the
    // shaders we set on the descriptor"
    NSError *error = nil;
    _pipeline = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                       error:&error];

    if (!_pipeline) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }

    _commandQueue = [_device newCommandQueue];
}

- (void)makeBuffers {
    // defining vertex data in homogeneous coordinates
    static const Vertex vertices[] = {
        {.position = {0.0, 0.5, 0, 1}, .color = {1, 0, 0, 1}},
        {.position = {-0.5, -0.5, 0, 1}, .color = {0, 1, 0, 1}},
        {.position = {0.5, -0.5, 0, 1}, .color = {0, 0, 1, 1}}};

    _vertexBuffer = [_device newBufferWithBytes:vertices
                                        length:sizeof(vertices)
                                       options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)redraw {
    // Core Animation also defines the CAMetalDrawable protocol for objects that are displayable resources.
    // The CAMetalDrawable protocol extends MTLDrawable and provides an object that conforms to the MTLTexture protocol,
    // so it can be used as a destination for rendering commands. To render into a CAMetalLayer object, you should
    // get a new CAMetalDrawable object for each rendering pass, get the MTLTexture object that it provides,
    // and use that texture to create the color attachment. Unlike color attachments, creation and destruction
    // of a depth or stencil attachment are costly. If you need either depth or stencil attachments,
    // create them once and then reuse them each time a frame is rendered.

    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;

    // Command buffer and command encoder objects are inexpensive, transient and designed for a single use
    // "At any point in time, only a single command encoder can be active and append commands into a command buffer"

    if (drawable) {
        // a render pass descriptor tells Metal what actions to take while the image is being rendered
        // it contains a collection of attachments that are the rendering destination for pixels generated by a rendering pass
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
