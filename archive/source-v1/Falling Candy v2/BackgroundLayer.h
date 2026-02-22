//
//  BackgroundLayer.h
//  Falling Candy
//
//  Created by Gints Murans on 4/22/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "CCParallaxSpriteBatchNode.h"

@interface BackgroundLayer : CCParallaxSpriteBatchNode
{
    CCParallaxNode *_parallax;
    CCSpriteBatchNode *_backgroundSheet;
    CCSprite *_backgroundSprite;
    float _seconds1, _seconds2, _seconds3;

    CCParallaxNode *_pTest;
}

+ (void)loadResources;
+ (BackgroundLayer *)layer;

@end
