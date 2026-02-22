//
//  CCSpriteFont.h
//  Falling Candy
//
//  Created by Gints Murans on 7/17/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCSpriteBatchNode.h"
#import "CCSprite.h"

@interface CCSpriteFont : CCSpriteBatchNode
@property (nonatomic, assign) float spacing;
@property (nonatomic, retain) NSString *prefix;

- (id)initWithFile:(NSString *)fileImage plistFile:(NSString *)plistFile prefix:(NSString *)prefix;
- (void)setText:(NSString *)text;
- (void)setOpacity:(GLubyte)opacity;

@end
