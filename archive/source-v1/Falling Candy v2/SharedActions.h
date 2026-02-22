//
//  SharedActions.h
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SharedActions : NSObject
{
    NSDictionary *_levels;
}

@property (nonatomic, assign) float gravityX, gravityY, filtering, damping;

+ (SharedActions *)sharedActions;

- (CCAction *)buttonSelectedAction;
- (CCAction *)buttonUnselectedAction;
- (CCAction *)buttonActivateAction;
- (CCAction *)buttonDisabledUnselectedAction;


- (CCAction *)pauseButtonSelectedAction;
- (CCAction *)pauseButtonUnselectedAction;
- (CCAction *)pauseButtonActivateAction;

- (id)characterBored;
- (id)characterOpenMouth;
- (id)characterSad;
- (id)characterEating;
- (id)characterEyeBlink;
//- (id)characterJump;
//- (id)characterMoveFeet;

- (void)playButtonSound;

- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(CGSize)textureSize;
- (ccColor4F)randomBrightColor;

- (CCRenderTexture *) createStroke:(CCLabelTTF*) label size:(float)size color:(ccColor3B)cor;


- (NSString *)documentPath:(NSString *)append;
- (NSDictionary *)loadLevels;
- (void)clearLevelCache;

@end
