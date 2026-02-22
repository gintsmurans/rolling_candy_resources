//
//  LevelsScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLayer.h"

#import "cocos2d.h"
#import "Macros.h"
#import "CustomScrollLayer.h"
#import "AnimatedCCMenuItemImage.h"


@interface LevelsScene : CCScene
@property (nonatomic, retain) CCLayer *layer;
+ (LevelsScene *)scene;
@end


@interface LevelsLayer : CCLayer<CustomScrollLayerDelegate>
{
    CustomScrollLayer *_scrollLayer;
    CCSprite *_candy;
    CCSpriteBatchNode *_menuSheet;
    AnimatedCCMenuItemImage *_backButton;

    int _theme, _level;
    BOOL _shouldScroll, _levelsUnlocked;

    float _accelX;
}

@property (nonatomic, assign) BOOL preloading;

+ (void)loadResources;
+ (LevelsLayer *)layer;

@end
