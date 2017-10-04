//
//  Ledge.m
//  SpriteKitGame
//
//  Created by Fatima B on 11/25/15.
//
//

#import "Ledge.h"

@implementation  Ledge

- (void)createNewSetOfLedgeNodes:(SKScene *)whichScene startingPoint:(CGPoint)leftSide withHowManyBlocks:(int)blockCount startingIndex:(int)indexStart
{
    // ledge nodes
    SKTexture *ledgeBrickTexture = [SKTexture textureWithImageNamed:kLedgeBrickFileName];

    NSMutableArray *nodeArray = [[NSMutableArray alloc] initWithCapacity:blockCount-1];
    CGPoint where = leftSide;

    // nodes, equally spaced
    for (int index=0; index < blockCount; index++) {

        // make a brick node
        SKSpriteNode *theNode = [SKSpriteNode spriteNodeWithTexture:ledgeBrickTexture];
        theNode.name = [NSString stringWithFormat:@"ledgeBrick%d", indexStart+index];
        theNode.position = where;
        theNode.anchorPoint = CGPointMake(0.5,0.5);
        where.x += kLedgeBrickSpacing;

        // physics for the brick node
        theNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:theNode.size];
        theNode.physicsBody.categoryBitMask = kLedgeCategory; // ledge mask
        theNode.physicsBody.affectedByGravity = NO; // no gravity
        theNode.physicsBody.linearDamping = 1.0; // reduces the body’s linear velocity
        theNode.physicsBody.angularDamping = 1.0; // reduces the body’s rotational velocity

        // first and last brick will stay solid
        if (index == 0 || index == (blockCount-1)) {
            theNode.physicsBody.dynamic = NO; // not moved by the physics simulation
        } else {
            theNode.physicsBody.dynamic = YES;
        }

        [nodeArray insertObject:theNode atIndex:index];
        [whichScene addChild:theNode];
    }

    // joints between nodes
    for (int index=0; index <= (blockCount-2); index++) {
        SKSpriteNode *nodeA = [nodeArray objectAtIndex:index];
        SKSpriteNode *nodeB = [nodeArray objectAtIndex:index+1];

        // An SKPhysicsJointPin object allows two physics bodies to independently rotate
        // around the anchor point as if pinned together. You can configure how far
        // the two objects may rotate and the resistance to rotation.

        SKPhysicsJointPin *theJoint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody bodyB:nodeB.physicsBody anchor:CGPointMake(nodeB.position.x, nodeB.position.y)];
        theJoint.frictionTorque = 1.0;
        theJoint.shouldEnableLimits = YES;
        theJoint.lowerAngleLimit = 0.0000;
        theJoint.upperAngleLimit = 0.0000;
        [whichScene.physicsWorld addJoint:theJoint];
    }
}

@end
