//
//  MainGameScene.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/23/15.
//
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"
#import "AppDelegate.h"
#import "Ratz.h"
#import "Scores.h"

#define kEnemySpawnEdgeBufferX 60
#define kEnemySpawnEdgeBufferY 60
#define kNumberOfLevelsMax 2
#define kPlayerLivesMax 3
#define kPlayerLivesSpacing 10

@interface MainGameScene : SKScene <SKPhysicsContactDelegate> // handling contacts and collisions

@property (strong, nonatomic) Player *playerSprite;
@property (strong, nonatomic) SpriteTextures *spriteTextures;
@property int spawnedEnemyCount, activeEnemyCount;
@property BOOL enemyIsSpawningFlag;
@property (strong, nonatomic) NSArray *castTypeArray, *castDelayArray, *castStartXindexArray;
@property (nonatomic, strong) Scores *scoreDisplay;

@property int playerScore, highScore;
@property int frameCounter;

@property BOOL playerIsDeadFlag;
@property int playerLivesRemaining;
@property BOOL gameIsOverFlag, gameIsPaused;
@property int currentLevel;

@end
