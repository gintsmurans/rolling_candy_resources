//
//  GLPhysicsBody.m
//  Falling Candy
//
//  Created by Gints Murans on 3/27/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CandySprite.h"
#import "Macros.h"


@implementation CandySubSprites
@synthesize direction = _direction, rotate = _rotate;
@end


#pragma mark - PhysicsSprite
@implementation CandySprite


- (BOOL)dirty
{
	return YES;
}



- (CGPoint)position
{
    b2Vec2 pos  = _body->GetPosition();
    float x = pos.x * PTM_RATIO;
    float y = pos.y * PTM_RATIO - self.parent.position.y;
    return ccp(x,y);
}

- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];

    if (_body != nil)
    {
        float angle = _body->GetAngle();
        _body->SetTransform(b2Vec2(position.x / PTM_RATIO, (position.y - self.parent.position.y) / PTM_RATIO), angle);
    }
}



- (float)rotation
{
	return CC_RADIANS_TO_DEGREES(_body->GetAngle());
}

- (void)setRotation:(float)rotation
{
    [super setRotation:rotation];

    b2Vec2 p = _body->GetPosition();
    _body->SetTransform(p, CC_DEGREES_TO_RADIANS(rotation));
}

- (void)setRotationX:(float)rotationX
{
    [super setRotationX:rotationX];

    b2Vec2 p = _body->GetPosition();
    _body->SetTransform(p, CC_DEGREES_TO_RADIANS(rotationX));
}

- (void)setRotationY:(float)rotationY
{
    [super setRotationY:rotationY];

    b2Vec2 p = _body->GetPosition();
    _body->SetTransform(p, CC_DEGREES_TO_RADIANS(rotationY));
}



// returns the transform matrix according the box2d body values
- (CGAffineTransform)nodeToParentTransform
{
	b2Vec2 pos  = _body->GetPosition();

	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO - self.parent.position.y;

	if ( _ignoreAnchorPointForPosition ) {
		x += _anchorPointInPoints.x;
		y += _anchorPointInPoints.y;
	}

	// Make matrix
	float radians = _body->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);

	// Although scale is not used by physics engines, it is calculated just in case
	// the sprite is animated (scaled up/down) using actions.
	// For more info see: http://www.cocos2d-iphone.org/forum/topic/68990
	if( ! CGPointEqualToPoint(_anchorPointInPoints, CGPointZero) ){
		x += c*-_anchorPointInPoints.x * _scaleX + -s*-_anchorPointInPoints.y * _scaleY;
		y += s*-_anchorPointInPoints.x * _scaleX + c*-_anchorPointInPoints.y * _scaleY;
	}

	// Rot, Translate Matrix
	_transform = CGAffineTransformMake( c * _scaleX,	s * _scaleX,
									   -s * _scaleY,	c * _scaleY,
									   x,	y );

	return _transform;
}


- (void)destroy
{
    // Update display frame
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"candy-1.png"]];

    // Add other parts
    for (int i = 2; i <= 5; ++i)
    {
        CandySubSprites *sprite = [CandySubSprites spriteWithSpriteFrameName:[NSString stringWithFormat:@"candy-%d.png", i]];
        [sprite setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
        [self addChild:sprite];
    }
}


- (void)setOpacity:(GLubyte)opacity
{
    [super setOpacity:opacity];
    CCNode *node = nil;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node respondsToSelector:@selector(setOpacity:)])
        {
            [(id<CCRGBAProtocol>)node setOpacity:opacity];
        }
    }
}

@end