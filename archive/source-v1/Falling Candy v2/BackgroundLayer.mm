//
//  BackgroundLayer.m
//  Falling Candy
//
//  Created by Gints Murans on 4/22/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "BackgroundLayer.h"
#import "Macros.h"

@implementation BackgroundLayer

+ (void)loadResources
{
    // Load shared sprite frame cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game-backgrounds.plist"];

    // Load textures
    [[CCTextureCache sharedTextureCache] addImage:@"game-backgrounds.pvr"];
}


+ (BackgroundLayer *)layer
{
    return [[[BackgroundLayer alloc] init] autorelease];
}


- (id)init
{
    if ((self = [super initWithFile:@"game-backgrounds.pvr" capacity:29]))
    {
        _seconds1 = _seconds2 = _seconds3 = 0.0;

        // Add background
        CGFloat multi = 0.3;
        _backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"bg.png"];
        [self setContentSize:_backgroundSprite.contentSize];
        CGPoint pos = CGPointMake(_backgroundSprite.contentSize.width / 2, _backgroundSprite.contentSize.height / 2);
        [self addChild:_backgroundSprite z:0 parallaxRatio:ccp(0.0f, multi) positionOffset:pos];


        multi = 0.5;
        CCSprite *s2 = [CCSprite spriteWithSpriteFrameName:@"hills.png"];
        pos = CGPointMake(_backgroundSprite.contentSize.width / 2, 1100 / 2 * multi);
        [self addChild:s2 z:2 parallaxRatio:ccp(0.0f, multi) positionOffset:pos];


        multi = 0.7;
        CCSprite *s1 = [CCSprite spriteWithSpriteFrameName:@"hills2.png"];
        pos = CGPointMake(rToRight(s1.contentSize.width, _backgroundSprite.contentSize.width), 1020 / 2 * multi);
        [self addChild:s1 z:4 parallaxRatio:ccp(0.0f, multi) positionOffset:pos];


        multi = 0.8;
        CCSprite *s4 = [CCSprite spriteWithSpriteFrameName:@"hills3.png"];
        pos = CGPointMake(rToRight(s4.contentSize.width, _backgroundSprite.contentSize.width), 800 / 2 * multi);
        [self addChild:s4 z:6 parallaxRatio:ccp(0.0f, multi) positionOffset:pos];


        multi = 1.0;
        CCSprite *s0 = [CCSprite spriteWithSpriteFrameName:@"front.png"];
        pos = CGPointMake(s0.contentSize.width / 2, s0.contentSize.height / 2 * multi);
        [self addChild:s0 z:8 parallaxRatio:ccp(0.0f, multi) positionOffset:pos];


        // Add some clouds
        [self update:500];


        // Schedule updates
        [self scheduleUpdate];
    }
    return self;
}


- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    if (contentSize.height >= _backgroundSprite.contentSize.height)
    {
        [_backgroundSprite setScaleY:(contentSize.height) / _backgroundSprite.contentSize.height];
        [_backgroundSprite setPosition:CGPointMake(_backgroundSprite.position.x, contentSize.height / 2)];
    }
}


- (void)update:(ccTime)dt
{
    _seconds1 += dt;
    _seconds2 += dt;
    _seconds3 += dt;

    int min = 1280 / 2;
    int max = _backgroundSprite.contentSize.height * _backgroundSprite.scaleY;
    if (_seconds1 >= 5.0 && fabs(self.position.y) > min)
    {
        _seconds1 = 0.0;
        int random = (arc4random() % (max - min + 1)) + min;
        int cloundNr = (arc4random() % (3 - 1 + 1)) + 1;
        int cloudSpeed = 50;

        CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"cloud3%d.png", cloundNr]];
        [cloud setPosition:CGPointMake(-cloud.contentSize.width / 2, random)];
        [self addChild:cloud z:1];

        id cMov = [CCMoveTo actionWithDuration:cloudSpeed position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2, cloud.position.y)];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [cloud removeFromParentAndCleanup:YES];
        }];
        [cloud runAction:[CCSequence actions:cMov, cFunc, nil]];
    }


    min = 1050 / 2;
    max = 1700 / 2;
    if (_seconds2 >= 7 && fabs(self.position.y) > min)
    {
        _seconds2 = 0.0;
        int random = (arc4random() % (max - min + 1)) + min;
        int cloundNr = (arc4random() % (3 - 1 + 1)) + 1;
        int cloudSpeed = 40;

        CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"cloud2%d.png", cloundNr]];
        [cloud setPosition:CGPointMake(-cloud.contentSize.width / 2, random)];
        [self addChild:cloud z:3];

        id cMov = [CCMoveTo actionWithDuration:cloudSpeed position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2, cloud.position.y)];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [cloud removeFromParentAndCleanup:YES];
        }];
        [cloud runAction:[CCSequence actions:cMov, cFunc, nil]];
    }


    min = 872 / 2;
    max = 1200 / 2;
    if (_seconds3 >= 15 && fabs(self.position.y) > min)
    {
        _seconds3 = 0.0;
        int random = (arc4random() % (max - min + 1)) + min;
        int cloundNr = (arc4random() % (1 - 1 + 1)) + 1;
        int cloudSpeed = 30;

        CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"cloud1%d.png", cloundNr]];
        [cloud setPosition:CGPointMake(-cloud.contentSize.width / 2, random)];
        [self addChild:cloud z:5];

        id cMov = [CCMoveTo actionWithDuration:cloudSpeed position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2, cloud.position.y)];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [cloud removeFromParentAndCleanup:YES];
        }];
        [cloud runAction:[CCSequence actions:cMov, cFunc, nil]];

        id scale0 = [CCScaleTo actionWithDuration:0.8 scaleX:1.0 scaleY:1.0];
        id scale1 = [CCScaleTo actionWithDuration:1.0 scaleX:1.1 scaleY:0.9];
        id scale2 = [CCScaleTo actionWithDuration:1.0 scaleX:0.9 scaleY:1.1];

        CCSequence *sequence = [CCSequence actions:scale1, scale2, scale0, nil];
        [cloud runAction:[CCRepeatForever actionWithAction:sequence]];
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
