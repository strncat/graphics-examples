//
//  Ratz.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/29/15.
//
//

#import <SpriteKit/SpriteKit.h>
#import "AppDelegate.h"
#import "SpriteTextures.h"

@interface Ratz : SKSpriteNode

#define kRatzSpawnSoundFileName @"SpawnEnemy.caf"
#define kRatzKOSoundFileName @"EnemyKO.caf"
#define kRatzCollectedSoundFileName @"EnemyCollected.caf"
#define kRatzSplashedSoundFileName @"Splash.caf"

#define RatzRunningIncrement 40
#define kRatzPointValue 100
#define kRatzKickedIncrement 5

typedef enum : int {
    RatzRunningLeft = 0,
    RatzRunningRight,
    RatzKOfacingLeft,
    RatzKOfacingRight,
    SBRatzKicked
} RatzStatus;

@property (nonatomic, strong) SpriteTextures *spriteTextures;
@property int ratzStatus;
@property (nonatomic, strong) SKAction *spawnSound, *koSound, *collectedSound, *splashSound;
@property int lastKnownXposition, lastKnownYposition;
@property (nonatomic, strong) NSString *lastKnownContactedLedge;

+ (Ratz *)initNewRatz:(SKScene *)whichScene startingPoint:(CGPoint)location ratzIndex:(int)index;
- (void)spawnedInScene:(SKScene *)whichScene;
- (void)wrapRatz:(CGPoint)where;
- (void)runRight;
- (void)runLeft;
- (void)turnRight;
- (void)turnLeft;

- (void)ratzHitLeftPipe:(SKScene *)whichScene;
- (void)ratzHitRightPipe:(SKScene *)whichScene;

- (void)ratzKnockedOut:(SKScene *)whichScene;
- (void)ratzCollected:(SKScene *)whichScene;
- (void)ratzHitWater:(SKScene *)whichScene;
@end
