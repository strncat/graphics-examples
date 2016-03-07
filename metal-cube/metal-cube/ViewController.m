//
//  ViewController.m
//  metal-cube
//  Source: Metal By Example - Warren Moore
//

#import "ViewController.h"
#import "MetalView.h"
#import "Renderer.h"

@interface ViewController ()
@property (nonatomic, strong) Renderer *renderer;
@end

@implementation ViewController

- (MetalView *)metalView {
    return (MetalView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.renderer = [Renderer new];
    self.metalView.delegate = self.renderer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
