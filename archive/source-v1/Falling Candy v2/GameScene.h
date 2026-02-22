//
//  GameScene.h
//  Falling Candy
//
//  Created by Gints Murans on 3/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Macros.h"
#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "PhysicsSprite.h"
#import "GLES-Render.h"
#import "vector"
#import "BackgroundLayer.h"
#import "PauseLayer.h"
#import "GameBatchNode.h"
#import "CandySprite.h"
#import "CCSpriteFont.h"



const int32 k_maxContactPoints = 2048;
struct ContactPoint
{
    b2Fixture* fixtureA;
    b2Fixture* fixtureB;
    b2Vec2 normal;
    b2Vec2 position;
    b2PointState state;
};

class MyContactListener : public b2ContactListener{

public:
    std::vector<b2Body *>toDestroy;
    std::vector<b2Body *>changeTypeDynamic;
    id gameLayer;
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
};



@interface GameScene : CCScene
@property (nonatomic, retain) CCLayer *layer;
+ (GameScene *)sceneWithTheme:(int)theme andLevel:(int)level withLevelNr:(int)levelNr;
- (id)initWithTheme:(int)theme withLevel:(int)level withLevelNr:(int)levelNr;
@end



@interface GameLayer : CCLayer
{
    CandySprite *_candySprite;
    PhysicsSprite *_characterSprite;
    CCLayerColor *_progressLayer;
    CCSpriteFont *_currScoreLabel, *_highScoreLabel;

    BOOL _isHouseOpen, _gameCompleted, _gameFailed;
    float _accelX, _accelY, _accelXButtons;
    int _scrollSpeed;
    NSMutableSet *_checkpoints;

    b2World *_world;
    GLESDebugDraw *m_debugDraw;

    CCParticleBatchNode *_particleSheet;
    BackgroundLayer *_backgroundLayer;

    PauseLayer *_pauseLayer;

    int _maxScore, _currHighScore, _totalScore, _lastScore, _lastScoreCount;
    GLubyte _opacity;

    GLint _colorAmountUniformLocation, _colorAlphaUniformLocation;
    float _colorAmount, _colorAlpha;
    GameScene *_nextScene;
}

@property (nonatomic, retain) GameBatchNode *gameSheet;
@property (nonatomic, assign) MyContactListener *contactListener;
@property (nonatomic, assign) int theme;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int levelNr;
@property (nonatomic, assign) int currScore;
@property (nonatomic, assign) int randomCoinSpriteId;
@property (nonatomic, assign) CGPoint startCheckpoint;
@property (nonatomic, retain) NSMutableSet *removedObjects;
@property (nonatomic, retain) CCSprite *candyOverlaySprite;

+ (void)loadResources;
+ (GameLayer *)layer;

- (void)loadLayer;
- (void)restartGame;
- (void)restartGameWithCheckpoint:(CGPoint)checkpoint;

- (void)addRandomCoins;
- (void)updateScore:(int)score;
- (void)showScoreWithSprite:(PhysicsSprite *)sprite withShowParticles:(BOOL)showParticles;
- (void)gameCompleted;
- (void)gameFailedWithExplosion:(BOOL)explosion;

@end
