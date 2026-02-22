//
//  GLPhysicsBody.h
//  Falling Candy
//
//  Created by Gints Murans on 3/27/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

@interface PhysicsSprite : CCSprite

@property (nonatomic, assign) b2Body *body;
@property (nonatomic, assign) b2Body *body2;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int spriteId;
@property (nonatomic, assign, getter = isPhysicsSprite) BOOL physicsSprite;
@property (nonatomic, assign) int customVariable1;

@end
