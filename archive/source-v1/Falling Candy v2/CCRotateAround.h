//
//  CCRotateAround.h
//  Falling Candy
//
//  Created by Gints Murans on 7/6/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**  Rotates a CCNode object to a certain angle around
 a certain rotation point by modifying it's rotation
 attribute and position.
 The direction will be decided by the shortest angle.
 */
@interface CCRotateAroundTo : CCRotateTo {
    CGPoint rotationPoint_;
    CGPoint startPosition_;
    float diffAngle_;
    float startAngle_;
}

/** creates the action */
+(id) actionWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint;
/** initializes the action */
-(id) initWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint;

@end

/** Rotates a CCNode object clockwise around a certain
 rotation point a number of degrees by modiying its
 rotation attribute and position.
 */
@interface CCRotateAroundBy : CCRotateBy {
    CGPoint rotationPoint_;
    CGPoint startPosition_;
    float startAngle_;
    float angle_;
}

/** creates the action */
+(id) actionWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint;
/** initializes the action */
-(id) initWithDuration: (ccTime) t angle:(float) a rotationPoint:(CGPoint) rotationPoint;

@end
