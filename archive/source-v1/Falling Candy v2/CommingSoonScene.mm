//
//  CommingSoonScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CommingSoonScene.h"
#import "LevelsScene.h"
#import "HomeScene.h"
#import "SharedActions.h"


@implementation CommingSoonScene
@synthesize layer = _layer;

+ (CommingSoonScene *)scene
{
 	CommingSoonScene *scene = [[[CommingSoonScene alloc] init] autorelease];
	return scene;
}

- (void)dealloc
{
    NSLog(@"CommingSoon Dealloc");
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _layer = [CommingSoonLayer layer];
        [self addChild:_layer z:0];
    }
    return self;
}

@end



@implementation CommingSoonLayer


+ (void)loadResources
{

}


+ (CommingSoonLayer *)layer
{
	CommingSoonLayer *layer = [[[CommingSoonLayer alloc] init] autorelease];
	return layer;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        CCSprite *bg = [CCSprite spriteWithFile:@"cs-bg.png"];
        [bg setAnchorPoint:CGPointMake(0.5, 0)];
        [bg setPosition:CGPointMake(self.contentSize.width / 2, 0)];
        [self addChild:bg];

        CCSprite *good = [CCSprite spriteWithFile:@"cs-congratulations.png"];
        [good setAnchorPoint:CGPointMake(0.5, 1)];
        [good setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height + good.contentSize.height)];
        [self addChild:good z:10];

        CCSprite *basket = [CCSprite spriteWithFile:@"cs-basket.png"];
        [basket setAnchorPoint:CGPointMake(0.5, 0)];
        [basket setPosition:CGPointMake(self.contentSize.width / 2, 0)];
        [self addChild:basket z:4];


        // Character
        CCSprite *_characterSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-1.png"];
        [_characterSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [_characterSprite setPosition:CGPointMake(self.contentSize.width / 2, 34)];
        [self addChild:_characterSprite z:3];

        CCSprite *feetSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-kajas.png"];
        [feetSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [feetSprite setPosition:_characterSprite.position];
        [self addChild:feetSprite z:3];


        // Animate
        id cAni1 = [[SharedActions sharedActions] characterOpenMouth];
        id cAni2 = [[SharedActions sharedActions] characterEyeBlink];
        id cDelay1 = [CCDelayTime actionWithDuration:5];
        id cDelay2 = [CCDelayTime actionWithDuration:2];
        id cDelay3 = [CCDelayTime actionWithDuration:1];

        // Put it on the sequence
        id cSeq1 = [CCSequence actions:cDelay1, cAni1, cDelay2, [cAni1 reverse], cDelay3, cAni2, nil];
        id cRep1 = [CCRepeatForever actionWithAction:cSeq1];

        // Run those actions
        [_characterSprite runAction:cRep1];
        [_characterSprite runAction:[[SharedActions sharedActions] characterBored]];
        

        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            id cMov = [CCMoveTo actionWithDuration:1.0 position:CGPointMake(good.position.x, self.contentSize.height + (self.contentSize.height == 480 ? 40 : 0))];
            id cEase = [CCEaseBounceOut actionWithAction:cMov];
            id cFunc = [CCCallBlock actionWithBlock:^{
                CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"fireworks.plist"];
                [particle setPosition:CGPointMake(good.position.x, good.position.y - good.contentSize.height + 55)];
                [self addChild:particle z:5];
            }];
            id cSeq = [CCSequence actions:cEase, cFunc, nil];
            [good runAction:cSeq];
        });


        [self registerWithTouchDispatcher];

        [TestFlight passCheckpoint:@"Comming Soon Scene"];
    }
    return self;
}




- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    HomeScene *scene = [HomeScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:3.0 scene:scene withColor:ccWHITE]];
}



#pragma mark Touches

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{
#if COCOS2D_VERSION >= 0x00020000
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 1;
#else
    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
    int priority = kCCMenuTouchPriority - 1;
#endif

	[dispatcher addTargetedDelegate:self priority: priority swallowsTouches:NO];
}


@end
