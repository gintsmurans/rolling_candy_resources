//
//  GLMacros.h
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//


#import "CGPointExtension.h"


#define PTM_RATIO 32

#define rCGPointTopLeft(__PARENT__, __X__, __Y__) ccp(__X__, [__PARENT__ contentSize].height - __Y__)
#define rCGPoint(__CGPOINT__) CGPointMake(__CGPOINT__.x, ([[CCDirector sharedDirector] winSize].height - __CGPOINT__.y))

#define rToRight(__SMALL__, __BIG__) __BIG__ / 2 + (__BIG__ - __SMALL__) / 2
#define rToCenter(__SMALL__, __BIG__) (__BIG__ - __SMALL__) / 2
#define rToLeft(__SMALL__, __BIG__) __BIG__ / 2 - (__BIG__ - __SMALL__) / 2


#define TOTAL_THEMES 7
#define TOTAL_LEVELS 6
#define THEME_MULTIPLIER 20

#define TAG_CANDY 500
#define TAG_CHARACTER 501

#define TAG_BRICK_1 1000
#define TAG_BRICK_2 1001
#define TAG_BRICK_3 1002
#define TAG_BAD_BRICK_1 1003
#define TAG_BAD_BRICK_2 1004
#define TAG_BRICK_MOVING_LEFT 1008
#define TAG_BRICK_MOVING_RIGHT 1009

#define TAG_WATERMELON 2001
#define TAG_BANANA 2002
#define TAG_STRAWBERRY 2003
#define TAG_WHALE 2004
#define TAG_COIN 2008
#define TAG_STAR 2009


#define TAG_DART_0 3000
#define TAG_DART_1 3001
#define TAG_DART_2 3002
#define TAG_DART_3 3003
#define TAG_DART_4 3004
#define TAG_DART_5 3005
#define TAG_DART_6 3006
#define TAG_DART_7 3007
#define TAG_DART_8 3008



#pragma mark Animations

#define ANI_CHARACTER_BORED 100
#define ANI_CHARACTER_OPEN_MOUTH 101
#define ANI_CHARACTER_SAD 102
#define ANI_CHARACTER_EATING 103


