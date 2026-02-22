//
//  PauseScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "AnimatedCCMenuItemImage.h"


typedef void (^GenericBlock)();

@interface PauseLayer : CCLayer
{
    CCLayerColor *_effectLayer;
    CCMenu *_pauseMenuButtons;
    AnimatedCCMenuItemImage *_playButton;
    AnimatedCCMenuItemImage *_restartButton;
    AnimatedCCMenuItemImage *_menuButton;
    float _accelX;
}

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) AnimatedCCMenuItemImage *pauseButton;

+ (PauseLayer *)layer;
//+ (PauseLayer *)sharedPauseLayer;

- (void)pause:(GenericBlock)block;
- (void)resume:(GenericBlock)block;
- (void)hideMenu;
- (void)showMenu;
@end

