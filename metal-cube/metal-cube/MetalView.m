//
//  MetalView.m
//  metal-cube
//  Source: Metal By Example - Warren Moore
//


#import "MetalView.h"

@interface MetalView ()
@property (strong) id<CAMetalDrawable> currentDrawable;
@property (assign) NSTimeInterval frameDuration;
@property (strong) id<MTLTexture> depthTexture;
@property (strong) CADisplayLink *displayLink;
@end

@implementation MetalView

+(Class)layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
        self.metalLayer.device = MTLCreateSystemDefaultDevice();
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame device:(id<MTLDevice>)device {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
        self.metalLayer.device = device;
    }
    return self;
}

- (void)commonInit {
    _preferredFramesPerSecond = 60;
    _clearColor = MTLClearColorMake(1, 1, 1, 1);
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    // During the first layout pass, we will not be in a view hierarchy, so we guess our scale
    CGFloat scale = [UIScreen mainScreen].scale;

    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    if (self.window) {
        scale = self.window.screen.scale;
    }

    CGSize drawableSize = self.bounds.size;
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;

    self.metalLayer.drawableSize = drawableSize;
    [self makeDepthTexture];
}

- (void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat {
    self.metalLayer.pixelFormat = colorPixelFormat;
}

- (MTLPixelFormat)colorPixelFormat {
    return self.metalLayer.pixelFormat;
}

- (void)didMoveToWindow {
    const NSTimeInterval idealFrameDuration = (1.0 / 60);
    const NSTimeInterval targetFrameDuration = (1.0 / self.preferredFramesPerSecond);
    const NSInteger frameInterval = round(targetFrameDuration / idealFrameDuration);

    if (self.window) {
        [self.displayLink invalidate];

        // A CADisplayLink object is a timer object that allows your application to synchronize its drawing to the
        // refresh rate of the display. Your application creates a new display link, providing a target object and
        // a selector to be called when the screen is updated. Next, your application adds the display link to a run loop.
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];

        // The number of frames that must pass before the display link notifies the target again.
        self.displayLink.frameInterval = frameInterval;

        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    //NSLog(@"displayLinkDidFire");
    self.currentDrawable = [self.metalLayer nextDrawable];
    self.frameDuration = displayLink.duration;
    //NSLog(@"%f", self.frameDuration);
    if ([self.delegate respondsToSelector:@selector(drawInView:)]) {

        // every time the displayLink fires we ask the delegate to invoke drawInView
        [self.delegate drawInView:self];
    }
}

- (void)makeDepthTexture {
    CGSize drawableSize = self.metalLayer.drawableSize;

    if ([self.depthTexture width] != drawableSize.width ||
        [self.depthTexture height] != drawableSize.height) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                                        width:drawableSize.width
                                                                                       height:drawableSize.height
                                                                                    mipmapped:NO];
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
    }
}

- (MTLRenderPassDescriptor *)currentRenderPassDescriptor {
    // https://developer.apple.com/library/ios/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Render-Ctx/Render-Ctx.html#//apple_ref/doc/uid/TP40014221-CH7-SW1
    // "Typically, you create a MTLRenderPassDescriptor object once and reuse it each time your app renders a frame."
    // create a render pass descriptor
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;

    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    return passDescriptor;
}

@end
