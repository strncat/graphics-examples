//
//  Player.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/24/15.
//
//

#import "Player.h"
#import "MainGameScene.h"

@implementation Player

#pragma mark Initialization

+ (Player *)initNewPlayer:(SKScene *)whichScene startingPoint:(CGPoint)location;
{
    // initial frame
    SKTexture *f1 = [SKTexture textureWithImageNamed: playerStillFacingRightFileName];

    // our player character sprite & starting position in the scene
    Player *player = [Player spriteNodeWithTexture:f1];
    player.name = @"player1";
    player.position = location;
    player.playerStatus = PlayerFacingRight;

    // physics body properties
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size];
    player.physicsBody.categoryBitMask = kPlayerCategory; // A mask that defines which categories this physics body belongs to

    // which categories of bodies cause intersection notifications with this physics body
    player.physicsBody.contactTestBitMask = kWallCategory | kRatzCategory | kCoinCategory | kLedgeCategory | kRatzCategory;

    player.physicsBody.density = 1.0; // The density of the object in kilograms per square meter
    player.physicsBody.linearDamping = 0.1; // A property that reduces the body’s linear velocity
    player.physicsBody.restitution = 0.2; // This property is used to determine how much energy the physics body loses when it bounces off another object
    player.physicsBody.allowsRotation = NO; // don't rotate

    // A mask that defines which categories of physics bodies can collide with this physics body.
    player.physicsBody.collisionBitMask = kBaseCategory | kWallCategory | kLedgeCategory | kRatzCategory;

    // add the sprite to the scene
    [whichScene addChild:player];
    return player;
}

- (void)spawnedInScene:(SKScene *)whichScene
{
    MainGameScene *theScene = (MainGameScene *)whichScene;
    _spriteTextures = theScene.spriteTextures;
    // Sounds

    // wait: If YES, the duration of this action is the same as the length of the audio playback.
    // If NO, the action is considered to have completed immediately.

    _spawnSound = [SKAction playSoundFileNamed:kPlayerSpawnSoundFileName waitForCompletion:NO];
    _runSound = [SKAction playSoundFileNamed:kPlayerRunSoundFileName waitForCompletion:YES];
    _jumpSound = [SKAction playSoundFileNamed:kPlayerJumpSoundFileName waitForCompletion:NO];
    _skidSound = [SKAction playSoundFileNamed:kPlayerSkidSoundFileName waitForCompletion:YES];
    _bittenSound = [SKAction playSoundFileNamed:kPlayerBittenSoundFileName waitForCompletion:NO];
    _splashSound = [SKAction playSoundFileNamed:kPlayerSplashedSoundFileName waitForCompletion:NO];

    // Play sound
    [self runAction:_spawnSound];
}

#pragma mark Screen wrap

- (void)wrapPlayer:(CGPoint)where
{
    SKPhysicsBody *storePB = self.physicsBody;
    self.physicsBody = nil;
    self.position = where;
    self.physicsBody = storePB;
}

#pragma mark Contact

- (void)playerKilled:(SKScene *)whichScene
{
    NSLog(@"dead!!!!!!!!!");
    _playerStatus = PlayerFalling;

    [self removeAllActions];
    [whichScene runAction:_bittenSound];

    // upward impulse applied
    [self.physicsBody applyImpulse:CGVectorMake(0, kPlayerBittenIncrement)];
    SKAction *shortDelay = [SKAction waitForDuration:0.5];

    [self runAction:shortDelay completion:^{
    // a new physics body that won't be affected by enemies when falling
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1,1)];
    self.physicsBody.categoryBitMask = kPlayerCategory;
    self.physicsBody.collisionBitMask = kWallCategory;
    self.physicsBody.contactTestBitMask = kWallCategory;
    self.physicsBody.linearDamping = 1.0;
    self.physicsBody.allowsRotation = NO;
    }];
}

- (void)playerHitWater:(SKScene *)whichScene
{
    [self removeFromParent];
    [whichScene runAction:_splashSound];

    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"Splashed" ofType:@"sks"];
    SKEmitterNode *splash = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    splash.position = self.position;
    splash.name = @"playerSplash";
    splash.targetNode = whichScene.scene;
    [whichScene addChild:splash];
}

#pragma mark Movement

- (void)runRight
{
    NSLog(@"run Right");
    _playerStatus = PlayerRunningRight;

    SKAction *walkAnimation = [SKAction animateWithTextures:_spriteTextures.playerRunRightTextures timePerFrame:0.05];
    SKAction *walkForever = [SKAction repeatActionForever:walkAnimation];
    [self runAction:walkForever];

    SKAction *moveRight = [SKAction moveByX:playerRunningIncrement y:0 duration:1];
    SKAction *moveForever = [SKAction repeatActionForever:moveRight];
    [self runAction:moveForever];

    // Sound effect for running
    SKAction *shortPause = [SKAction waitForDuration:0.01];
    SKAction *sequence = [SKAction sequence:@[_runSound, shortPause]];
    SKAction *soundContinuous = [SKAction repeatActionForever:sequence];
    [self runAction:soundContinuous withKey:@"soundContinuous"];
}

- (void)runLeft
{
    NSLog(@"run Left");
    _playerStatus = PlayerRunningLeft;

    SKAction *walkAnimation = [SKAction animateWithTextures:_spriteTextures.playerRunLeftTextures timePerFrame:0.05];
    SKAction *walkForever = [SKAction repeatActionForever:walkAnimation];
    [self runAction:walkForever];

    SKAction *moveLeft = [SKAction moveByX:-playerRunningIncrement y:0 duration:1];
    SKAction *moveForever = [SKAction repeatActionForever:moveLeft];
    [self runAction:moveForever];

    // Sound effect for running
    SKAction *shortPause = [SKAction waitForDuration:0.01];
    SKAction *sequence = [SKAction sequence:@[_runSound, shortPause]];
    SKAction *soundContinuous = [SKAction repeatActionForever:sequence];
    [self runAction:soundContinuous withKey:@"soundContinuous"];
}

- (void)skidRight
{
    NSLog(@"skid Right");
    [self removeAllActions];
    _playerStatus = PlayerSkiddingRight;

    NSArray *playerSkidTextures = _spriteTextures.playerSkiddingRightTextures;
    NSArray *playerStillTextures = _spriteTextures.playerStillFacingRightTextures;

    SKAction *skidAnimation = [SKAction animateWithTextures:playerSkidTextures timePerFrame:1];
    SKAction *skidAwhile = [SKAction repeatAction:skidAnimation count:0.2];

    SKAction *moveLeft = [SKAction moveByX:playerSkiddingIncrement y:0 duration:0.2];
    SKAction *moveAwhile = [SKAction repeatAction:moveLeft count:1];

    SKAction *stillAnimation = [SKAction animateWithTextures:playerStillTextures timePerFrame:1];
    SKAction *stillAwhile = [SKAction repeatAction:stillAnimation count:0.1];

    SKAction *sequence = [SKAction sequence:@[skidAwhile, moveAwhile, stillAwhile]];
    SKAction *group = [SKAction group:@[sequence, _skidSound]];

    [self runAction:group completion:^{
        NSLog(@"skid ended, still facing right");
        _playerStatus = PlayerFacingRight;
    }];
}

- (void)skidLeft
{
    NSLog(@"skid Left");
    [self removeAllActions];
    _playerStatus = PlayerSkiddingLeft;

    NSArray *playerSkidTextures = _spriteTextures.playerSkiddingLeftTextures;
    NSArray *playerStillTextures = _spriteTextures.playerStillFacingLeftTextures;

    SKAction *skidAnimation = [SKAction animateWithTextures:playerSkidTextures timePerFrame:1];
    SKAction *skidAwhile = [SKAction repeatAction:skidAnimation count:0.2];

    SKAction *moveLeft = [SKAction moveByX:-playerSkiddingIncrement y:0 duration:0.2];
    SKAction *moveAwhile = [SKAction repeatAction:moveLeft count:1];

    SKAction *stillAnimation = [SKAction animateWithTextures:playerStillTextures timePerFrame:1];
    SKAction *stillAwhile = [SKAction repeatAction:stillAnimation count:0.1];

    SKAction *sequence = [SKAction sequence:@[skidAwhile, moveAwhile, stillAwhile]];
    SKAction *group = [SKAction group:@[sequence, _skidSound]];

    [self runAction:group completion:^{
        NSLog(@"skid ended, still facing left");
        _playerStatus = PlayerFacingLeft;
    }];
}

- (void)jump
{
    // Stop running Sound Effects
    [self removeActionForKey:@"soundContinuous"];

    NSArray *playerJumpTextures = nil;
    PlayerStatus nextPlayerStatus = 0;

    // determine direction and next phase
    if (self.playerStatus == PlayerRunningLeft || self.playerStatus == PlayerSkiddingLeft) {
        NSLog(@"jump left");
        self.playerStatus = PlayerJumpingLeft;
        playerJumpTextures = _spriteTextures.playerJumpLeftTextures;
        nextPlayerStatus = PlayerRunningLeft;
    } else if (self.playerStatus == PlayerRunningRight || self.playerStatus == PlayerSkiddingRight) {
        NSLog(@"jump right");
        self.playerStatus = PlayerJumpingRight;
        playerJumpTextures = _spriteTextures.playerJumpRightTextures;
        nextPlayerStatus = PlayerRunningRight;
    } else if (self.playerStatus == PlayerFacingLeft) {
        NSLog(@"jump up, facing left");
        self.playerStatus = PlayerJumpingUpFacingLeft;
        playerJumpTextures = _spriteTextures.playerJumpLeftTextures;
        nextPlayerStatus = PlayerFacingLeft;
    } else if (self.playerStatus == PlayerFacingRight) {
        NSLog(@"jump up, facing right");
        self.playerStatus = PlayerJumpingUpFacingRight;
        playerJumpTextures = _spriteTextures.playerJumpRightTextures;
        nextPlayerStatus = PlayerFacingRight;
    } else {
        NSLog(@"invalid value...");
    }

    // applicable animation
    SKAction *jumpAnimation = [SKAction animateWithTextures:playerJumpTextures timePerFrame:0.2];
    SKAction *jumpAwhile = [SKAction repeatAction:jumpAnimation count:4.0];
    SKAction *groupedJump = [SKAction group:@[_jumpSound, jumpAwhile]];

    // run jump action and when completed handle next phase
    [self runAction:groupedJump completion:^{
        if (nextPlayerStatus == PlayerRunningLeft) {
            [self removeAllActions];
            [self runLeft];
        } else if (nextPlayerStatus == PlayerRunningRight) {
            [self removeAllActions];
            [self runRight];
        } else if (nextPlayerStatus == PlayerFacingLeft) {
            NSArray *playerStillTextures = _spriteTextures.playerStillFacingLeftTextures;
            SKAction *stillAnimation = [SKAction animateWithTextures:playerStillTextures timePerFrame:1];
            SKAction *stillAwhile = [SKAction repeatAction:stillAnimation count:0.1];
            [self runAction:stillAwhile];
            self.playerStatus = PlayerFacingLeft;
        } else if (nextPlayerStatus == PlayerFacingRight) {
            NSArray *playerStillTextures = _spriteTextures.playerStillFacingRightTextures;
            SKAction *stillAnimation = [SKAction animateWithTextures:playerStillTextures timePerFrame:1];
            SKAction *stillAwhile = [SKAction repeatAction:stillAnimation count:0.1];
            [self runAction:stillAwhile];
            self.playerStatus = PlayerFacingRight;
        } else {
            NSLog(@"invalid value...");
        }
    }];

    // applies an impulse uniformly to a physics body
    // jump impulse applied
    [self.physicsBody applyImpulse:CGVectorMake(0, playerJumpingIncrement)];
}

@end
