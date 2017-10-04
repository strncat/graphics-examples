//
//  GameViewController.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/21/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;

    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        //skView.showsDrawCount = YES;
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        //skView.ignoresSiblingOrder = YES;
        
        // Create and configure the scene.
        GameScene *scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape; // landscape only
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
