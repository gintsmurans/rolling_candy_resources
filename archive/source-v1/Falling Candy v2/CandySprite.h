//
//  GLPhysicsBody.h
//  Falling Candy
//
//  Created by Gints Murans on 3/27/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "CandySprite.h"

typedef void (^GenericBlock)();

@interface CandySubSprites : CCSprite
@property (nonatomic, assign) CGPoint direction;
@property (nonatomic, assign) float rotate;
@end


@interface CandySprite : CCSprite
{
    BOOL _toDestroy;
    int _inc;
}

@property (nonatomic, assign) b2Body *body;
@property (nonatomic, assign) b2Vec2 surfaceVelocity;

- (void)destroy;

@end