//
//  HomeLayer.h
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//


#import "cocos2d.h"
#import "AnimatedCCMenuItemImage.h"

@interface HomeLayer : CCLayer
{
    CCSpriteBatchNode *_sheet;
    float _seconds;
    int _effectNr;
}

+ (HomeLayer *)layer;
+ (void)loadResources;
@end


@interface HomeScene : CCScene
@property (nonatomic, retain) HomeLayer *layer;
+ (HomeScene *)scene;
@end
