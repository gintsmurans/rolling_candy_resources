//
//  SettingsScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "AnimatedCCMenuItemImage.h"


@interface SettingsLayer : CCLayer
{
    AnimatedCCMenuItemImage *_backButton;
    float _accelX;
}

+ (SettingsLayer *)layer;
+ (void)loadResources;
@end


@interface SettingsScene : CCScene
@property (nonatomic, retain) SettingsLayer *layer;
+ (SettingsScene *)scene;
@end
