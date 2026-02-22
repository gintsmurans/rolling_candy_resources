//
//  GameBatchNode.m
//  Falling Candy
//
//  Created by Gints Murans on 7/7/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "GameBatchNode.h"
#import "PhysicsSprite.h"
#import "GameScene.h"
#import "Macros.h"

@implementation GameBatchNode


- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];

//    int total = 0, staticHits = 0, dynamicHits = 0;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    PhysicsSprite *sprite = nil;
    CCARRAY_FOREACH([self children], sprite)
    {
//        total += 1;
        // Skip 1
        if ([sprite isKindOfClass:[PhysicsSprite class]] == NO || sprite.body == nil || sprite.tag == TAG_CANDY)
        {
            continue;
        }

        // Skip 2
        if (sprite.position.y < -sprite.contentSize.height * 4 - self.position.y)
        {
            [sprite setVisible:NO];
            continue;
        }

        // Remove
        if (sprite.position.y > winSize.height - self.position.y + sprite.contentSize.height * 4)
        {
            [(GameLayer *)self.parent contactListener]->toDestroy.push_back(sprite.body);
            sprite.body->SetUserData(nil);
            [sprite setBody:nil];
            [sprite removeFromParentAndCleanup:YES];
            continue;
        }

        // Else set active physics body
        sprite.body->SetActive(YES);
        [sprite setVisible:YES];

        // Dynamic objects
        if (sprite.body->GetType() == b2_dynamicBody && sprite.tag != TAG_WHALE)
        {
            b2Vec2 pos = sprite.body->GetPosition();
            CGPoint cgPos = CGPointMake(pos.x * PTM_RATIO, pos.y * PTM_RATIO - self.position.y);
            [sprite setPosition:cgPos];

            float angle = sprite.body->GetAngle();
            [sprite setRotation:CC_RADIANS_TO_DEGREES(angle)];
//            dynamicHits += 1;
        }

        // Static and kinematic objects
        else
        {
            // Get new position
            b2Vec2 b2Position = b2Vec2(sprite.position.x / PTM_RATIO, (sprite.position.y + self.position.y) / PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);

            // Move body2, if any
            if (sprite.body2 != nil)
            {
                sprite.body2->SetTransform(b2Position, sprite.body2->GetAngle());

                b2Angle = sprite.body->GetAngle();
                [sprite setRotation:-1 * CC_RADIANS_TO_DEGREES(b2Angle)];
            }

            // Move body
            sprite.body->SetTransform(b2Position, b2Angle);
//            staticHits += 1;
        }
    }
}


- (void)setOpacity:(GLubyte)opacity
{
    CCNode *node = nil;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node respondsToSelector:@selector(setOpacity:)])
        {
            [(id<CCRGBAProtocol>)node setOpacity:opacity];
        }
    }
}

@end
