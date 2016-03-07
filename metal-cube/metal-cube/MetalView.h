//
//  MetalView.h
//  metal-cube
//  Source: Metal By Example - Warren Moore
//

#import <UIKit/UIKit.h>

@import UIKit;
@import Metal;
@import QuartzCore.CAMetalLayer;
@import simd;

@protocol MetalViewDelegate;

@interface MetalView : UIView
@property (nonatomic, weak) id<MetalViewDelegate> delegate;
@property (nonatomic, readonly) CAMetalLayer *metalLayer;
@property (nonatomic) NSInteger preferredFramesPerSecond;

@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic, assign) MTLClearColor clearColor;
@property (nonatomic, readonly) NSTimeInterval frameDuration;
@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;

/// A render pass descriptor configured to use the current drawable's texture
/// as its primary color attachment and an internal depth texture of the same
/// size as its depth attachment's texture
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;
@end

@protocol MetalViewDelegate <NSObject>
// called once per frame
- (void)drawInView:(MetalView *)view;
@end