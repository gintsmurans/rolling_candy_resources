//
//  PauseScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "PauseLayer.h"
#import "SharedActions.h"
#import "LevelsScene.h"
#import "LoaderLayer.h"
#import "GameScene.h"


@implementation PauseLayer
@synthesize pauseButton = _pauseButton;


+ (PauseLayer *)layer
{
	PauseLayer *layer = [[[PauseLayer alloc] init] autorelease];
	return layer;
}


//+ (PauseLayer *)sharedPauseLayer
//{
//    static dispatch_once_t once;
//    static PauseLayer *sharedInstance;
//    dispatch_once(&once, ^{
//        sharedInstance = [[PauseLayer layer] retain];
//    });
//    return sharedInstance;
//}


- (id)init
{
    if ((self = [super init]))
    {
        _effectLayer = [CCLayerColor layerWithColor:ccc4(50, 50, 50, 255)];
        // [_effectLayer setBlendFunc:(ccBlendFunc){GL_ZERO, GL_ONE}];
        [_effectLayer setOpacity:0];
        [self addChild:_effectLayer z:0];



        // Pause
        _pauseButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"go-pause.png"] selectedSprite:nil target:self selector:@selector(pause:)];
        [_pauseButton setButtonSound:@"buttons.m4a"];
        [_pauseButton setAnchorPoint:CGPointMake(0.5, 1)];
        [_pauseButton setPosition:ccp(self.contentSize.width - _pauseButton.contentSize.width / 2 - 10, self.contentSize.height + 40)];

        // Menu
        _menuButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"go-menu.png"] selectedSprite:nil block:^(id sender) {
            [self hideWithOverlay:NO withCallbackBlock:^{
                [[CCDirector sharedDirector] replaceScene:[LevelsScene scene]];

//                [[LoaderLayer sharedLoaderLayer] showWithScene:scene withLoadingBlock:^{
//                    [scene.layer loadLayer];
//                } withCallbackBlock:^{
//                    [scene.layer startLayer];
//                }];
            }];
        }];
        [_menuButton setButtonSound:@"buttons.m4a"];
        [_menuButton setAnchorPoint:CGPointMake(0.5, 1)];
        [_menuButton setPosition:ccp(self.contentSize.width / 2, self.contentSize.height + _menuButton.contentSize.height + 40)];

        // Play
        _playButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"go-play.png"] selectedSprite:nil block:^(id sender) {
            [self resume:nil];
        }];
        [_playButton setButtonSound:@"buttons.m4a"];
        [_playButton setAnchorPoint:CGPointMake(0.5, 1)];
        [_playButton setPosition:ccp(_menuButton.position.x + _menuButton.contentSize.width / 2 + _playButton.contentSize.width / 2, self.contentSize.height + _playButton.contentSize.height + 40)];

        // Restart
        _restartButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"go-restart.png"] selectedSprite:nil block:^(id sender) {
            [self hideWithOverlay:NO withCallbackBlock:^{
                [self.parent restartGame];
            }];
        }];
        [_restartButton setButtonSound:@"buttons.m4a"];
        [_restartButton setAnchorPoint:CGPointMake(0.5, 1)];
        [_restartButton setPosition:ccp(_menuButton.position.x - _menuButton.contentSize.width / 2 - _playButton.contentSize.width / 2 - 4, self.contentSize.height + _restartButton.contentSize.height + 40)];


        // Add menu
        _pauseMenuButtons = [CCMenu menuWithItems:_pauseButton, _playButton, _restartButton, _menuButton, nil];
        [_pauseMenuButtons setPosition:CGPointZero];
        [self addChild:_pauseMenuButtons z:1];
    }
    return self;
}


- (void)dealloc
{
    NSLog(@"PauseLayer Dealloc");
    [super dealloc];
}


- (void)pause:(GenericBlock)block
{
    // Stop the game
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.parent unscheduleUpdate];
    [self.parent setAccelerometerEnabled:NO];

    // Schedule pause layer for updates (moving buttons stuff)
    [self scheduleUpdate];
    [self setAccelerometerEnabled:YES];

    // Fade in our effects view
    id cFad = [CCFadeTo actionWithDuration:0.4 opacity:150];
    [_effectLayer runAction:cFad];


    // Move buttons around
    id cMov1 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(_pauseButton.position.x, self.contentSize.height)];
    id cMov2 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(_pauseButton.position.x, self.contentSize.height + _pauseButton.contentSize.height)];
    id cFunc = [CCCallBlock actionWithBlock:^{
        AnimatedCCMenuItemImage *item = nil;
        CCARRAY_FOREACH(_pauseMenuButtons.children, item)
        {
            if ([item isEqual:_pauseButton])
            {
                continue;
            }

            id cMov = [CCMoveTo actionWithDuration:0.4 position:CGPointMake(item.position.x, self.contentSize.height + 40)];
            id cBounce = [CCEaseBounceOut actionWithAction:cMov];
            [item runAction:cBounce];
        }
    }];
    id cSeq = [CCSequence actions:cMov1, cMov2, cFunc, nil];
    [_pauseButton runAction:cSeq];
}


- (void)hideWithOverlay:(BOOL)overlay withCallbackBlock:(GenericBlock)callbackblock
{
    // Fade out our effects view
    if (overlay == YES)
    {
        id cFad = [CCFadeTo actionWithDuration:0.3 opacity:0];
        [_effectLayer runAction:cFad];
    }

    // Move buttons around
    AnimatedCCMenuItemImage *item = nil;
    CCARRAY_FOREACH(_pauseMenuButtons.children, item)
    {
        if ([item isEqual:_pauseButton])
        {
            continue;
        }

        id cMov = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(item.position.x, self.contentSize.height + item.contentSize.height)];
        [item runAction:cMov];
    }

    if (callbackblock != nil)
    {
        id cDelay = [CCDelayTime actionWithDuration:0.2];
        id cFunc = [CCCallBlock actionWithBlock:callbackblock];
        [self runAction:[CCSequence actions:cDelay, cFunc, nil]];
    }
}


- (void)resume:(GenericBlock)block
{
    // Hide the menu first
    [self hideWithOverlay:YES withCallbackBlock:^{
        id cMov = [CCMoveTo actionWithDuration:0.4 position:CGPointMake(_pauseButton.position.x, self.contentSize.height + 40)];
        id cBounce = [CCEaseBounceOut actionWithAction:cMov];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [self setAccelerometerEnabled:NO];
            [self unscheduleUpdate];

            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [self.parent scheduleUpdate];
            [self.parent setAccelerometerEnabled:YES];

            if (block != nil)
            {
                block();
            }
        }];
        id cSeq = [CCSequence actions:cBounce, cFunc, nil];
        [_pauseButton runAction:cSeq];
    }];
}


- (void)hideMenu
{
    id cMov4 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(self.position.x, self.position.y + _pauseButton.contentSize.height)];
    [self runAction:cMov4];

}

- (void)showMenu
{
    id cMov4 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(self.position.x, 0)];
    [self runAction:cMov4];

}



- (void)update:(ccTime)dt
{
    AnimatedCCMenuItemImage *item = nil;
    CCARRAY_FOREACH(_pauseMenuButtons.children, item)
    {
        if ([item isEqual:_pauseButton])
        {
            continue;
        }
        [item setRotation:-30 * _accelX];
    }
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    _accelX = (acceleration.x * 0.05) + (_accelX * (1.0 - 0.05));
}

@end
