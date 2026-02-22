//
//  CCExtensions.h
//  Falling Candy
//
//  Created by Gints Murans on 7/2/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"

@interface CCNode (ccnode)
+ (CCRenderTexture *)createStrokeForSprite:(CCSprite*)sprite size:(float)size color:(ccColor3B)cor;
/**  Rotates a CCNode object to a certain angle around
 a certain rotation point by modifying it's rotation
 attribute and position.
 */
-(void) rotateAroundPoint:(CGPoint)rotationPoint angle:(CGFloat)angle;
@end
