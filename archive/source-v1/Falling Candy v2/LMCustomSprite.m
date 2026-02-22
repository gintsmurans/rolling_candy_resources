//
//  LMCustomSprite.m
//  Falling Candy
//
//  Created by Gints Murans on 5/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "LMCustomSprite.h"

@implementation LMCustomSprite
@synthesize disabled = _disabled;
@synthesize done = _done;
@synthesize enabledFrameName = _enabledFrameName;
@synthesize touchUpBlock = _touchUpBlock;


- (void)onEnter
{
    [super onEnter];
    [self registerWithTouchDispatcher];
}


- (void)onExit
{
    [super onExit];
    [self unregisterWithTouchDispatcher];
}


- (void)registerWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    int priority = kCCMenuHandlerPriority - 1;
	[dispatcher addTargetedDelegate:self priority:priority swallowsTouches:NO];
}


- (void) unregisterWithTouchDispatcher
{
    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
    [dispatcher removeDelegate:self];
}


- (BOOL) touchHitsSelf:(UITouch*) touch
{
    return [self touch:touch hitsNode:self];
}

- (BOOL) touch:(UITouch*) touch hitsNode:(CCNode*) node
{
    CGRect r = CGRectMake(0, 0, node.contentSize.width, node.contentSize.height);
    CGPoint local = [node convertTouchToNodeSpace:touch];

    return CGRectContainsPoint(r, local);
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([self touchHitsSelf:touch])
    {
        _touchInProgress = YES;
        [self touchDown];
        return YES;
    }
    return NO;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_touchInProgress)
    {
        [self touchUpWithCancelled:NO];
        _touchInProgress = NO;
    }
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_touchInProgress)
    {
        [self touchUpWithCancelled:YES];
        _touchInProgress = NO;
    }
}



#pragma mark - Blocks

- (void)touchDown
{
    if (self.isDisabled == YES)
    {
        id action4 = [CCRotateTo actionWithDuration:0.05 angle:15];
        id action5 = [CCRotateTo actionWithDuration:0.05 angle:-15];
        id action6 = [CCRotateTo actionWithDuration:0.05 angle:0.0];

        CCSequence *scaleSeq = [CCSequence actions:action4, action5, action6, nil];
        CCAction *action = [CCRepeat actionWithAction:scaleSeq times:2];
        [self runAction:action];
    }
    else
    {
        id cSca = [CCScaleTo actionWithDuration:0.1 scale:0.8];
        [self runAction:cSca];
    }
}

- (void)touchUpWithCancelled:(BOOL)cancelled
{
    if (self.isDisabled == NO)
    {
        [self doubleTapFix];
        id cSca = [CCScaleTo actionWithDuration:0.2 scale:1.0];
        id cFunc = [CCCallBlock actionWithBlock:^{
            if (cancelled == NO && self.touchUpBlock != nil)
            {
                self.touchUpBlock();
            }
        }];
        id cSeq = [CCSequence actions:cSca, cFunc, nil];
        [self runAction:cSeq];
    }
}


- (void)doubleTapFix
{
    [self setDisabled:YES];
    [self schedule:@selector(resetButton:) interval:0.5f];
}

- (void)resetButton:(ccTime)dt
{
    [self unschedule:@selector(resetButton:)];
    [self setDisabled:NO];
}

@end
