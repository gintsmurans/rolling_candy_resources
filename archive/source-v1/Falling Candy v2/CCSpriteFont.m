//
//  CCSpriteFont.m
//  Falling Candy
//
//  Created by Gints Murans on 7/17/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCSpriteFont.h"
#import "CCSpriteFrameCache.h"

@implementation CCSpriteFont
@synthesize spacing = _spacing, prefix = _prefix;

- (id)initWithFile:(NSString *)fileImage plistFile:(NSString *)plistFile prefix:(NSString *)prefix
{
    self = [super initWithFile:fileImage capacity:29];
    if (self)
    {
        _spacing = 0.0f;
        _prefix = prefix;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistFile];
    }
    return self;
}


- (void)setText:(NSString *)text
{
    [self removeAllChildrenWithCleanup:YES];

    float width = 0, height = 0;
    for (int i = 0; i < text.length; ++i)
    {
        unichar char1 = [text characterAtIndex:i];
        NSString *upperCase;
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:char1])
        {
            upperCase = @"-c";
        }
        else
        {
            upperCase = @"";
        }

        CCSprite *letter = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@%C%@.png", _prefix, [[text lowercaseString] characterAtIndex:i], upperCase]];
        [letter setAnchorPoint:CGPointMake(0, 1)];
        [letter setPosition:CGPointMake(width, 0)];
        [self addChild:letter z:1];

        width += letter.contentSize.width + _spacing;
        height = MAX(height, letter.contentSize.height);
    }

    CCSprite *letter = nil;
    CCARRAY_FOREACH(self.children, letter)
    {
        [letter setPosition:CGPointMake(letter.position.x, height)];
    }

    [self setContentSize:CGSizeMake(width, height)];
}


- (void)setOpacity:(GLubyte)opacity
{
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
