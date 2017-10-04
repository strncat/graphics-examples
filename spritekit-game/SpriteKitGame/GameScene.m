//
//  GameScene.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/21/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MainGameScene.h"

@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];

        NSString *fileName = @"SewerSplash_568.png";

        // intro scene
        SKSpriteNode *splash = [SKSpriteNode spriteNodeWithImageNamed:fileName];
        splash.name = @"splashNode";
        splash.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

        [self addChild:splash];

        SKLabelNode *myText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];

        myText.text = @"Press To Start";
        myText.name = @"startNode";
        myText.fontSize = 30;
        myText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100);
        [self addChild:myText];

        SKAction *themeSong = [SKAction playSoundFileNamed:@"Theme.caf" waitForCompletion:NO];
        [self runAction:themeSong];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        SKNode *splashNode = [self childNodeWithName:@"splashNode"]; // SKScene
        SKNode *startNode = [self childNodeWithName:@"startNode"];

        if (splashNode != nil) { // make sure it exists
            splashNode.name = nil; // so that the transition only occurs once

            SKAction *zoom = [SKAction scaleTo: 4.0 duration: 1]; // create an SKAction
            SKAction *fadeAway = [SKAction fadeOutWithDuration: 1];
            SKAction *grouped = [SKAction group:@[zoom, fadeAway]];

            [startNode runAction:grouped];
            [splashNode runAction: grouped completion:^{
                // run the action on itself with a completion block to be executed after the action is done
                MainGameScene *nextScene = [[MainGameScene alloc] initWithSize:self.size];
                SKTransition *doors = [SKTransition doorwayWithDuration:0.5];
                [self.view presentScene:nextScene transition:doors];
            }];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
