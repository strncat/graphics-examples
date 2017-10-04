//
//  Ratz.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/29/15.
//
//

#import "Ratz.h"
#import "MainGameScene.h"

@implementation Ratz

#pragma mark Initialization

+ (Ratz *)initNewRatz:(SKScene *)whichScene startingPoint:(CGPoint)location ratzIndex:(int)index
{
    SKTexture *ratzTexture = [SKTexture textureWithImageNamed:kRatzRunRight1FileName];
    Ratz *ratz = [Ratz spriteNodeWithTexture:ratzTexture];
    ratz.name = [NSString stringWithFormat:@"ratz%d", index];
    ratz.position = location;
    ratz.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ratz.size];
    ratz.physicsBody.density = 1.0;
    ratz.physicsBody.linearDamping = 0.1;
    ratz.physicsBody.restitution = 0.2;
    ratz.physicsBody.allowsRotation = NO;

    ratz.physicsBody.categoryBitMask = kRatzCategory;

    // A mask that defines which categories of bodies cause intersection notifications with this physics body.
    ratz.physicsBody.contactTestBitMask = kWallCategory | kRatzCategory | kCoinCategory | kPipeCategory | kLedgeCategory | kBaseCategory | kPlayerCategory;

    // because we don't want ratz to go on top of each other .. they'll pass through each other 
    // A mask that defines which categories of physics bodies can collide with this physics body.
    ratz.physicsBody.collisionBitMask = kBaseCategory | kWallCategory | kLedgeCategory | kCoinCategory | kPipeCategory | kPlayerCategory;

    [whichScene addChild:ratz];
    return ratz;
}

- (void)spawnedInScene:(SKScene *)whichScene
{
    MainGameScene *theScene = (MainGameScene *)whichScene;
    _spriteTextures = theScene.spriteTextures;

    // Sound Effects
    _koSound = [SKAction playSoundFileNamed:kRatzKOSoundFileName
                             waitForCompletion:NO];
    _collectedSound = [SKAction playSoundFileNamed:kRatzCollectedSoundFileName
                             waitForCompletion:NO];
    _spawnSound = [SKAction playSoundFileNamed:kRatzSpawnSoundFileName
                             waitForCompletion:NO];
    _splashSound = [SKAction playSoundFileNamed:kRatzSplashedSoundFileName
                              waitForCompletion:NO];

    [self runAction:_spawnSound];

    // set initial direction and start moving
    if (self.position.x < CGRectGetMidX(whichScene.frame)) {
        [self runRight];
    } else {
        [self runLeft];
    }
}

#pragma mark Screen wrap

- (void)wrapRatz:(CGPoint)where
{
    SKPhysicsBody *storePB = self.physicsBody;
    self.physicsBody = nil;
    self.position = where;
    self.physicsBody = storePB;
}

#pragma mark Movement

- (void)runRight
{
    _ratzStatus = RatzRunningRight;
    SKAction *walkAnimation = [SKAction animateWithTextures:_spriteTextures.ratzRunRightTextures
                                               timePerFrame:0.05];
    SKAction *walkForever = [SKAction repeatActionForever:walkAnimation];
    [self runAction:walkForever];
    SKAction *moveRight = [SKAction moveByX: RatzRunningIncrement y:0 duration:1];
    SKAction *moveForever = [SKAction repeatActionForever:moveRight];
    [self runAction:moveForever];
}

- (void)runLeft
{
    _ratzStatus = RatzRunningLeft;
    SKAction *walkAnimation = [SKAction animateWithTextures:_spriteTextures.ratzRunLeftTextures timePerFrame:0.05];
    SKAction *walkForever = [SKAction repeatActionForever:walkAnimation];
    [self runAction:walkForever];
    SKAction *moveLeft = [SKAction moveByX:- RatzRunningIncrement y:0 duration:1];
    SKAction *moveForever = [SKAction repeatActionForever:moveLeft];
    [self runAction:moveForever];
}

- (void)turnRight
{
    self.ratzStatus = RatzRunningRight;
    [self removeAllActions];
    SKAction *moveRight = [SKAction moveByX:5 y:0 duration:0.4];
    [self runAction:moveRight completion:^{[self runRight];}];
}

- (void)turnLeft
{
    self.ratzStatus = RatzRunningLeft;
    [self removeAllActions];
    SKAction *moveLeft = [SKAction moveByX:-5 y:0 duration:0.4];
    [self runAction:moveLeft completion:^{[self runLeft];}];
}

- (void)ratzHitLeftPipe:(SKScene *)whichScene
{
    int leftSideX = CGRectGetMinX(whichScene.frame)+kEnemySpawnEdgeBufferX;
    int topSideY = CGRectGetMaxY(whichScene.frame)-kEnemySpawnEdgeBufferY;

    SKPhysicsBody *storedPB = self.physicsBody;
    self.physicsBody = nil;
    self.position = CGPointMake(leftSideX, topSideY);
    self.physicsBody = storedPB;
    [self removeAllActions];
    [self runRight];

    // Play spawning sound
    [self runAction:self.spawnSound];
}

- (void)ratzHitRightPipe:(SKScene *)whichScene
{
    int rightSideX = CGRectGetMaxX(whichScene.frame)-kEnemySpawnEdgeBufferX;
    int topSideY = CGRectGetMaxY(whichScene.frame)-kEnemySpawnEdgeBufferY;

    SKPhysicsBody *storedPB = self.physicsBody;
    self.physicsBody = nil;
    self.position = CGPointMake(rightSideX, topSideY);
    self.physicsBody = storedPB;
    [self removeAllActions];
    [self runLeft];

    // Play spawning sound
    [self runAction:self.spawnSound];
}

- (void)ratzKnockedOut:(SKScene *)whichScene
{
    [self removeAllActions];

    NSArray *textureArray = nil;

    if (_ratzStatus == RatzRunningLeft) {
        _ratzStatus = RatzKOfacingLeft;
        textureArray = [NSArray arrayWithArray:_spriteTextures.ratzKOfacingLeftTextures];
    } else {
        _ratzStatus = RatzKOfacingRight;
        textureArray = [NSArray arrayWithArray:_spriteTextures.ratzKOfacingRightTextures];
    }

    SKAction *knockedOutAnimation = [SKAction animateWithTextures:textureArray timePerFrame:0.5];
    SKAction *knockedOutForAwhile = [SKAction repeatAction:knockedOutAnimation count:1];

    [self runAction:knockedOutForAwhile completion:^{
        if (_ratzStatus == RatzKOfacingLeft) {
            [self runLeft];
        } else {
            [self runRight];
        }
    }];

    // Play knoced out sound sound
    [self runAction:self.koSound];
}

- (void)ratzCollected:(SKScene *)whichScene
{
    // Update status
    _ratzStatus = SBRatzKicked;

    NSLog(@"%@ collected", self.name);
    [self runAction:self.collectedSound];

    // show amount of winnings
    SKLabelNode *moneyText = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    moneyText.text = [NSString stringWithFormat:@"$%d", kRatzPointValue];
    moneyText.fontSize = 9;
    moneyText.fontColor = [SKColor whiteColor];
    moneyText.position = CGPointMake(self.position.x-10, self.position.y+28);
    [whichScene addChild:moneyText];
    SKAction *fadeAway = [SKAction fadeOutWithDuration:1];
    [moneyText runAction:fadeAway completion:^{ [moneyText removeFromParent];
    }];
    [self removeFromParent];

    // upward impulse applied
    [self.physicsBody applyImpulse:CGVectorMake(0, kRatzKickedIncrement)];

    // Make him spin when kicked
    SKAction *rotation = [SKAction rotateByAngle:M_PI duration:0.1];
    // 2*pi = 360deg, pi = 180deg
    SKAction *rotateForever = [SKAction repeatActionForever:rotation];
    [self runAction:rotateForever];

    // While kicked upward and spinning, wait for a short spell before altering physicsBody
    SKAction *shortDelay = [SKAction waitForDuration:0.5];

    [self runAction:shortDelay completion:^{
    // Make a new physics body that is much, much smaller as to not affect ledges as he falls...

    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1,1)];
    self.physicsBody.categoryBitMask = kRatzCategory;
    self.physicsBody.collisionBitMask = kWallCategory;
    self.physicsBody.contactTestBitMask = kWallCategory;
    self.physicsBody.linearDamping = 1.0;
    self.physicsBody.allowsRotation = YES;
    }];
}

- (void)ratzHitWater:(SKScene *)whichScene
{
    NSLog(@"%@ hit bottom of screen and is being removed", self.name);
    // Play sound
    [whichScene runAction:_splashSound];

    // splash eye candy
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"Splashed" ofType:@"sks"];
    SKEmitterNode *splash = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    splash.position = self.position;
    NSLog(@"splash (%f,%f)", splash.position.x, splash.position.y);
    splash.name = @"ratzSplash";
    splash.targetNode = whichScene.scene;
    [whichScene addChild:splash];

    [self removeFromParent];
}

@end
