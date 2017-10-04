//
//  Ledge.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/25/15.
//
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"

#define kLedgeBrickFileName @"LedgeBrick.png"

#define kLedgeBrickSpacing 9
#define kLedgeSideBufferSpacing 4


@interface Ledge : NSObject

- (void)createNewSetOfLedgeNodes:(SKScene *)whichScene startingPoint:(CGPoint)leftSide withHowManyBlocks:(int)blockCount startingIndex:(int)indexStart;

@end