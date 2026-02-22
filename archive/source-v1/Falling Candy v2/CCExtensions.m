//
//  CCExtensions.m
//  Falling Candy
//
//  Created by Gints Murans on 7/2/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCExtensions.h"

@implementation CCNode (ccnode)

+ (CCRenderTexture *)createStrokeForSprite:(CCSprite*)sprite size:(float)size color:(ccColor3B)cor
{
    CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:sprite.texture.contentSize.width+size*2  height:sprite.texture.contentSize.height+size*2];
    CGPoint originalPos = [sprite position];
    ccColor3B originalColor = [sprite color];
    BOOL originalVisibility = [sprite visible];
    [sprite setColor:cor];
    [sprite setVisible:YES];
    ccBlendFunc originalBlend = [sprite blendFunc];
    [sprite setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    CGPoint bottomLeft = ccp(sprite.texture.contentSize.width * sprite.anchorPoint.x + size, sprite.texture.contentSize.height * sprite.anchorPoint.y + size);
    CGPoint positionOffset = ccp(sprite.texture.contentSize.width * sprite.anchorPoint.x - sprite.texture.contentSize.width/2,sprite.texture.contentSize.height * sprite.anchorPoint.y - sprite.texture.contentSize.height/2);
    CGPoint position = ccpSub(originalPos, positionOffset);

    [rt begin];
    for (int i=0; i<100; i+=30)
    {
        [sprite setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
        [sprite visit];
    }
    [rt end];
    [sprite setPosition:originalPos];
    [sprite setColor:originalColor];
    [sprite setBlendFunc:originalBlend];
    [sprite setVisible:originalVisibility];

    [rt setPosition:position];
    return rt;
}


-(void) rotateAroundPoint:(CGPoint)rotationPoint angle:(CGFloat)angle {
    CGFloat x = cos(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.x-rotationPoint.x) - sin(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.y-rotationPoint.y) + rotationPoint.x;
    CGFloat y = sin(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.x-rotationPoint.x) + cos(CC_DEGREES_TO_RADIANS(-angle)) * (self.position.y-rotationPoint.y) + rotationPoint.y;

    self.position = ccp(x, y);
    self.rotation = angle;
}

@end
