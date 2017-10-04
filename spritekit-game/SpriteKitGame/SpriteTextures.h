//
//  SpriteTextures.h
//  SpriteKitGame
//
//  Created by Fatima B on 11/24/15.
//
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#define playerRunRight1FileName @"Player_Right1.png"
#define playerRunRight2FileName @"Player_Right2.png"
#define playerRunRight3FileName @"Player_Right3.png"
#define playerRunRight4FileName @"Player_Right4.png"

#define playerRunLeft1FileName @"Player_Left1.png"
#define playerRunLeft2FileName @"Player_Left2.png"
#define playerRunLeft3FileName @"Player_Left3.png"
#define playerRunLeft4FileName @"Player_Left4.png"

#define playerStillFacingRightFileName @"Player_Left_Still.png"
#define playerStllFacingLeftFileName @"Player_Right_Still.png"

#define playerSkiddingRightFileName @"Player_RightSkid.png"
#define playerSkiddingLeftFileName @"Player_LeftSkid.png"

#define PlayerJumpLeftFileName @"Player_LeftJump.png"
#define PlayerJumpRightFileName @"Player_RightJump.png"

#define kRatzRunRight1FileName @"Ratz_Right1.png"
#define kRatzRunRight2FileName @"Ratz_Right2.png"
#define kRatzRunRight3FileName @"Ratz_Right3.png"
#define kRatzRunRight4FileName @"Ratz_Right4.png"
#define kRatzRunRight5FileName @"Ratz_Right5.png"

#define kRatzRunLeft1FileName @"Ratz_Left1.png"
#define kRatzRunLeft2FileName @"Ratz_Left2.png"
#define kRatzRunLeft3FileName @"Ratz_Left3.png"
#define kRatzRunLeft4FileName @"Ratz_Left4.png"
#define kRatzRunLeft5FileName @"Ratz_Left5.png"

#define kCoin1FileName @"Coin1.png"
#define kCoin2FileName @"Coin2.png"
#define kCoin3FileName @"Coin3.png"

#define kRatzKOfacingLeft1FileName @"Ratz_KO_L_Hit1.png"
#define kRatzKOfacingLeft2FileName @"Ratz_KO_L_Hit2.png"
#define kRatzKOfacingLeft3FileName @"Ratz_KO_L_Hit3.png"
#define kRatzKOfacingLeft4FileName @"Ratz_KO_L_Hit4.png"
#define kRatzKOfacingLeft5FileName @"Ratz_KO_L_Hit5.png"
#define kRatzKOfacingRight1FileName @"Ratz_KO_R_Hit1.png"
#define kRatzKOfacingRight2FileName @"Ratz_KO_R_Hit2.png"
#define kRatzKOfacingRight3FileName @"Ratz_KO_R_Hit3.png"
#define kRatzKOfacingRight4FileName @"Ratz_KO_R_Hit4.png"
#define kRatzKOfacingRight5FileName @"Ratz_KO_R_Hit5.png"

@interface SpriteTextures : NSObject

@property (nonatomic, strong) NSArray *playerRunRightTextures, *playerStillFacingRightTextures,
                                        *playerSkiddingLeftTextures, *playerJumpRightTextures;
@property (nonatomic, strong) NSArray *playerRunLeftTextures, *playerStillFacingLeftTextures,
                                        *playerSkiddingRightTextures, *playerJumpLeftTextures;
@property (nonatomic, strong) NSArray *ratzRunLeftTextures, *ratzRunRightTextures;

@property (nonatomic, strong) NSArray *coinTextures;

@property (nonatomic, strong) NSArray *ratzKOfacingLeftTextures, *ratzKOfacingRightTextures;

- (void)createAnimationTextures;

@end
