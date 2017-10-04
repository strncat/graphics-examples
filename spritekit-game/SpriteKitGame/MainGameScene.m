//
//  MainGameScene.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/23/15.
//
//

#import "GameScene.h"
#import "MainGameScene.h"
#import "Ratz.h"
#import "Player.h"
#import "Ledge.h"
#import "Coin.h"

@implementation MainGameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];

        // wall body bounded by the frame
        CGRect edgeRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:edgeRect];
        self.physicsBody.categoryBitMask = kWallCategory;
        self.physicsWorld.contactDelegate = self;

        // initialize and create our sprite textures
        _spriteTextures = [[SpriteTextures alloc] init];
        [_spriteTextures createAnimationTextures];

        // Background: SKSpriteNode is a node that draws a textured image
        SKSpriteNode *backdrop = [SKSpriteNode spriteNodeWithImageNamed:@"Backdrop_480"];
        backdrop.name = @"backdropNode";
        backdrop.size = self.frame.size;
        backdrop.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

        // add the background to the Scene
        [self addChild:backdrop];

        // add content to the Scene (Ledges .. etc)
        [self createSceneContents];

        // start at level 1
        _currentLevel = 1;

        // Create our characters
        [self loadCastOfCharacters:_currentLevel];
    }
    return self;
}

#pragma mark

- (void)loadCastOfCharacters:(int)levelNumber
{
    // load cast from plist file
    NSString *path = [[NSBundle mainBundle] pathForResource:kCastOfCharactersFileName ofType:@"plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    if (plistDictionary) {
        NSDictionary *levelDictionary = [plistDictionary valueForKey:@"Level"];
        if (levelDictionary) {
            NSArray *singleLevelArray = [NSArray arrayWithObject:path]; // temp object
            switch (levelNumber) {
                case 1: singleLevelArray = [levelDictionary valueForKey:@"One"];
                    break;
                case 2:
                    singleLevelArray = [levelDictionary valueForKey:@"Two"];
                    break;
                default:
                    singleLevelArray = [levelDictionary valueForKey:@"Two"];
                    break;
            }
            if (singleLevelArray) {
                NSDictionary *enemyDictionary = nil;
                NSMutableArray *newTypeArray = [NSMutableArray arrayWithCapacity:[singleLevelArray count]];
                NSMutableArray *newDelayArray = [NSMutableArray arrayWithCapacity:[singleLevelArray count]];
                NSMutableArray *newStartArray = [NSMutableArray arrayWithCapacity:[singleLevelArray count]];
                NSNumber *rawType, *rawDelay, *rawStartXindex;

                int enemyType, spawnDelay, startXindex = 0;

                for (int index=0; index<[singleLevelArray count]; index++) {
                    enemyDictionary = [singleLevelArray objectAtIndex:index];

                    // NSNumbers from dictionary
                    rawType = [enemyDictionary valueForKey:@"Type"];
                    rawDelay = [enemyDictionary valueForKey:@"Delay"];
                    rawStartXindex = [enemyDictionary valueForKey:@"StartXindex"];

                    // local integer values
                    enemyType = [rawType intValue];
                    spawnDelay = [rawDelay intValue];
                    startXindex = [rawStartXindex intValue];

                    // long term storage
                    [newTypeArray addObject:rawType];
                    [newDelayArray addObject:rawDelay];
                    [newStartArray addObject:rawStartXindex];
                }
                // store data locally
                _castTypeArray = [NSArray arrayWithArray:newTypeArray];
                _castDelayArray = [NSArray arrayWithArray:newDelayArray];
                _castStartXindexArray = [NSArray arrayWithArray:newStartArray];
            } else {
                NSLog(@"No levelOneArray");
            }
        } else {
            NSLog(@"No levelDictionary");
        }
    } else {
        NSLog(@"no plist found");
    }
}

#pragma mark Scene creation

- (void)createSceneContents
{
    // Initialize Enemies & Schedule
    _spawnedEnemyCount = 0;
    _enemyIsSpawningFlag = NO;
    _gameIsOverFlag = NO;
    _gameIsPaused = NO;


    // BASE node
    SKSpriteNode *brickBase = [SKSpriteNode spriteNodeWithImageNamed:@"Base_600"];
    brickBase.name = @"brickBaseNode";
    brickBase.size = CGSizeMake(self.frame.size.width, brickBase.size.height);
    brickBase.position = CGPointMake(CGRectGetMidX(self.frame), brickBase.size.height/2);
    brickBase.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brickBase.size];
    brickBase.physicsBody.categoryBitMask = kBaseCategory;
    brickBase.physicsBody.dynamic = NO; // not moved by the physics simulation
    [self addChild:brickBase]; // add it to the scene


    // LEDGES
    Ledge *sceneLedge = [[Ledge alloc] init];
    int ledgeIndex = 0;

    // ledge, bottom left
    int ledgeCount = 0;
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 18; } else { ledgeCount = 23; }

    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(kLedgeSideBufferSpacing, brickBase.position.y+80) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, bottom right
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMaxX(self.frame)-kLedgeSideBufferSpacing-((ledgeCount-1)*kLedgeBrickSpacing), brickBase.position.y+80) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, middle left
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 6; } else { ledgeCount = 8; }
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMinX(self.frame)+kLedgeSideBufferSpacing, brickBase.position.y+142) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, middle middle
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 31; } else { ledgeCount = 36; }
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMidX(self.frame)-((ledgeCount * kLedgeBrickSpacing) / 2), brickBase.position.y+152) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, middle right
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 6; } else { ledgeCount = 9; }
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMaxX(self.frame)-kLedgeSideBufferSpacing-((ledgeCount-1)*kLedgeBrickSpacing), brickBase.position.y+142) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, top left
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 23; } else { ledgeCount = 28; }
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMinX(self.frame)+kLedgeSideBufferSpacing, brickBase.position.y+224) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;

    // ledge, top right
    if (CGRectGetMaxX(self.frame) < 500) { ledgeCount = 23; } else { ledgeCount = 28; }
    [sceneLedge createNewSetOfLedgeNodes:self startingPoint:CGPointMake(CGRectGetMaxX(self.frame)-kLedgeSideBufferSpacing-((ledgeCount-1)*kLedgeBrickSpacing), brickBase.position.y+224) withHowManyBlocks:ledgeCount startingIndex:ledgeIndex];
    ledgeIndex = ledgeIndex + ledgeCount;


    // Grates
    SKSpriteNode *grate = [SKSpriteNode spriteNodeWithImageNamed:@"Grate.png"];
    grate.name = @"grate1";
    grate.position = CGPointMake(30, CGRectGetMaxY(self.frame)-25);
    [self addChild:grate];

    grate = [SKSpriteNode spriteNodeWithImageNamed:@"Grate.png"];
    grate.name = @"grate2";
    grate.position = CGPointMake(CGRectGetMaxX(self.frame)-30, CGRectGetMaxY(self.frame)-25);
    [self addChild:grate];


    // Pipes
    SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithImageNamed:@"PipeLwrLeft.png"];
    pipe.name = @"pipeLeft";
    pipe.position = CGPointMake(9, 25);
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
    pipe.physicsBody.categoryBitMask = kPipeCategory;
    pipe.physicsBody.dynamic = NO;
    [self addChild:pipe];

    pipe = [SKSpriteNode spriteNodeWithImageNamed:@"PipeLwrRight.png"];
    pipe.name = @"pipeRight";
    pipe.position = CGPointMake(CGRectGetMaxX(self.frame)-9, 25);
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
    pipe.physicsBody.categoryBitMask = kPipeCategory;
    pipe.physicsBody.dynamic = NO;
    [self addChild:pipe];

    // read high score from disk (if written there by previous game)
    NSNumber *theScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    _highScore = [theScore intValue];

    // Scores
    _scoreDisplay = [[Scores alloc] init];
    [_scoreDisplay createScoreNodes:self];
    _playerScore = 0;
    [_scoreDisplay updateScore:self newScore:_playerScore hiScore:_highScore];


    // Player
    _playerSprite = [Player initNewPlayer:self startingPoint:CGPointMake(40, 25)];
    [_playerSprite spawnedInScene:self];
    _playerLivesRemaining = kPlayerLivesMax;
    _playerIsDeadFlag = NO;
    [self playerLivesDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self]; //current location of the receiver in the coordinate system of the given node
        PlayerStatus status = _playerSprite.playerStatus;

        if (_gameIsOverFlag) {
            [self removeAllActions];
            [self removeAllChildren];
            GameScene *nextScene  = [[GameScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorwayWithDuration:0.5];
            [self.view presentScene:nextScene transition:doors];

        } else if (location.y >= (self.frame.size.height/2 )) { // UPPER HALF = JUMP
            if (status != PlayerJumpingLeft && status != PlayerJumpingRight && status != PlayerJumpingUpFacingLeft && status != PlayerJumpingUpFacingRight) {
                [_playerSprite jump];
            }

        } else if (location.x <= ( self.frame.size.width/2 )) { // LOWER LEFT
            if (status == PlayerRunningRight) { // IF RUNNING STOP
                [_playerSprite skidRight];
            } else if (status == PlayerFacingLeft || status == PlayerFacingRight) {
                [_playerSprite runLeft];
            }

        } else { // LOWER RIGHT
            if (status == PlayerRunningLeft) {
                [_playerSprite skidLeft];
            } else if (status == PlayerFacingLeft || status == PlayerFacingRight) {
                [_playerSprite runRight];
            }
        }
    }
}

- (void)gameIsOver
{
    _gameIsOverFlag = YES;
    [self removeAllActions];
    [self removeAllChildren];

    if (_playerScore > _highScore) {
        _highScore = _playerScore;
        [_scoreDisplay updateScore:self newScore:_playerScore hiScore:_highScore];

        // write it to disk
        NSNumber *theScore = [NSNumber numberWithInt:_highScore];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:theScore forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    SKLabelNode *gameOverText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOverText.text = @"Game Over";
    gameOverText.fontSize = 60;
    gameOverText.xScale = 0.1;
    gameOverText.yScale = 0.1;
    gameOverText.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame));

    SKLabelNode *pressAnywhereText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    pressAnywhereText.text = @"Press anywhere to continue";
    pressAnywhereText.fontSize = 12;
    pressAnywhereText.position = CGPointMake(CGRectGetMidX(self.frame),
                                             CGRectGetMidY(self.frame)-100);

    SKAction *zoom = [SKAction scaleTo:1.0 duration:2];
    SKAction *rotate = [SKAction rotateByAngle:M_PI duration:0.5];
    SKAction *rotateAbit = [SKAction repeatAction:rotate count:4];
    SKAction *group = [SKAction group:@[zoom,rotateAbit]];

    [gameOverText runAction:group];
    [self addChild:gameOverText];
    [self addChild:pressAnywhereText];
}

- (void)playerLivesDisplay
{
    NSLog(@"new life!!!!!");
    SKTexture *lifeTexture = [SKTexture textureWithImageNamed:playerStillFacingRightFileName];
    CGPoint startWhere = CGPointMake(CGRectGetMinX(self.frame)+kScorePlayerDistanceFromLeft+60, CGRectGetMaxY(self.frame)-kScoreDistanceFromTop-20);

    for (int index=1; index <= kPlayerLivesMax; index++) {
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"player_lives%d", index] usingBlock:^(SKNode *node, BOOL *stop) {
            *stop = YES;
            [node removeFromParent];
        }];
    }

    // One body icon per life remaining
    for (int index=1; index <= _playerLivesRemaining; index++) {
        NSLog(@"new life");
        SKSpriteNode *lifeNode = [SKSpriteNode spriteNodeWithTexture:lifeTexture];
        lifeNode.name = [NSString stringWithFormat:@"player_lives%d", index];
        lifeNode.position = CGPointMake(startWhere.x+(kPlayerLivesSpacing*index), startWhere.y);
        lifeNode.xScale = 0.5;
        lifeNode.yScale = 0.5;
        [self addChild:lifeNode];
    }
}

- (void)levelCompleted
{
    NSLog(@"Level is completed!");
    [self removeAllActions];
    _gameIsPaused = YES;

    // Remove player sprite from scene
    [self enumerateChildNodesWithName:[NSString stringWithFormat:@"player1"] usingBlock:^(SKNode *node, BOOL *stop) {
        *stop = YES;
        [node removeFromParent];
    }];

    // Play sound
    SKAction *completedSong = [SKAction playSoundFileNamed:@"LevelCompleted.caf" waitForCompletion:NO];
    [self runAction:completedSong];

    SKLabelNode *levelText = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    levelText.text = @"Level Completed";
    levelText.fontSize = 48;
    levelText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.25];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.25];
    SKAction *sequence = [SKAction sequence:@[fadeIn,fadeOut,fadeIn,fadeOut,fadeIn,fadeOut,fadeIn,fadeOut,fadeIn,fadeOut,fadeIn,fadeOut]];
    [self addChild:levelText];
    [levelText runAction:sequence completion:^{
        [levelText removeFromParent];

        // Player reappears at starting location
        _playerSprite = [Player initNewPlayer:self startingPoint:CGPointMake(40, 25)];
        [_playerSprite spawnedInScene:self];

        // Trigger a new level and it's cast of characters
        _currentLevel++;
        [self loadCastOfCharacters:_currentLevel];
        _gameIsPaused = NO;
        _spawnedEnemyCount = 0;
        _enemyIsSpawningFlag = NO;
    }];
}

- (void)checkForEnemyHits:(NSString *)struckLedgeName
{
    // Coins
    for (int index=0; index <= _spawnedEnemyCount; index++) {
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"coin%d", index] usingBlock:^(SKNode *node, BOOL *stop) {
            *stop = YES;
            Coin *theCoin = (Coin *)node;

            // struckLedge check
            if ([theCoin.lastKnownContactedLedge isEqualToString:struckLedgeName]) {
                NSLog(@"Player hit %@ where %@ is known to be", struckLedgeName, theCoin.name);
                [theCoin coinCollected:self];
                _activeEnemyCount--;
            }
        }];
    }

    // Ratz
    for (int index=0; index <= _spawnedEnemyCount; index++) {
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"ratz%d", index] usingBlock:^(SKNode *node, BOOL *stop) {
            *stop = YES;
            Ratz *theRatz = (Ratz *)node;

            // struckLedge check
            if ([theRatz.lastKnownContactedLedge isEqualToString:struckLedgeName]) {
                NSLog(@"Player hit %@ where %@ is known to be", struckLedgeName, theRatz.name);
                [theRatz ratzKnockedOut:self];
            }
        }];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact // bodyA, bodyB, contactPoint, collisionImpulse
{
    SKPhysicsBody *firstBody, *secondBody;

    // just to make an order, player has the lower category bit mask
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    // contact body name
    NSString *firstBodyName = firstBody.node.name;


    // Player <> Base Collision
    if ((((firstBody.categoryBitMask & kPlayerCategory) != 0) &&
         ((secondBody.categoryBitMask & kBaseCategory) != 0))) {
        NSLog(@"player contacted base"); // not needed I guess

    }

    // Player <> Wall Collision
    if ((((firstBody.categoryBitMask & kPlayerCategory) != 0)
         && ((secondBody.categoryBitMask & kWallCategory) != 0))) {
        if (_playerSprite.playerStatus != PlayerFalling) {
            if ([firstBodyName isEqualToString: @"player1"]) {
                if (_playerSprite.position.x < 100) {
                    NSLog(@"player contacted left edge");
                    [_playerSprite wrapPlayer:CGPointMake(self.frame.size.width-10, _playerSprite.position.y)];
                } else {
                    NSLog(@"player contacted right edge");
                    [_playerSprite wrapPlayer:CGPointMake(10, _playerSprite.position.y)];
                }
            }
        } else {
            [_playerSprite playerHitWater:self];
            _playerIsDeadFlag = YES;
        }
    }

    // Ratz <> Wall Collision
    if ((((firstBody.categoryBitMask & kWallCategory) != 0)
         &&((secondBody.categoryBitMask & kRatzCategory) != 0))) {
        Ratz *theRatz = (Ratz *)secondBody.node;
        if (theRatz.ratzStatus != SBRatzKicked) {
            if (theRatz.position.x < 100) {
                [theRatz wrapRatz:CGPointMake(self.frame.size.width-11, theRatz.position.y)];
            } else {
                [theRatz wrapRatz:CGPointMake(11, theRatz.position.y)];
            }
        } else {
            NSLog(@"%@ hit bottom of screen and is being removed", theRatz.name);
            [theRatz ratzHitWater:self];
            _activeEnemyCount--;
        }
    }

    // Coin / sideWalls
    if ((((firstBody.categoryBitMask & kWallCategory) != 0) &&
         ((secondBody.categoryBitMask & kCoinCategory) != 0))) {
        Coin *theCoin = (Coin *)secondBody.node;
        if (theCoin.position.x < 100) {
            [theCoin wrapCoin:CGPointMake(self.frame.size.width-6, theCoin.position.y)];
        } else {
            [theCoin wrapCoin:CGPointMake(6, theCoin.position.y)];
        }
    }

    // Ratz <> Ratz
    if ((((firstBody.categoryBitMask & kRatzCategory) != 0) &&
         ((secondBody.categoryBitMask & kRatzCategory) != 0))) {
        NSLog(@"Ratz and Ratz Collision!!!!!");

        Ratz *theFirstRatz = (Ratz *)firstBody.node;
        Ratz *theSecondRatz = (Ratz *)secondBody.node;

        // causes first Ratz to turn and change directions
        if (theFirstRatz.ratzStatus == RatzRunningLeft) {
            [theFirstRatz turnRight];
        } else if (theFirstRatz.ratzStatus == RatzRunningRight) {
            [theFirstRatz turnLeft];
        }

        // causes second Ratz to turn and change directions
        if (theSecondRatz.ratzStatus == RatzRunningLeft) {
        [theSecondRatz turnRight];
        } else if (theSecondRatz.ratzStatus == RatzRunningRight) {
            [theSecondRatz turnLeft];
        }
    }

    // Coin / Coin
    if ((((firstBody.categoryBitMask & kCoinCategory) != 0) &&
         ((secondBody.categoryBitMask & kCoinCategory) != 0))) {
        Coin *theFirstCoin = (Coin *)firstBody.node;
        Coin *theSecondCoin = (Coin *)secondBody.node;

        NSLog(@"coins collision ahh!!");

        // causes first Coin to turn and change directions
        if (theFirstCoin.coinStatus == CoinRunningLeft) {
            [theFirstCoin turnRight];
        } else if (theFirstCoin.coinStatus == CoinRunningRight) {
            [theFirstCoin turnLeft];
        }

        // causes second Coin to turn and change directions
        if (theSecondCoin.coinStatus == CoinRunningLeft) {
            [theSecondCoin turnRight];
        } else if (theSecondCoin.coinStatus == CoinRunningRight) {
            [theSecondCoin turnLeft];
        }

    }

    // Coin / Ratz
    if ((((firstBody.categoryBitMask & kCoinCategory) != 0) &&
         ((secondBody.categoryBitMask & kRatzCategory) != 0))) {
        Coin *theCoin = (Coin *)firstBody.node;

        Ratz *theRatz = (Ratz *)secondBody.node;

        NSLog(@"Coin Ratz Collision");

        // cause Coin to turn and change directions
        if (theCoin.coinStatus == CoinRunningLeft) {
            [theCoin turnRight];
        } else if (theCoin.coinStatus == CoinRunningRight) {
            [theCoin turnLeft];
        }

        // causes Ratz to turn and change directions
        if (theRatz.ratzStatus == RatzRunningLeft) {
            [theRatz turnRight];
        } else if (theRatz.ratzStatus == RatzRunningRight) {
            [theRatz turnLeft];
        }
    }

    // Pipe / Coin
    if ((((firstBody.categoryBitMask & kPipeCategory) != 0) &&
         ((secondBody.categoryBitMask & kCoinCategory) != 0))) {

        Coin *coin = (Coin *)secondBody.node;
        NSLog(@"Pipe Coin Collision");
        [coin coinHitPipe];
        _activeEnemyCount--;
    }


    // Pipe / Ratz
    if ((((firstBody.categoryBitMask & kPipeCategory) != 0) &&
         ((secondBody.categoryBitMask & kRatzCategory) != 0))) {

        Ratz *theRatz = (Ratz *)secondBody.node;

        NSLog(@"Pipe Ratz Collision");

        // causes Ratz to go up
        if (theRatz.position.x < 100) {
            [theRatz ratzHitLeftPipe:self];
        } else {
            [theRatz ratzHitRightPipe:self];
        }
    }

    // Player / Coin
    if ((((firstBody.categoryBitMask &kPlayerCategory) != 0) &&
         ((secondBody.categoryBitMask &kCoinCategory) != 0))) {
        Coin *theCoin = (Coin *)secondBody.node;
        [theCoin coinCollected:self];
        _activeEnemyCount--;

        // Score some bonus points
        _playerScore = _playerScore + kCoinPointValue;
        [_scoreDisplay updateScore:self newScore:_playerScore hiScore:_highScore];
    }

    // Player / Ledges
    if ((((firstBody.categoryBitMask &kPlayerCategory) != 0) &&
         ((secondBody.categoryBitMask &kLedgeCategory) != 0)))
    {
        if (_playerSprite.playerStatus == PlayerJumpingLeft || _playerSprite.playerStatus == PlayerJumpingRight || _playerSprite.playerStatus == PlayerJumpingUpFacingLeft || _playerSprite.playerStatus == PlayerJumpingUpFacingRight) {
            {
                SKSpriteNode *theStruckLedge = (SKSpriteNode *)secondBody.node;
                [self checkForEnemyHits:theStruckLedge.name];
            }
        }
    }

    // Coin / ledges
    if ((((firstBody.categoryBitMask &kLedgeCategory) != 0) &&
         ((secondBody.categoryBitMask &kCoinCategory) != 0))) {
        Coin *theCoin = (Coin *)secondBody.node;
        SKNode *theLedge = firstBody.node;
        theCoin.lastKnownContactedLedge = theLedge.name;
    }

    // Ratz / ledges
    if ((((firstBody.categoryBitMask &kLedgeCategory) != 0) &&
         ((secondBody.categoryBitMask &kRatzCategory) != 0))) {
        Ratz *theRatz = (Ratz *)secondBody.node;
        SKNode *theLedge = firstBody.node;
        theRatz.lastKnownContactedLedge = theLedge.name;
    }

    // Ratz / BaseBricks
    if ((((firstBody.categoryBitMask &kBaseCategory) != 0) &&
         ((secondBody.categoryBitMask &kRatzCategory) != 0))) {
        Ratz *theRatz = (Ratz *)secondBody.node;
        theRatz.lastKnownContactedLedge = @"";
    }

    // Ratz <> Player Collision
    if ((((firstBody.categoryBitMask &kPlayerCategory) != 0)
         &&((secondBody.categoryBitMask &kRatzCategory) != 0))) {
        Ratz *theRatz = (Ratz *)secondBody.node;
        if (_playerSprite.playerStatus != PlayerFalling) {
            if (theRatz.ratzStatus == RatzKOfacingLeft || // KNOCKED OUT
                theRatz.ratzStatus == RatzKOfacingRight) {
                [theRatz ratzCollected:self];
                _activeEnemyCount--;
            } else if (theRatz.ratzStatus == RatzRunningLeft ||
                       theRatz.ratzStatus == RatzRunningRight) {
                // oops, player dies
                [_playerSprite playerKilled:self];
                _playerLivesRemaining--;
                [self playerLivesDisplay];
            }
            _playerScore = _playerScore + kRatzPointValue;
            [_scoreDisplay updateScore:self newScore:_playerScore hiScore:_highScore];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    NSLog(@"%d %d %d\n", _spawnedEnemyCount, _activeEnemyCount, [_castTypeArray count]);
    if (_gameIsOverFlag) {

    } else if (_playerLivesRemaining == 0) {
        NSLog(@"GAME OVER");
        [self gameIsOver];

    } else if (_gameIsPaused) {
        // do nothing while paused

    } else if (_playerIsDeadFlag) { // one more life
        _playerIsDeadFlag = NO;
        SKAction *shortDelay = [SKAction waitForDuration:2];
        [self runAction:shortDelay completion:^{
            _playerSprite = [Player initNewPlayer:self startingPoint:CGPointMake(40, 25)];
            [_playerSprite spawnedInScene:self];
    }];

    } else if (_activeEnemyCount == 0 && _spawnedEnemyCount == [_castTypeArray count]) {
        [self levelCompleted];

    } else {
        if (!_enemyIsSpawningFlag &&_spawnedEnemyCount < 5) {
            _enemyIsSpawningFlag = YES;
            int castIndex = _spawnedEnemyCount;

            int leftSideX = CGRectGetMinX(self.frame)+kEnemySpawnEdgeBufferX;
            int rightSideX = CGRectGetMaxX(self.frame)-kEnemySpawnEdgeBufferX;
            int topSideY = CGRectGetMaxY(self.frame)-kEnemySpawnEdgeBufferY;

            // Sprite Type
            int castType = [[_castTypeArray objectAtIndex:castIndex] intValue];

            // Get the delay
            int castDelay = [[_castDelayArray objectAtIndex:castIndex] intValue];

            // from castOfCharacters file, the sprite startXindex
            int startX = 0;

            // the side where it will appear
            if ([[_castStartXindexArray objectAtIndex:castIndex] intValue] == 0) {
                startX = leftSideX;
            } else {
                startX = rightSideX;
            }

            int startY = topSideY;

            // begin delay & when completed spawn new enemy
            SKAction *spacing = [SKAction waitForDuration:castDelay ];

            [self runAction:spacing completion:^{
                // Create & spawn the new Enemy
                _enemyIsSpawningFlag = NO;
                _spawnedEnemyCount = _spawnedEnemyCount + 1;
                _activeEnemyCount++;

                if (castType == EnemyTypeCoin) {
                    Coin *newCoin = [Coin initNewCoin:self
                                        startingPoint:CGPointMake(startX,startY)
                                            coinIndex:castIndex];
                    [newCoin spawnedInScene:self];
                } else if (castType == EnemyTypeRatz) {
                    Ratz *newEnemy = [Ratz initNewRatz:self
                                         startingPoint:CGPointMake(startX, startY)
                                             ratzIndex:castIndex];
                    [newEnemy spawnedInScene:self];
                }
            }];
        }

        // check for stuck enemies every 20 frames
        _frameCounter = _frameCounter + 1;
        if (_frameCounter >=20) {
            _frameCounter = 0;

            // hmmmm?
            for (int index=0; index <= _spawnedEnemyCount; index++) {
                // Coins
                [self enumerateChildNodesWithName:[NSString stringWithFormat:@"coin%d", index]
                    usingBlock:^(SKNode *node, BOOL *stop) {
                        *stop = YES;
                        Coin *theCoin = (Coin *)node;
                        int currentX = theCoin.position.x;
                        int currentY = theCoin.position.y;

                        if (currentX == theCoin.lastKnownXposition&&currentY == theCoin.lastKnownYposition) {

                            NSLog(@"%@ appears to be stuck...", theCoin.name);

                            if (theCoin.coinStatus == CoinRunningRight) {
                               [theCoin removeAllActions];
                               [theCoin runLeft];
                            } else if (theCoin.coinStatus == CoinRunningLeft) {
                               [theCoin removeAllActions];
                               [theCoin runRight];
                            }
                        }
                        theCoin.lastKnownXposition = currentX;
                        theCoin.lastKnownYposition = currentY;
                    }
                 ];

                // Ratz
                [self enumerateChildNodesWithName:[NSString stringWithFormat:@"ratz%d", index]
                    usingBlock:^(SKNode *node, BOOL *stop) {
                        *stop = YES;
                        Ratz *theRatz = (Ratz *)node;
                        int currentX = theRatz.position.x;
                        int currentY = theRatz.position.y;

                        if (currentX == theRatz.lastKnownXposition&&currentY == theRatz.lastKnownYposition) {

                            NSLog(@"%@ appears to be stuck...", theRatz.name);
                            if (theRatz.ratzStatus == RatzRunningRight) {
                                [theRatz turnLeft];
                            } else if (theRatz.ratzStatus == RatzRunningLeft) {
                                [theRatz turnRight];
                            }
                        }
                        theRatz.lastKnownXposition = currentX;
                        theRatz.lastKnownYposition = currentY;
                    }
                ];
            }
        }
    }
}

@end
