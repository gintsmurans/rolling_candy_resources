//
//  CCBrickSprite.h
//  Falling Candy
//
//  Created by Gints Murans on 4/29/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
#import "PhysicsSprite.h"

@interface BrickSubSprites : CCSprite
@property (nonatomic, assign) CGPoint direction;
@property (nonatomic, assign) float rotate;
@end


@interface Brick4Sprite : PhysicsSprite
{
    int _inc;
}
- (Brick4Sprite *)initWithSpriteFrameNames:(NSString *)firstName, ... NS_REQUIRES_NIL_TERMINATION;
- (void)hitIt;
@end
