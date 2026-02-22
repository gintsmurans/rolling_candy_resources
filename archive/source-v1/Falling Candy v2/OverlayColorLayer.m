//
//  OverlayColorLayer.m
//  Falling Candy
//
//  Created by Gints Murans on 8/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "OverlayColorLayer.h"

@implementation OverlayColorLayer
@synthesize touchUpBlock = _touchUpBlock;


- (void)dealloc
{
    self.touchUpBlock = nil;
    [super dealloc];
}


- (void)onEnter
{
    [super onEnter];
    if (_touchUpBlock)
    {
        [self registerWithTouchDispatcher];
    }
}



#pragma mark Touches

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_touchUpBlock)
    {
        _touchUpBlock();
    }
}


- (void)registerWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority + 10;
	[dispatcher addTargetedDelegate:self priority:priority swallowsTouches:YES];
}

@end
