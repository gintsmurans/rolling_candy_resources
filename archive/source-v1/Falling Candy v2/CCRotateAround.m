//
//  CCRotateAround.m
//  Falling Candy
//
//  Created by Gints Murans on 7/6/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCRotateAround.h"


//p'x = cos(theta) * (px-ox) - sin(theta) * (py-oy) + ox
//p'y = sin(theta) * (px-ox) + cos(theta) * (py-oy) + oy

@implementation CCRotateAroundTo

+(id) actionWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint
{
    return [[[self alloc] initWithDuration:t angle:a rotationPoint:rotationPoint] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint
{
    if( (self=[super initWithDuration: t angle: a]) )
    {
        rotationPoint_ =  rotationPoint;
        startAngle_ = a;
        diffAngle_ = a;
    }

    return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
    [super startWithTarget:aTarget];
    startPosition_ = [(CCNode*)_target position];
}

-(void) update: (ccTime) t
{

    CGFloat x = cos(CC_DEGREES_TO_RADIANS(-diffAngle_*t)) * ((startPosition_.x)-rotationPoint_.x) - sin(CC_DEGREES_TO_RADIANS(-diffAngle_*t)) * ((startPosition_.y)-rotationPoint_.y) + rotationPoint_.x;
    CGFloat y = sin(CC_DEGREES_TO_RADIANS(-diffAngle_*t)) * ((startPosition_.x)-rotationPoint_.x) + cos(CC_DEGREES_TO_RADIANS(-diffAngle_*t)) * ((startPosition_.y)-rotationPoint_.y) + rotationPoint_.y;

    [_target setPosition:ccp(x, y)];
    [_target setRotation: (startAngle_ + diffAngle_ * t )];
}

@end

@implementation CCRotateAroundBy

+(id) actionWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint
{
    return [[[self alloc] initWithDuration:t angle:a rotationPoint:rotationPoint] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint
{
    if( (self=[super initWithDuration: t angle: a]) )
    {
        rotationPoint_ =  rotationPoint;
        startAngle_ = a;
        angle_ = a;
    }

    return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
    [super startWithTarget:aTarget];
    startPosition_ = [(CCNode*)_target position];
}

-(void) update: (ccTime) t
{
    CGFloat x = cos(CC_DEGREES_TO_RADIANS(-angle_*t)) * ((startPosition_.x)-rotationPoint_.x) - sin(CC_DEGREES_TO_RADIANS(-angle_*t)) * ((startPosition_.y)-rotationPoint_.y) + rotationPoint_.x;
    CGFloat y = sin(CC_DEGREES_TO_RADIANS(-angle_*t)) * ((startPosition_.x)-rotationPoint_.x) + cos(CC_DEGREES_TO_RADIANS(-angle_*t)) * ((startPosition_.y)-rotationPoint_.y) + rotationPoint_.y;

    [_target setPosition:ccp(x, y)];
    [_target setRotation: (startAngle_ + angle_ * t )];
}

@end
