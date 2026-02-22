//
//  BrickSprite.m
//  Falling Candy
//
//  Created by Gints Murans on 4/29/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "BrickSprite.h"

@implementation BrickSubSprites
@synthesize direction = _direction, rotate = _rotate;
@end


@implementation Brick4Sprite

- (Brick4Sprite *)initWithSpriteFrameNames:(NSString *)firstName, ... NS_REQUIRES_NIL_TERMINATION;
{
    self = [super initWithSpriteFrameName:@"empty.png"];
    if (self)
    {
        _inc = 0;

        va_list args;
        va_start(args, firstName);
        for (NSString *arg = firstName; arg != nil; arg = va_arg(args, NSString*))
        {
            BrickSubSprites *sprite = [BrickSubSprites spriteWithSpriteFrameName:arg];
            [self addChild:sprite];

            int minX = -1;
            int maxX = 1;

            int minY = -5;
            int maxY = 0;

            int x = (arc4random() % (maxX - minX + 1)) + minX;
            int y = (arc4random() % (maxY - minY + 1)) + minY;

            if (x == 0)
            {
                x = minX;
            }
            if (y == 0)
            {
                y = minY;
            }

            [sprite setDirection:CGPointMake(x, y)];


            int minR = -45;
            int maxR = 45;
            int rot = (arc4random() % (maxR - minR + 1)) + minR;
            [sprite setRotate:rot];
        }
        va_end(args);
    }
    return self;
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

- (void)hitIt
{
    [self schedule:@selector(visit:)];
}

- (void)visit:(ccTime)delta
{
    _inc += 10;
    BrickSubSprites *sprite = nil;
    CCARRAY_FOREACH(self.children, sprite)
    {
        // Move
        CGPoint direction = sprite.direction;
        direction.x += direction.x * 0.2;
        direction.y += direction.y * 0.2;
        sprite.direction = direction;

        [sprite setPosition:ccpAdd(sprite.position, CGPointMake(sprite.direction.x * delta, sprite.direction.y * delta))];

        // Rotate
        if ((sprite.rotate < 0 && sprite.rotation > sprite.rotate) || (sprite.rotate > 0 && sprite.rotation < sprite.rotate))
        {
            [sprite setRotation:sprite.rotation + sprite.rotate * delta];
        }
    }
}

@end
