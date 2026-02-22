//
//  AnimatedCCMenuItemImage.m
//  Falling Candy
//
//  Created by Gints Murans on 3/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "AnimatedCCMenuItemImage.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"


@implementation AnimatedCCMenuItemImage
@synthesize disabled = _disabled, selectedAction = _selectedAction, unselectedAction = _unselectedAction, activateAction = _activateAction, buttonSound = _buttonSound;


- (void)dealloc
{
    [_selectedAction release], _selectedAction = nil;
    [_unselectedAction release], _unselectedAction = nil;
    [_activateAction release], _activateAction = nil;

    [super dealloc];
}

- (void)stopLocalActions
{
    [self stopActionByTag:kSelectedAction];
    [self stopActionByTag:kUnselectedAction];
    [self stopActionByTag:kActivateAction];
}


- (void)selected
{
    [super selected];
    if (self.selectedAction != nil)
    {
        [self stopLocalActions];
        [self.selectedAction setTag:kSelectedAction];
        [self runAction:self.selectedAction];
    }
}


- (void)unselected
{
    [super unselected];
    if (self.unselectedAction != nil)
    {
        [self stopLocalActions];
        [self.unselectedAction setTag:kUnselectedAction];
        [self runAction:self.unselectedAction];
    }
}


- (void)activate
{
    if (_buttonSound != nil)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:_buttonSound];
    }

    if (self.activateAction != nil)
    {
        [self stopLocalActions];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [super activate];
            [self doubleTapFix];
        }];
        id cSeq = [CCSequence actions:self.activateAction, cFunc, nil];
        [cSeq setTag:kActivateAction];
        [self runAction:cSeq];
    }
    else
    {
        [super activate];
        [self doubleTapFix];
    }
}


- (void)doubleTapFix
{
    [self setIsEnabled:NO];
    [self schedule:@selector(resetButton:) interval:0.5f];
}

- (void)resetButton:(ccTime)dt
{
    [self unschedule:@selector(resetButton:)];
    [self setIsEnabled:YES];
}

@end
