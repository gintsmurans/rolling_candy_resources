//
//  CustomScrollLayer.m
//
//  Copyright 2010 DK101
//  http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
//
//  Copyright 2010 Giv Parvaneh.
//  http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
//
//  Copyright 2011-2012 Stepan Generalov
//  Copyright 2011 Jeff Keeme
//  Copyright 2011 Brian Feller
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "CustomScrollLayer.h"
#import "CCGL.h"

enum
{
	kCustomScrollLayerStateIdle,
	kCustomScrollLayerStateSliding,
};

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (id<NSFastEnumeration>) targetedHandlers
{
	return targetedHandlers;
}

@end
#endif


@implementation CustomScrollLayer

@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize stealTouches = _stealTouches;
@synthesize delegate = _delegate;



+ (id)node
{
    return [[[self alloc] init] autorelease];
}



- (id)init
{
    if ((self = [super init]))
    {
		[self setTouchEnabled:YES];
		[self setStealTouches:YES];
		[self setMinimumTouchLengthToSlide:5.0f];
		_screenSize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}


- (void)dealloc
{
    [_time release];
    [super dealloc];
}


#pragma mark Touches

/** Register with more priority than CCMenu's but don't swallow touches. */
-(void) registerWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 2;
	[dispatcher addTargetedDelegate:self priority:priority swallowsTouches:NO];
}



/** Hackish stuff - stole touches from other CCTouchDispatcher targeted delegates.
 Used to claim touch without receiving ccTouchBegan. */
- (void) claimTouch: (UITouch *) aTouch
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];

	// Enumerate through all targeted handlers.
	for ( CCTargetedTouchHandler *handler in [dispatcher targetedHandlers] )
	{
		// Only our handler should claim the touch.
		if (handler.delegate == self)
		{
			if (![handler.claimedTouches containsObject: aTouch])
			{
				[handler.claimedTouches addObject: aTouch];
			}
		}
        else
        {
            // Steal touch from other targeted delegates, if they claimed it.
            if ([handler.claimedTouches containsObject: aTouch])
            {
                if ([handler.delegate respondsToSelector:@selector(ccTouchCancelled:withEvent:)])
                {
                    [handler.delegate ccTouchCancelled: aTouch withEvent: nil];
                }
                [handler.claimedTouches removeObject: aTouch];
            }
        }
	}
}


- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(scrolling)])
    {
        [self.delegate scrolling];
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (_scrollTouch == nil)
    {
		_scrollTouch = touch;
	}
    else
    {
		return NO;
	}

	CGPoint touchPoint = [touch locationInView:[touch view]];
    _originalPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	_originalPositon = self.position;
	_state = kCustomScrollLayerStateIdle;
    [_time release], _time = [[NSDate date] retain];
	return YES;
}



- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (_scrollTouch != touch)
    {
		return;
	}

	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

	if ((_state != kCustomScrollLayerStateSliding) && (fabsf(touchPoint.y - _originalPositon.y) >= self.minimumTouchLengthToSlide))
	{
        [self stopAllActions];
		_state = kCustomScrollLayerStateSliding;

		if (self.stealTouches)
        {
			[self claimTouch:touch];
        }
	}

	if (_state == kCustomScrollLayerStateSliding)
	{
        float y = _originalPositon.y - (_originalPoint.y - touchPoint.y);
        if (y < _screenSize.height)
        {
            y = _screenSize.height;
            // _originalPoint = touchPoint;
        }
        else if (y > self.contentSize.height)
        {
            y = self.contentSize.height;
        }
		self.position = ccp(self.position.x, y);
	}
}



- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _scrollTouch = nil;

    CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

    if (_state == kCustomScrollLayerStateSliding)
    {
        // Calculate speed and stuff
        float distanceFromPrevious = touchPoint.y - _originalPoint.y;
        float timeSincePrevious = [[NSDate date] timeIntervalSinceDate:_time] * 5000;
        float newSpeed = distanceFromPrevious / timeSincePrevious;
        if ((newSpeed > 0 && newSpeed < 0.1) || (newSpeed < 0 && newSpeed > -0.1))
        {
            newSpeed = 0;
        }
        float moveBy = newSpeed * self.contentSize.height;

        // Calculate position
        CGPoint pos = self.position;
        pos.y += moveBy;
        pos.y = MIN(pos.y, self.contentSize.height);
        pos.y = MAX(pos.y, _screenSize.height);

        // Move it
        id cMove = [CCMoveTo actionWithDuration:2.0 position:pos];
        id cEase = [CCEaseExponentialOut actionWithAction:cMove];
        [self runAction:cEase];

        // Reset state
        _state = kCustomScrollLayerStateIdle;
    }
}

@end
