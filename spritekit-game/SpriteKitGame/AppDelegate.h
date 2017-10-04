//
//  AppDelegate.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/21/15.
//
//

#import <UIKit/UIKit.h>

#define kCastOfCharactersFileName @"CastOfCharacters"

static const uint32_t kPlayerCategory = 0x1 << 0;
static const uint32_t kBaseCategory = 0x1 << 1;
static const uint32_t kWallCategory = 0x1 << 2;
static const uint32_t kPipeCategory = 0x1 << 3;
static const uint32_t kLedgeCategory = 0x1 << 4;
static const uint32_t kCoinCategory = 0x1 << 5;
static const uint32_t kRatzCategory = 0x1 << 6;

#define kEnemySpawnEdgeBufferX 30
#define kEnemySpawnEdgeBufferY 30

typedef enum : uint8_t {
    EnemyTypeCoin = 0,
    EnemyTypeRatz
} EnemyTypes;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
