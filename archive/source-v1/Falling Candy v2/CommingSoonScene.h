//
//  CommingSoonScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"


@interface CommingSoonLayer : CCLayer
{
}

+ (CommingSoonLayer *)layer;
+ (void)loadResources;
@end


@interface CommingSoonScene : CCScene
@property (nonatomic, retain) CommingSoonLayer *layer;
+ (CommingSoonScene *)scene;
@end
