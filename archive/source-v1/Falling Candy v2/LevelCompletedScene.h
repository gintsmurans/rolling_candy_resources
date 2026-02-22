//
//  PauseScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GameScene.h"
#import "LevelsScene.h"



@interface LevelCompletedLayer : CCLayer
{
    CGSize _screenSize;
    CCSpriteBatchNode *_batchNode;
    CCSprite *_starsHolder;
    CCSprite *_star1;
    CCSprite *_star2;
    CCSprite *_star3;
    CCSprite *_highScore;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_levelLabel;
    CCLabelTTF *_msgLabel;
    int _showingStar;
    float _currScore;
}

@property (nonatomic, assign) int stars;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int theme;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int levelNr;
@property (nonatomic, assign) int nextTheme;
@property (nonatomic, assign) int nextLevel;
@property (nonatomic, assign) BOOL newHighScore;

+ (void)loadResources;
+ (LevelCompletedLayer *)layer;
+ (LevelCompletedLayer *)sharedLayer;

@end

