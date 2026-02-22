//
//  CCMoveByXY.m
//  Falling Candy
//
//  Created by Gints Murans on 6/26/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCMoveByXY.h"

@implementation CCMoveByXY
@synthesize moveY;

-(void) update: (ccTime) t
{
    if (self.moveY == YES)
    {
        [_target setPosition: CGPointMake([_target position].x, (_previousPos.y + _positionDelta.y * t))];
    }
    else
    {
        [_target setPosition:CGPointMake((_previousPos.x + _positionDelta.x * t ), [_target position].y)];
    }
}

@end
