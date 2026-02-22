//
//  CCParallaxSpriteBatchNode.m
//  Falling Candy
//
//  Created by Gints Murans on 6/18/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCParallaxSpriteBatchNode.h"
#import "cocos2d.h"


@interface CGPointObjectCustom : NSObject
{
	CGPoint	ratio_;
	CGPoint offset_;
	CCNode *child_;	// weak ref
}
@property (nonatomic,readwrite) CGPoint ratio;
@property (nonatomic,readwrite) CGPoint offset;
@property (nonatomic,readwrite,assign) CCNode *child;
@property (nonatomic,readwrite,assign, getter = isParallex) BOOL parallex;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end
@implementation CGPointObjectCustom
@synthesize ratio = ratio_;
@synthesize offset = offset_;
@synthesize child=child_;
@synthesize parallex = _parallex;

+(id) pointWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	return [[[self alloc] initWithCGPoint:ratio offset:offset] autorelease];
}
-(id) initWithCGPoint:(CGPoint)ratio offset:(CGPoint)offset
{
	if( (self=[super init])) {
		ratio_ = ratio;
		offset_ = offset;
	}
	return self;
}
@end



@implementation CCParallaxSpriteBatchNode
@synthesize parallaxArray = parallaxArray_;


-(id) initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	if( (self=[super initWithFile:fileImage capacity:capacity]) ) {
		parallaxArray_ = ccArrayNew(5);
		lastPosition = CGPointMake(-100,-100);
	}
	return self;
}

- (void) dealloc
{
	if( parallaxArray_ ) {
		ccArrayFree(parallaxArray_);
		parallaxArray_ = nil;
	}
	[super dealloc];
}

-(void) addChild:(CCNode*)child z:(NSInteger)z tag:(NSInteger)tag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObjectCustom *obj = [CGPointObjectCustom pointWithCGPoint:CGPointZero offset:CGPointZero];
	obj.child = child;
    obj.parallex = NO;
	ccArrayAppendObjectWithResize(parallaxArray_, obj);

	[super addChild:child z:z tag:child.tag];
}

-(void) addChild: (CCNode*) child z:(NSInteger)z parallaxRatio:(CGPoint)ratio positionOffset:(CGPoint)offset
{
	NSAssert( child != nil, @"Argument must be non-nil");
	CGPointObjectCustom *obj = [CGPointObjectCustom pointWithCGPoint:ratio offset:offset];
	obj.child = child;
    obj.parallex = YES;
	ccArrayAppendObjectWithResize(parallaxArray_, obj);

	CGPoint pos = self.position;
	pos.x = pos.x * ratio.x + offset.x;
	pos.y = pos.y * ratio.y + offset.y;
	child.position = pos;

	[super addChild: child z:z tag:child.tag];
}

-(void)removeChild:(CCSprite *)node cleanup:(BOOL)cleanup
{
	for( unsigned int i=0;i < parallaxArray_->num;i++) {
		CGPointObjectCustom *point = parallaxArray_->arr[i];
		if( [point.child isEqual:node] ) {
			ccArrayRemoveObjectAtIndex(parallaxArray_, i);
			break;
		}
	}
	[super removeChild:node cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	ccArrayRemoveAllObjects(parallaxArray_);
	[super removeAllChildrenWithCleanup:cleanup];
}

-(CGPoint) absolutePosition_
{
	CGPoint ret = _position;

	CCNode *cn = self;

	while (cn.parent != nil) {
		cn = cn.parent;
		ret = ccpAdd( ret,  cn.position );
	}

	return ret;
}

/*
 The positions are updated at visit because:
 - using a timer is not guaranteed that it will called after all the positions were updated
 - overriding "draw" will only be precise if the children have a z > 0
 */
-(void) visit
{
    //	CGPoint pos = position_;
    //	CGPoint	pos = [self convertToWorldSpace:CGPointZero];
	CGPoint pos = [self absolutePosition_];
	if( ! CGPointEqualToPoint(pos, lastPosition) )
    {
		for(unsigned int i=0; i < parallaxArray_->num; i++ )
        {
			CGPointObjectCustom *point = parallaxArray_->arr[i];
            if (point.isParallex == NO)
            {
                continue;
            }

			float x = -pos.x + pos.x * point.ratio.x + point.offset.x;
			float y = -pos.y + pos.y * point.ratio.y + point.offset.y;
			point.child.position = CGPointMake(x,y);
		}
        
		lastPosition = pos;
	}
    
	[super visit];
}


@end
