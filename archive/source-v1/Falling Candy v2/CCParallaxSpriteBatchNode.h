//
//  CCParallaxSpriteBatchNode.h
//  Falling Candy
//
//  Created by Gints Murans on 6/18/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCSpriteBatchNode.h"

@interface CCParallaxSpriteBatchNode : CCSpriteBatchNode
{
	ccArray				*parallaxArray_;
	CGPoint				lastPosition;
}

/** array that holds the offset / ratio of the children */
@property (nonatomic,readwrite) ccArray * parallaxArray;

/** Adds a child to the container with a z-order, a parallax ratio and a position offset
 It returns self, so you can chain several addChilds.
 @since v0.8
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z parallaxRatio:(CGPoint)c positionOffset:(CGPoint)positionOffset;

@end
