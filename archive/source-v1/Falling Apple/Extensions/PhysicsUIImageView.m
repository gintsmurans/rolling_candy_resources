//
//  PhysicsUIImageView.m
//  Falling Candy
//
//  Created by Gints Murans on 2/11/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "PhysicsUIImageView.h"

@implementation PhysicsUIImageView
@synthesize score, animatingCustom, testFrame, originalTestSize, originalSize, stickiness, rotation, moveX, moveY, movingX, movingY;


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self setRotation:0];
        [self setStickiness:1];
        [self setAnimatingCustom:NO];

        [self setMoveX:0.0];
        [self setMoveY:0.0];
        [self setMovingX:0.0];
        [self setMovingY:0.0];
    }
    return self;
}

- (CGRect)testFrame
{
    CGRect frame;
    frame.origin = CGPointMake(self.frame.origin.x + testFrame.origin.x, self.frame.origin.y + testFrame.origin.y);
    frame.size = testFrame.size;
    return frame;
}

@end
