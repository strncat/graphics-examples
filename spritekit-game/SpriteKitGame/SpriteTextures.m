//
//  SpriteTextures.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/24/15.
//
//

#import "SpriteTextures.h"

@implementation SpriteTextures

- (void)createAnimationTextures
{
    // right running
    SKTexture *f1 = [SKTexture textureWithImageNamed: playerRunRight1FileName];
    SKTexture *f2 = [SKTexture textureWithImageNamed: playerRunRight2FileName];
    SKTexture *f3 = [SKTexture textureWithImageNamed: playerRunRight3FileName];
    SKTexture *f4 = [SKTexture textureWithImageNamed: playerRunRight4FileName];
    _playerRunRightTextures = @[f1,f2,f3,f4];

    // left running
    f1 = [SKTexture textureWithImageNamed: playerRunLeft1FileName];
    f2 = [SKTexture textureWithImageNamed: playerRunLeft2FileName];
    f3 = [SKTexture textureWithImageNamed: playerRunLeft3FileName];
    f4 = [SKTexture textureWithImageNamed: playerRunLeft4FileName];
    _playerRunLeftTextures = @[f1,f2,f3,f4];

    // Still Left
    f1 = [SKTexture textureWithImageNamed: playerStllFacingLeftFileName];
    _playerStillFacingLeftTextures = @[f1];

    // Still Right
    f1 = [SKTexture textureWithImageNamed: playerStillFacingRightFileName];
    _playerStillFacingRightTextures = @[f1];

    // Skidding Left
    f1 = [SKTexture textureWithImageNamed: playerSkiddingLeftFileName];
    _playerSkiddingLeftTextures = @[f1];

    // Skidding Right
    f1 = [SKTexture textureWithImageNamed: playerSkiddingRightFileName];
    _playerSkiddingRightTextures = @[f1];

    // Jump Left
    f1 = [SKTexture textureWithImageNamed:PlayerJumpLeftFileName];
    _playerJumpLeftTextures = @[f1];

    //   right, jumping
    f1 = [SKTexture textureWithImageNamed:PlayerJumpRightFileName];
    _playerJumpRightTextures = @[f1];

    // Ratz

    //  right, running
    f1 = [SKTexture textureWithImageNamed:kRatzRunRight1FileName];
    f2 = [SKTexture textureWithImageNamed:kRatzRunRight2FileName];
    f3 = [SKTexture textureWithImageNamed:kRatzRunRight3FileName];
    f4 = [SKTexture textureWithImageNamed:kRatzRunRight4FileName];
    SKTexture *f5 = [SKTexture textureWithImageNamed:kRatzRunRight5FileName];
    _ratzRunRightTextures = @[f1,f2,f3,f4,f5];

    //  left, running
    f1 = [SKTexture textureWithImageNamed:kRatzRunLeft1FileName];
    f2 = [SKTexture textureWithImageNamed:kRatzRunLeft2FileName];
    f3 = [SKTexture textureWithImageNamed:kRatzRunLeft3FileName];
    f4 = [SKTexture textureWithImageNamed:kRatzRunLeft4FileName];
    f5 = [SKTexture textureWithImageNamed:kRatzRunLeft5FileName];
    _ratzRunLeftTextures = @[f1,f2,f3,f4,f5];

    //  Coins
    f1 = [SKTexture textureWithImageNamed:kCoin1FileName];
    f2 = [SKTexture textureWithImageNamed:kCoin2FileName];
    f3 = [SKTexture textureWithImageNamed:kCoin3FileName];
    _coinTextures = @[f1,f2,f3,f2];

    // knocked out, facing left
    f1 = [SKTexture textureWithImageNamed:kRatzKOfacingLeft1FileName];
    f2 = [SKTexture textureWithImageNamed:kRatzKOfacingLeft2FileName];
    f3 = [SKTexture textureWithImageNamed:kRatzKOfacingLeft3FileName];
    f4 = [SKTexture textureWithImageNamed:kRatzKOfacingLeft4FileName];
    f5 = [SKTexture textureWithImageNamed:kRatzKOfacingLeft5FileName];

    _ratzKOfacingLeftTextures = @[f1,f2,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,
                                  f5,f5,f5,f5,f5,f5,f5,f3,f2,f3,f2,f3,f2,f1];

    // knocked out, facing right
    f1 = [SKTexture textureWithImageNamed:kRatzKOfacingRight1FileName];
    f2 = [SKTexture textureWithImageNamed:kRatzKOfacingRight2FileName];
    f3 = [SKTexture textureWithImageNamed:kRatzKOfacingRight3FileName];
    f4 = [SKTexture textureWithImageNamed:kRatzKOfacingRight4FileName];
    f5 = [SKTexture textureWithImageNamed:kRatzKOfacingRight5FileName];
    _ratzKOfacingRightTextures = @[f1,f2,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,f5,
                                   f5,f5,f5,f5,f5,f5,f5,f3,f2,f3,f2,f3,f2,f1];
}

@end
