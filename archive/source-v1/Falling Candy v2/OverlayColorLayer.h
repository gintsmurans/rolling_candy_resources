//
//  OverlayColorLayer.h
//  Falling Candy
//
//  Created by Gints Murans on 8/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"

@interface OverlayColorLayer : CCLayerColor
@property (nonatomic, copy) void(^touchUpBlock)(void);
@end
