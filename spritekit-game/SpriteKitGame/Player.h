//
//  Player.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/24/15.
//
//

#import <SpriteKit/SpriteKit.h>
#import "SpriteTextures.h"
#import "AppDelegate.h"

#define kPlayerSpawnSoundFileName @"SpawnPlayer.caf"
#define kPlayerRunSoundFileName @"Run.caf"
#define kPlayerSkidSoundFileName @"Skid.caf"
#define kPlayerJumpSoundFileName @"Jump.caf"
#define kPlayerBittenSoundFileName @"Playerbitten.caf"
#define kPlayerSplashedSoundFileName @"Splash.caf"

#define playerRunningIncrement 100
#define playerSkiddingIncrement 20
#define playerJumpingIncrement 8
#define kPlayerBittenIncrement 5

typedef enum : int {
    PlayerFacingLeft = 0,
    PlayerFacingRight,
    PlayerRunningLeft,
    PlayerRunningRight,
    PlayerSkiddingLeft,
    PlayerSkiddingRight,
    PlayerJumpingLeft,
    PlayerJumpingRight,
    PlayerJumpingUpFacingLeft,
    PlayerJumpingUpFacingRight,
    PlayerFalling
} PlayerStatus;

@interface Player : SKSpriteNode

@property (nonatomic, strong) SpriteTextures *spriteTextures;
@property PlayerStatus playerStatus;
@property (nonatomic, strong) SKAction *spawnSound;
@property (nonatomic, strong) SKAction *runSound, *jumpSound, *skidSound, *bittenSound, *splashSound;

+ (Player *)initNewPlayer:(SKScene *)whichScene startingPoint:(CGPoint)location;
- (void)runRight;
- (void)runLeft;
- (void)skidRight;
- (void)skidLeft;
- (void)wrapPlayer:(CGPoint)where;
- (void)jump;
- (void)spawnedInScene:(SKScene *)whichScene;
- (void)playerKilled:(SKScene *)whichScene;
- (void)playerHitWater:(SKScene *)whichScene;
@end
