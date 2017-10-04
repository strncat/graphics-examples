//
//  Coin.h
//  SpriteKitGame
//
//  Created by Fatima B on 12/1/15.
//
//

#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"
#import "SpriteTextures.h"

#define kCoinSpawnSoundFileName @"SpawnCoin.caf"
#define kCoinCollectedSoundFileName @"CoinCollected.caf"

#define kCoinRunningIncrement 40
#define kCoinPointValue 60

typedef enum : int {
    CoinRunningLeft = 0,
    CoinRunningRight
} CoinStatus;

@interface Coin : SKSpriteNode

@property int coinStatus;
@property (nonatomic, strong) SpriteTextures *spriteTextures;
@property (nonatomic, strong) SKAction *spawnSound, *collectedSound;
@property int lastKnownXposition, lastKnownYposition;
@property (nonatomic, strong) NSString *lastKnownContactedLedge;

+ (Coin *)initNewCoin:(SKScene *)whichScene startingPoint:(CGPoint)location
            coinIndex:(int)index;

- (void)spawnedInScene:(SKScene *)whichScene;
- (void)wrapCoin:(CGPoint)where;

- (void)runRight;
- (void)runLeft;
- (void)turnRight;
- (void)turnLeft;

- (void)coinHitPipe;
- (void)coinCollected:(SKScene *)whichScene;

@end
