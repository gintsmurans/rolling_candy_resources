//
//  GameScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <vector>

#import "GameScene.h"
#import "GB2ShapeCache.h"
#import "AnimatedCCMenuItemImage.h"
#import "SharedActions.h"
#import "LevelsScene.h"
#import "b2Contact.h"
#import "SimpleAudioEngine.h"
#import "LevelCompletedScene.h"
#import "LoaderLayer.h"
#import "CCMoveByXY.h"
#import "FSNConnection.h"
#import "BrickSprite.h"
#import "CCShake.h"
#import "CCRotateAround.h"



#pragma mark - Collision detection


void MyContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
    // Find objects
    CandySprite *candySprite = nil;
    PhysicsSprite *otherSprite = (PhysicsSprite *)contact->GetFixtureB()->GetBody()->GetUserData();


    if (otherSprite == nil)
    {
        return;
    }

    // Find static physics sprite
    if (otherSprite.body->GetType() == b2_dynamicBody)
    {
        candySprite = (CandySprite *)contact->GetFixtureB()->GetBody()->GetUserData();
        otherSprite = (PhysicsSprite *)contact->GetFixtureA()->GetBody()->GetUserData();
    }
    else
    {
        candySprite = (CandySprite *)contact->GetFixtureA()->GetBody()->GetUserData();
    }


    if ([otherSprite isKindOfClass:[PhysicsSprite class]] == YES)
    {
        if (otherSprite.tag == 1023 || otherSprite.tag == 1024)
        {
            float x = otherSprite.customVariable1 * 8;
            contact->SetTangentSpeed(x);

            if (candySprite.tag == TAG_CANDY)
            {
                [candySprite setSurfaceVelocity:b2Vec2(x, -1)];
            }
        }
    }
}


void MyContactListener::EndContact(b2Contact *contact)
{
    CandySprite *candySprite = (CandySprite *)contact->GetFixtureA()->GetBody()->GetUserData();
    if (candySprite == nil)
    {
        return;
    }

    if (candySprite.tag != TAG_CANDY)
    {
        candySprite = (CandySprite *)contact->GetFixtureB()->GetBody()->GetUserData();
    }

    if (candySprite.tag != TAG_CANDY)
    {
        return;
    }

    [candySprite setSurfaceVelocity:b2Vec2(0, 0)];
}


void MyContactListener::BeginContact(b2Contact *contact)
{
    // Find objects
    CandySprite *candySprite = (CandySprite *)contact->GetFixtureA()->GetBody()->GetUserData();
    PhysicsSprite *otherSprite;


    // Stop if a sprite is not associated with the body
    if (candySprite == nil)
    {
        return;
    }


    // Find which one is candy and which one is other object
    if (candySprite.tag == TAG_CANDY)
    {
        otherSprite = (PhysicsSprite *)contact->GetFixtureB()->GetBody()->GetUserData();
    }
    else
    {
        otherSprite = (PhysicsSprite *)candySprite;
        candySprite = (CandySprite *)contact->GetFixtureB()->GetBody()->GetUserData();
    }


    // Stop if one of elements wasn't candy (Shouldn't ever happen)
    if (candySprite.tag != TAG_CANDY || otherSprite.body == nil)
    {
        return;
    }

    // Calculate effect volume
    b2Vec2 vel = candySprite.body->GetLinearVelocity();
    CGFloat volume = MIN(1.0f, fabsf(vel.y / 10));
    if (volume <= 0.5f)
    {
        volume = 0.0f;
    }

    // Choose object and do stuff with it
    switch (otherSprite.tag)
    {
        // Regular bricks
        case TAG_BRICK_1:
        {
            if (volume > 0.0f) [[SimpleAudioEngine sharedEngine] playEffect:@"brick-wood.m4a" pitch:1.0f pan:0.0f gain:volume];
            break;
        }



        // Leaf bricks
        case TAG_BRICK_2:
        case TAG_BRICK_3:
        {
            if (volume > 0.0f)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"brick-leaf.m4a" pitch:1.0f pan:0.0f gain:0.4f];
                CCShake *shake = [CCShake actionWithDuration:0.5 amplitude:ccp(2,2) dampening:NO shakes:7];
                [otherSprite runAction:shake];

                int max = (otherSprite.tag == TAG_BRICK_3 ? 3 : 9);
                int rnd = (arc4random() % (max - 1 + 1)) + 1;
                for (int i = 1; i <= rnd; ++i)
                {
                    int speed = (arc4random() % (10 - 2 + 1)) + 2;
                    CCSprite *leapSprite = [CCSprite spriteWithSpriteFrameName:@"brick-leap.png"];

                    int max = otherSprite.contentSize.width / 2;
                    int rndPosX = (arc4random() % (max - (-max) + 1)) + (-max);
                    [leapSprite setPosition:CGPointMake(otherSprite.position.x + rndPosX, otherSprite.position.y)];
                    [otherSprite.parent addChild:leapSprite];

                    ccBezierConfig bezier;
                    bezier.controlPoint_1 = CGPointMake(leapSprite.position.x - 102, leapSprite.position.y - 79);
                    bezier.controlPoint_2 = CGPointMake(leapSprite.position.x + 79, leapSprite.position.y - 47);
                    bezier.endPosition = CGPointMake(leapSprite.position.x - 8, leapSprite.position.y - 175);
                    id cBez = [CCBezierTo actionWithDuration:speed bezier:bezier];
                    id cFunc = [CCCallBlock actionWithBlock:^{
                        [leapSprite removeFromParentAndCleanup:YES];
                    }];

                    int rotSpeed = (arc4random() % (2 - 1 + 1)) + 1;
                    id cRot1 = [CCRotateTo actionWithDuration:rotSpeed angle:40.0];
                    id cRot2 = [CCRotateTo actionWithDuration:rotSpeed * 2 angle:-40.0];

                    [leapSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:cRot1, cRot2, nil]]];
                    [leapSprite runAction:[CCSequence actions:cBez, cFunc, nil]];
                }
            }
            
            break;
        }

            
        // Snakes
        case 1005:
        case 1006:
        case 1007:
        {
            if (volume > 0.0f)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"brick-snake.m4a" pitch:1.0f pan:0.0f gain:volume];

                CCSprite *eyes = (CCSprite *)[otherSprite getChildByTag:1];
                id cShake = [CCShake actionWithDuration:0.5 amplitude:CGPointMake(0, 5) shakes:20];
                id cEase = [CCEaseOut actionWithAction:cShake rate:3];
                [eyes stopAllActions];
                [eyes runAction:cEase];
            }
            break;
        }

            
        // Birds
        case 1008:
        case 1009:
        {
            if (volume > 0.0f) [[SimpleAudioEngine sharedEngine] playEffect:@"brick-bird.m4a" pitch:1.0f pan:0.0f gain:volume];
            break;
        }


            
        // Trees
        case 1010:
        case 1011:
        case 1012:
        case 1013:
        case 1014:
        {
            if (volume > 0.0f) [[SimpleAudioEngine sharedEngine] playEffect:@"brick-leaf.m4a" pitch:1.0f pan:0.0f gain:0.4f];
            break;
        }

            

        // Gray bricks
        case 1015:
        case 1016:
        case 1017:
        case 3009:
        case 3010:
        {
            if (volume > 0.0f) [[SimpleAudioEngine sharedEngine] playEffect:@"brick-stone-gray.m4a" pitch:1.0f pan:0.0f gain:volume];
            break;
        }


        case 1026:
        {
            CGPoint pos = [otherSprite.parent convertToWorldSpace:otherSprite.position];

            CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"star-explode.plist"];
            [particle setAutoRemoveOnFinish:YES];
            [particle setPosition:pos];
            [otherSprite.parent.parent addChild:particle z:5];

            // Remove sprite
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];
            [otherSprite removeFromParentAndCleanup:YES];
            break;
        }
            

        // Breaking brick
        case TAG_BAD_BRICK_1:
        {
            // Sound
            [(GameLayer *)gameLayer showScoreWithSprite:otherSprite withShowParticles:NO];
            [[SimpleAudioEngine sharedEngine] playEffect:@"brick-stone.m4a" pitch:1.0f pan:0.0f gain:1.0f];

            // Remove sprite
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Shake it
            CCShake *shake = [CCShake actionWithDuration:0.5 amplitude:ccp(2,2) dampening:NO shakes:10];
            [otherSprite.parent.parent runAction:shake];

            // Show some animation
            Brick4Sprite *brick = [[[Brick4Sprite alloc] initWithSpriteFrameNames:@"Brick4/9.png", @"Brick4/10.png", @"Brick4/11.png", @"Brick4/2.png", @"Brick4/3.png", @"Brick4/4.png", @"Brick4/5.png", @"Brick4/6.png", @"Brick4/7.png", @"Brick4/8.png", nil] autorelease];
            [brick setPosition:otherSprite.position];
            [otherSprite.parent addChild:brick];
            [brick hitIt];

            id cFade = [CCFadeTo actionWithDuration:2.2 opacity:0];
            id cFunc = [CCCallBlock actionWithBlock:^{
                [brick removeFromParentAndCleanup:YES];
            }];
            [brick runAction:[CCSequence actions:cFade, cFunc, nil]];

            // Remove old brick
            [otherSprite removeFromParentAndCleanup:YES];
            break;
        }


            
        // Breaking brick
        case TAG_BAD_BRICK_2:
        {
            // Sound and score thingy
            [(GameLayer *)gameLayer showScoreWithSprite:otherSprite withShowParticles:NO];
            [[SimpleAudioEngine sharedEngine] playEffect:@"brick-wood-crashing.m4a" pitch:1.0f pan:0.0f gain:1.0f];

            // Destroy b2body
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Animation
            Brick4Sprite *brick = [[[Brick4Sprite alloc] initWithSpriteFrameNames:@"Brick5/12.png", @"Brick5/7.png", @"Brick5/8.png", @"Brick5/9.png", @"Brick5/10.png", @"Brick5/11.png", nil] autorelease];
            [brick setPosition:otherSprite.position];
            [otherSprite.parent addChild:brick];
            [brick hitIt];

            id cFade = [CCFadeTo actionWithDuration:2.2 opacity:0];
            id cFunc = [CCCallBlock actionWithBlock:^{
                [brick removeFromParentAndCleanup:YES];
            }];
            [brick runAction:[CCSequence actions:cFade, cFunc, nil]];

            // Remove old brick
            [otherSprite removeFromParentAndCleanup:YES];
            break;
        }


            
        // Coin
        case TAG_COIN:
        {
            // Sound and score thingy
            [[SimpleAudioEngine sharedEngine] playEffect:@"cashregister.m4a" pitch:1.0f pan:0.0f gain:0.5f];
            [(GameLayer *)gameLayer showScoreWithSprite:otherSprite withShowParticles:NO];

            // Destroy b2body
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Animate
            id cMov1 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(otherSprite.position.x, otherSprite.position.y - 20)];
            id cMov2 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(otherSprite.position.x, otherSprite.position.y + 70)];
            id cFad = [CCFadeOut actionWithDuration:0.1];
            id cFunc = [CCCallBlock actionWithBlock:^{
                [[(GameLayer *)gameLayer removedObjects] addObject:[NSNumber numberWithInt:otherSprite.spriteId]];
                [otherSprite removeFromParentAndCleanup:YES];
            }];
            [otherSprite runAction:[CCSequence actions:cMov1, cMov2, cFad, cFunc, nil]];
            break;
        }

            

        // Star
        case TAG_STAR:
        {
            // Sound and score thingy
            [[SimpleAudioEngine sharedEngine] playEffect:@"chim.m4a" pitch:1.0f pan:0.0f gain:0.5f];
            [(GameLayer *)gameLayer showScoreWithSprite:otherSprite withShowParticles:YES];

            // Destroy b2body
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Shake it baby
            CCShake *shake = [CCShake actionWithDuration:0.5 amplitude:ccp(2,2) dampening:NO shakes:10];
            [otherSprite.parent.parent runAction:shake];

            // Animate
            id cSca2 = [CCScaleTo actionWithDuration:0.1 scale:2.4];
            id cFunc2 = [CCCallBlock actionWithBlock:^{
                [[(GameLayer *)gameLayer removedObjects] addObject:[NSNumber numberWithInt:otherSprite.spriteId]];
                [otherSprite removeFromParentAndCleanup:YES];
            }];
            [otherSprite runAction:[CCSequence actions:cSca2, cFunc2, nil]];
            break;
        }



        // Darts
        case TAG_DART_0:
        case TAG_DART_1:
        case TAG_DART_2:
        case TAG_DART_3:
        case TAG_DART_4:
        case TAG_DART_5:
        case TAG_DART_6:
        case TAG_DART_7:
        case TAG_DART_8:
        {
            // Break it sound
            [[SimpleAudioEngine sharedEngine] playEffect:@"break.m4a"];

            // Remove sprite
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Game failed
            [(GameLayer *)gameLayer gameFailedWithExplosion:YES];
            break;
        }


        case 3011:
        {
            // Break it sound
            [[SimpleAudioEngine sharedEngine] playEffect:@"laugh.m4a"];

            // Move things around
            [[otherSprite getChildByTag:1] setVisible:NO];
            [[(GameLayer *)gameLayer candyOverlaySprite] setVisible:NO];
            id cFade = [CCFadeTo actionWithDuration:0.2 opacity:0];
            [candySprite runAction:cFade];
            candySprite.body->SetLinearVelocity(otherSprite.body->GetPosition());


            // Remove sprite
            toDestroy.push_back(otherSprite.body);
            otherSprite.body->SetUserData(nil);
            [otherSprite setBody:nil];

            // Game failed
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [(GameLayer *)gameLayer gameFailedWithExplosion:NO];
            });
            break;
        }


        // Whale
        case TAG_WHALE:
        {
            if (volume > 0.0f)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"brick-whale.m4a"];
            }
            break;
        }


        // Cage
        case 2010:
        {
            if (otherSprite.customVariable1 != 1)
            {
                [otherSprite setCustomVariable1:1];
                [(GameLayer *)gameLayer setRandomCoinSpriteId:otherSprite.spriteId];
            }
            break;
        }


        // The Main Character
        case TAG_CHARACTER:
        {
            [(GameLayer *)gameLayer gameCompleted];
            break;
        }
    }
}




@implementation GameScene
@synthesize layer = _layer;


+ (GameScene *)sceneWithTheme:(int)theme andLevel:(int)level withLevelNr:(int)levelNr
{
 	GameScene *scene = [[[GameScene alloc] initWithTheme:theme withLevel:level withLevelNr:levelNr] autorelease];
	return scene;
}

- (id)initWithTheme:(int)theme withLevel:(int)level withLevelNr:(int)levelNr
{
    self = [super init];
    if (self)
    {
        _layer = [GameLayer layer];
        [(GameLayer *)_layer setTheme:theme];
        [(GameLayer *)_layer setLevel:level];
        [(GameLayer *)_layer setLevelNr:levelNr];
        [(GameLayer *)_layer loadLayer];
        [self addChild:_layer z:0];
    }
    return self;
}
@end




#pragma mark - GameLayer

@implementation GameLayer
@synthesize theme = _theme, level = _level, levelNr = _levelNr,
            currScore = _currScore, randomCoinSpriteId = _randomCoinSpriteId,
            gameSheet = _gameSheet, contactListener = _contactListener,
            startCheckpoint = _startCheckpoint, removedObjects = _removedObjects,
            candyOverlaySprite = _candyOverlaySprite;


#pragma mark - Initialization


+ (void)loadResources
{
    // Load music
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"break.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-bird.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-leaf.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-snake.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-stone-gray.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-stone.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-whale.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-wood-crashing.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"brick-wood.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"cashregister.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"chew.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"chim.m4a"];
//    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bonus.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"game-success.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"playing-games.m4a"];

    // Load shared sprite frame cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game-objects.plist"];

    // Load shapes
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"game-shapes.plist"];

    // Load textures
    [[CCTextureCache sharedTextureCache] addImage:@"game-objects.pvr"];

    // Load particles
    [CCParticleSystemQuad particleWithFile:@"star-explode.plist"];
    [CCParticleSystemQuad particleWithFile:@"star-glowe.plist"];

    // Load shaders | should be done once opengl is setup
    CCGLProgram *grayShader = [[CCGLProgram alloc] initWithVertexShaderFilename:@"ShaderGray.vs" fragmentShaderFilename:@"ShaderGray.fs"];
    [grayShader addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
    [grayShader addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    [grayShader link];
    [grayShader updateUniforms];

    [[CCShaderCache sharedShaderCache] addProgram:grayShader forKey:@"GrayShader"];
    [grayShader release];
}


+ (GameLayer *)layer
{
	GameLayer *layer = [[[GameLayer alloc] init] autorelease];
	return layer;
}


- (void)loadLayer
{
    _opacity = 255;
    _randomCoinSpriteId = 0;

    // Init stuff
    [self loadGame];
    [self initPhysics];
    [self generateLevel];


    // Play game music
    BOOL musicIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"MusicIsOn"];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(musicIsOn ? 0.1f : 0.0f)];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games.m4a"];

    [TestFlight passCheckpoint:@"Game Scene"];
}


- (void)cleanup
{
    delete _world, _world = nil;
    delete _contactListener, _contactListener = nil;

    [super cleanup];
}


- (void)dealloc
{
    NSLog(@"GameLayer Dealloc");
    [_checkpoints release];
    [_removedObjects release];
    [super dealloc];
}



- (void)scheduleUpdate
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationResignActive) name:@"ApplicationResignActive" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self setAccelerometerEnabled:YES];
    [super scheduleUpdate];
}


- (void)unscheduleUpdate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setAccelerometerEnabled:NO];
    [super unscheduleUpdate];
}



#pragma mark - Getters and Setters

- (void)setCurrScore:(int)currScore
{
    _currScore = currScore;
    [_currScoreLabel setText:[NSString stringWithFormat:@"Score# %d", _currScore]];
}



- (void)setRemovedObjects:(NSMutableSet *)removedObjects
{
    if (_removedObjects != nil)
    {
        [_removedObjects release], _removedObjects = nil;
    }

    _removedObjects = [removedObjects retain];
    CCArray *tmpArray = [[CCArray alloc] init];

    if (_removedObjects != nil)
    {
        PhysicsSprite *sprite = nil;
        CCARRAY_FOREACH(_gameSheet.children, sprite)
        {
            if ([sprite isKindOfClass:[PhysicsSprite class]] == NO || sprite.spriteId <= 0)
            {
                continue;
            }

            NSNumber *idObject = [NSNumber numberWithInt:sprite.spriteId];
            if ([_removedObjects containsObject:idObject])
            {
                if (sprite.body != nil)
                {
                    sprite.body->SetUserData(nil);
                    _world->DestroyBody(sprite.body);
                    [sprite setBody:nil];
                }
                [tmpArray addObject:sprite];
            }
        }
        [_gameSheet.children removeObjectsInArray:tmpArray];
        [tmpArray release], tmpArray = nil;
        tmpArray = [[CCArray alloc] init];


        CCParticleSystemQuad *particle = nil;
        CCARRAY_FOREACH(_particleSheet.children, particle)
        {
            NSNumber *idObject = [NSNumber numberWithInt:particle.tag];
            if ([_removedObjects containsObject:idObject])
            {
                [tmpArray addObject:particle];
            }
        }
        [_particleSheet.children removeObjectsInArray:tmpArray];
        [tmpArray release], tmpArray = nil;
    }
}



- (void)setStartCheckpoint:(CGPoint)startCheckpoint
{
    _startCheckpoint = startCheckpoint;
    if (CGPointEqualToPoint(_startCheckpoint, CGPointZero) == NO)
    {
        float y = fabsf(_startCheckpoint.y) + self.contentSize.height / 2;
        [_gameSheet setPosition:CGPointMake(_gameSheet.position.x, _gameSheet.position.y + y)];
        [_backgroundLayer setPosition:CGPointMake(_backgroundLayer.position.x, _backgroundLayer.position.y + y)];
        [_particleSheet setPosition:CGPointMake(_particleSheet.position.x, _particleSheet.position.y + y)];

        CGPoint screenPoint = [_gameSheet convertToWorldSpace:_startCheckpoint];
        [_candySprite setPosition:screenPoint];
        [_candyOverlaySprite setPosition:screenPoint];
    }
}



- (GLubyte)opacity{
    return _opacity;
}

- (void)setOpacity:(GLubyte)opacity
{
    _opacity = opacity;
    CCNode *node = nil;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node respondsToSelector:@selector(setOpacity:)])
        {
            [(id<CCRGBAProtocol>)node setOpacity:opacity];
        }
    }
}


#pragma mark - Helpers and some events

- (void)applicationResignActive
{
    [_pauseLayer pause:nil];
}


- (void)restartGame
{
    [self unscheduleUpdate];

    GameScene *scene = [GameScene sceneWithTheme:_theme andLevel:_level withLevelNr:_levelNr];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
}


- (void)restartGameWithCheckpoint:(CGPoint)checkpoint
{
    NSLock *myLock = [[[NSLock alloc] init] autorelease];
    EAGLContext *myAuxGLcontext = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:[[(CCGLView *)[[CCDirector sharedDirector] view] context] sharegroup]] autorelease];

    dispatch_queue_t backgroundQueue = dispatch_queue_create("lv.earlybird.queue", 0);
    dispatch_async(backgroundQueue, ^{
        [myLock lock];
        [EAGLContext setCurrentContext:myAuxGLcontext];

        _nextScene = [[GameScene sceneWithTheme:_theme andLevel:_level withLevelNr:_levelNr] retain];
//        if (CGPointEqualToPoint(checkpoint, CGPointZero) == NO)
//        {
//            [(GameLayer *)_nextScene.layer setCurrScore:_currScore];
//            [(GameLayer *)_nextScene.layer setRemovedObjects:_removedObjects];
//            [(GameLayer *)_nextScene.layer setStartCheckpoint:checkpoint];
//        }

        [EAGLContext setCurrentContext:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self restartGameWithFadeout];
        });
        [myLock unlock];
    });
}


- (void)restartGameWithFadeout
{
    // OpenGL stuff
    CCGLProgram *program = [[CCShaderCache sharedShaderCache] programForKey:@"GrayShader"];

    _colorAmount = 0.0;
    _colorAmountUniformLocation = glGetUniformLocation(program->_program, "ColorAmount");

    [program use];
    glUniform1f(_colorAmountUniformLocation, _colorAmount);

    _gameSheet.shaderProgram = program;
    _backgroundLayer.shaderProgram = program;
    _progressLayer.parent.shaderProgram = program;
    _progressLayer.shaderProgram = program;

    [self schedule:@selector(replaceSceneWithFadeOut:)];
}

- (void)replaceSceneWithFadeOut:(ccTime)dt
{
    [_gameSheet.shaderProgram use];
    _colorAmount += 1.0/10;
    glUniform1f(_colorAmountUniformLocation, _colorAmount);

    if (_colorAmount >= 1.0)
    {
        [self unscheduleUpdate];
        [self unschedule:@selector(replaceSceneWithFadeOut:)];
        double delayInSeconds = 0.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[_nextScene autorelease] withColor:ccWHITE]];
        });
    }
}



- (void)resetLastScore
{
    _lastScoreCount = 0;
    _lastScore = 0;
}



- (void)updateScore:(int)score
{
    self.currScore += score;

    // Bonus
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetLastScore) object:nil];

    if (_lastScore == score || _lastScoreCount == 0)
    {
        _lastScoreCount += 1;
    }
    _lastScore = score;

    if (_lastScoreCount == 3)
    {
        self.currScore += 350;
        CGPoint point = _candySprite.position; // [_gameSheet convertToNodeSpace:_candySprite.position];
        point.y += 35;
        [self showScoreInPoint:point withScore:350 withDuration:0.5];
    }

    [self performSelector:@selector(resetLastScore) withObject:nil afterDelay:0.3];
}


- (void)showScoreInPoint:(CGPoint)point withScore:(int)score withDuration:(float)duration
{
    // Score label
    CCSprite *scoreLabel = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"p%d.png", score]];
    [scoreLabel setPosition:point];
    [scoreLabel setScale:0.0f];

    // Move label around and fade it out
    id cSca11 = [CCScaleTo actionWithDuration:duration scale:1.0];
    id cDelay11 = [CCDelayTime actionWithDuration:duration + 0.1];
    id cSca12 = [CCScaleTo actionWithDuration:0.1 scale:0.0f];
    id cFunc11 = [CCCallBlock actionWithBlock:^{
        [scoreLabel removeFromParentAndCleanup:YES];
    }];
    [scoreLabel runAction:[CCSequence actions:cSca11, cDelay11, cSca12, cFunc11, nil]];
    [_gameSheet addChild:scoreLabel];
}


- (void)showScoreWithSprite:(PhysicsSprite *)sprite withShowParticles:(BOOL)showParticles
{
    // Update current total score
    [self updateScore:sprite.score];

    // Score label
    float duration = (showParticles == YES ? 0.3f : 0.2f);
    [self showScoreInPoint:CGPointMake(sprite.position.x, sprite.position.y + 35) withScore:sprite.score withDuration:duration];

    // Particle
    CCParticleSystemQuad *particle = nil;
    if (showParticles == YES)
    {
        CGPoint pos = [_gameSheet convertToWorldSpace:sprite.position];

        particle = [CCParticleSystemQuad particleWithFile:@"star-explode.plist"];
        [particle setAutoRemoveOnFinish:YES];
        [particle setPosition:pos];
        [self addChild:particle z:5];

        // Remove any backround particles
        CCParticleSystemQuad *particle = nil;
        CCARRAY_FOREACH(_particleSheet.children, particle)
        {
            if (particle.tag == sprite.spriteId)
            {
                [particle removeFromParentAndCleanup:YES];
            }
        }
    }
}


- (void)gameFailedWithExplosion:(BOOL)explosion
{
    // Avoid multiple calls
    if (_gameCompleted == YES)
    {
        return;
    }
    _gameCompleted = YES;


    // Hide the pause menu and stop the game
    [_pauseLayer hideMenu];
    [self unscheduleUpdate];


    // Find and save checkpoint
//    CGPoint candyPoint = [_gameSheet convertToNodeSpace:_candySprite.position];
//    for (NSValue *value in _checkpoints)
//    {
//        CGPoint point = [value CGPointValue];
//        if (point.y < checkPoint.y && point.y > candyPoint.y)
//        {
//            checkPoint = point;
//        }
//    }

    // Move candy sprite to the front and destroy it
    [_candyOverlaySprite setVisible:NO];
    [_candySprite setVisible:NO];

    // Explosion
    if (explosion == YES)
    {
        CGPoint candyPoint = [_gameSheet convertToWorldSpace:_candySprite.position];
        CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"star-explode.plist"];
        [particle setAutoRemoveOnFinish:YES];
        [particle setPosition:candyPoint];
        [particle setDuration:0.10];
        [self addChild:particle z:5];
    }

    // Restart game
    [self restartGameWithCheckpoint:CGPointZero];
    [_characterSprite runAction:[[SharedActions sharedActions] characterSad]];
}



- (void)gameCompleted
{
    if (_gameCompleted == YES)
    {
        // Stop from calling it multiple times
        return;
    }

    // Hide the pause menu
    [_pauseLayer hideMenu];

    // Stop the game
    _gameCompleted = YES;
    [self unscheduleUpdate];
    [self schedule:@selector(updateMoveUp:)];

    [_candyOverlaySprite setVisible:NO];
    [_candySprite setVisible:NO];

    // Chew sound
    __block typeof(self) mySelf = self;
    __block int chewId = [[SimpleAudioEngine sharedEngine] playEffect:@"chew.m4a"];


    // Animation
    id cAni1 = [[SharedActions sharedActions] characterEating];
    id cAni2 = [[[SharedActions sharedActions] characterOpenMouth] reverse];
    id cFunc2 = [CCCallBlock actionWithBlock:^{
        [[SimpleAudioEngine sharedEngine] stopEffect:chewId];
        [[SimpleAudioEngine sharedEngine] playEffect:@"game-success.m4a" pitch:1.0f pan:0.0f gain:0.7f];
    }];
    id cDelay2 = [CCDelayTime actionWithDuration:1.5f];
    id cFunc3 = [CCCallBlock actionWithBlock:^{
        [_characterSprite runAction:[[SharedActions sharedActions] characterBored]];
    }];
    id cFunc4 = [CCCallBlock actionWithBlock:^{
        [mySelf showSuccessScene];
    }];

    id cSeq2 = [CCSequence actions:cAni2, cAni1, [[cAni1 copy] autorelease], [[cAni1 copy] autorelease], [[cAni1 copy] autorelease], [[cAni1 copy] autorelease], cFunc2, cFunc3, cDelay2, cFunc4, nil];

    [_characterSprite stopActionByTag:ANI_CHARACTER_BORED];
    [_characterSprite runAction:cSeq2];
}


- (void)showSuccessScene
{
    // Find how many stars we give
    int stars = 0;
    float scored_progress = ((_currScore + 10) * 100 / _maxScore);
    if (scored_progress >= 90)
    {
        stars = 3;
    }
    else if (scored_progress >= 60)
    {
        stars = 2;
    }
    else if (scored_progress >= 40)
    {
        stars = 1;
    }


    // Init success view
    LevelCompletedLayer *lcs = [LevelCompletedLayer sharedLayer];
    [lcs setStars:stars];
    [lcs setScore:_currScore];
    [lcs setTheme:_theme];
    [lcs setLevel:_level];
    [lcs setLevelNr:_levelNr];


    // Save the result
    NSDictionary *dictCheck = [[NSUserDefaults standardUserDefaults] objectForKey:@"FinishedLevels"];
    NSMutableDictionary *finishedLevels;
    if (dictCheck == nil)
    {
        finishedLevels = [[NSMutableDictionary alloc] init];
    }
    else
    {
        finishedLevels = [dictCheck mutableCopy];
    }


    NSString *levelIndex = [NSString stringWithFormat:@"%d:%d", _theme, _level];
    dictCheck = [finishedLevels objectForKey:levelIndex];
    NSMutableDictionary *levelDone;
    if (dictCheck == nil)
    {
        levelDone = [[NSMutableDictionary alloc] init];
        [levelDone setObject:[NSNumber numberWithInt:_level] forKey:@"level"];
    }
    else
    {
        levelDone = [dictCheck mutableCopy];
    }

    _currHighScore = [[levelDone objectForKey:@"score"] intValue];
    if (_currScore > _currHighScore)
    {
        [lcs setNewHighScore:_currHighScore > 0];
        [levelDone setObject:[NSNumber numberWithInt:_currScore] forKey:@"score"];

        _totalScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalScore"];
        _totalScore = _totalScore - _currHighScore + _currScore;
        [[NSUserDefaults standardUserDefaults] setInteger:_totalScore forKey:@"TotalScore"];
    }
    else
    {
        [lcs setNewHighScore:NO];
    }

    // Set stars
    int storedStars = [[levelDone objectForKey:@"stars"] intValue];
    if (stars > storedStars)
    {
        [levelDone setObject:[NSNumber numberWithInt:stars] forKey:@"stars"];
    }
    [finishedLevels setObject:levelDone forKey:levelIndex];
    [levelDone release], levelDone = nil;

    // Open next level
    int theme = (_level == TOTAL_LEVELS ? _theme + 1 : _theme);
    int level = (_level == TOTAL_LEVELS ? 1 : _level + 1);
    levelIndex = [NSString stringWithFormat:@"%d:%d", theme, level];
    levelDone = [[finishedLevels objectForKey:levelIndex] mutableCopy];
    if (levelDone == nil)
    {
        levelDone = [[NSMutableDictionary alloc] init];
        [levelDone setObject:[NSNumber numberWithInt:level] forKey:@"level"];
        [finishedLevels setObject:levelDone forKey:levelIndex];
    }
    [levelDone release], levelDone = nil;

    [lcs setNextTheme:theme];
    [lcs setNextLevel:level];

    // Update max finished theme + level
    int maxTheme = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MaxTheme"] intValue];
    int maxLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MaxLevel"] intValue];
    if (theme * THEME_MULTIPLIER + level >= maxTheme * THEME_MULTIPLIER + maxLevel)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:theme forKey:@"MaxTheme"];
        [[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"MaxLevel"];
    }


    // Sync settings
    [[NSUserDefaults standardUserDefaults] setObject:finishedLevels forKey:@"FinishedLevels"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [finishedLevels release];


    // Show success view
    [[CCDirector sharedDirector] replaceScene:(CCScene *)lcs];
}



#pragma mark - Loaders


- (void)loadGame
{
    _currScore = 0;
    _maxScore = 0;
    _lastScoreCount = 0;
    _lastScore = 0;

    // Add background
    _backgroundLayer = [BackgroundLayer layer];
    [self addChild:_backgroundLayer z:-20];


    // Game Sheet
    _gameSheet = [GameBatchNode batchNodeWithFile:@"game-objects.pvr" capacity:250];
    [self addChild:_gameSheet z:-2];

    _particleSheet = [CCParticleBatchNode batchNodeWithFile:@"star-glowe.png" capacity:300];
    [self addChild:_particleSheet z:-5];


    // Progress bar
    CCSprite *progressBG = [CCSprite spriteWithSpriteFrameName:@"progress-bar.png"];
    [progressBG setContentSize:CGSizeMake(progressBG.contentSize.width, self.contentSize.height)];
    [progressBG setAnchorPoint:CGPointMake(0, 0)];
    [progressBG setPosition:CGPointMake(self.contentSize.width - progressBG.contentSize.width, 0)];
    [self addChild:progressBG z:10];

    _progressLayer = [CCSprite spriteWithSpriteFrameName:@"progress-bar-pos.png"];
    [_progressLayer setAnchorPoint:CGPointMake(0.5, 1)];
    [_progressLayer setPosition:CGPointMake(progressBG.contentSize.width / 2, progressBG.contentSize.height + _progressLayer.contentSize.height)];
    [progressBG addChild:_progressLayer z:10];


    // Score labels
    _highScoreLabel = [[[CCSpriteFont alloc] initWithFile:@"font1.pvr" plistFile:@"font1.plist" prefix:@"f1-"] autorelease];
    [_highScoreLabel setOpacity:200];
    [_highScoreLabel setText:@"Highscore# 0"];
    [_highScoreLabel setSpacing:-1.0f];
    [_highScoreLabel setAnchorPoint:CGPointMake(0, 1)];
    [_highScoreLabel setPosition:CGPointMake(3, self.contentSize.height - _highScoreLabel.contentSize.height / 2 + 2)];
    [self addChild:_highScoreLabel z:10];

    _currScoreLabel = [[[CCSpriteFont alloc] initWithFile:@"font1.pvr" plistFile:@"font1.plist" prefix:@"f1-"] autorelease];
    [_currScoreLabel setOpacity:200];
    [_currScoreLabel setText:@"Score# 0"];
    [_currScoreLabel setSpacing:-1.0f];
    [_currScoreLabel setAnchorPoint:CGPointMake(0, 1)];
    [_currScoreLabel setPosition:CGPointMake(_highScoreLabel.position.x, _highScoreLabel.position.y - _highScoreLabel.contentSize.height)];
    [self addChild:_currScoreLabel z:10];

    // Add pause layer
    _pauseLayer = [PauseLayer layer];
    [self addChild:_pauseLayer z:101];
}



- (void)addHelp
{
    [_pauseLayer hideMenu];

    CCLayerColor *overlay = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 100)];
    [self addChild:overlay z:14];

    CCSprite *help1 = [CCSprite spriteWithSpriteFrameName:@"help1.png"];
    [help1 setScale:0.0f];
    [help1 setPosition:CGPointMake(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f)];
    [self addChild:help1 z:15];

    CCSprite *help2 = [CCSprite spriteWithSpriteFrameName:@"help2.png"];
    [help2 setPosition:CGPointMake(help1.contentSize.width / 2.0f, help1.contentSize.height / 2.0f)];
    [help1 addChild:help2];

    
    // Scale in
    id cSca1 = [CCScaleTo actionWithDuration:1.0f scale:1.0f];
    id cEase1 = [CCEaseInOut actionWithAction:cSca1 rate:4];
    [help1 runAction:cEase1];

    
    // Rotate and move
    id cRot1 = [CCRotateTo actionWithDuration:0.4f angle:0.0f];
    id cRot2 = [CCRotateTo actionWithDuration:0.4f angle:20.0f];
    id cRot3 = [CCRotateTo actionWithDuration:0.4f angle:-20.0f];

    id cMov2 = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(help2.position.x + 13.0f, help2.position.y)];
    id cMov3 = [CCMoveTo actionWithDuration:0.3f position:CGPointMake(help2.position.x - 10.0f, help2.position.y)];

    id cDelay1 = [CCDelayTime actionWithDuration:0.5f];
    id cDelay2 = [CCDelayTime actionWithDuration:0.8f];

    id cFunc1 = [CCCallBlock actionWithBlock:^{
        [help2 runAction:cMov2];
    }];
    id cFunc2 = [CCCallBlock actionWithBlock:^{
        [help2 runAction:cMov3];
    }];
    id cFunc3 = [CCCallBlock actionWithBlock:^{
        id cSca1 = [CCScaleTo actionWithDuration:1.0f scale:0.0f];
        id cEase1 = [CCEaseInOut actionWithAction:cSca1 rate:4];
        id cFunc1 = [CCCallBlock actionWithBlock:^{
            [help1 removeFromParentAndCleanup:YES];
            [overlay removeFromParentAndCleanup:YES];

            [_pauseLayer showMenu];
            [self scheduleUpdate];
        }];
        id cSeq1 = [CCSequence actions:cEase1, cFunc1, nil];
        [help1 runAction:cSeq1];
    }];

    id cSeq1 = [CCSequence actions:cDelay2, cRot2, cFunc1, cDelay1, cRot1, [[cDelay1 copy] autorelease], cRot3, cFunc2, [[cDelay1 copy] autorelease], [[cRot1 copy] autorelease], nil];
    id cRep1 = [CCRepeat actionWithAction:cSeq1 times:1];
    id cSeq2 = [CCSequence actions:cRep1, cFunc3, nil];

    [help1 runAction:cSeq2];
}


- (void)addRandomCoins
{
    NSMutableArray *coins = [NSMutableArray array];
    PhysicsSprite *handle = nil;
    PhysicsSprite *cage = nil;

    PhysicsSprite *sprite = nil;
    CCARRAY_FOREACH(_gameSheet.children, sprite)
    {
        if ([sprite isKindOfClass:[PhysicsSprite class]] == NO || sprite.spriteId != _randomCoinSpriteId)
        {
            continue;
        }

        if (sprite.tag == TAG_COIN)
        {
            [coins addObject:sprite];
        }

        if (sprite.tag == 2011)
        {
            cage = sprite;
        }

        if (sprite.tag == 2010)
        {
            handle = sprite;
        }
    }

    if (handle != nil)
    {
        id cRot1 = [CCRotateTo actionWithDuration:0.3 angle:0];
        id cFunc1 = [CCCallBlock actionWithBlock:^{
            [[cage getChildByTag:1] setRotation:90.0];
            [[cage getChildByTag:2] setRotation:-90.0];
            for (PhysicsSprite *sprite in coins)
            {
                _contactListener->changeTypeDynamic.push_back(sprite.body);
            }
        }];
        id cSeq1 = [CCSequence actions:cRot1, cFunc1, nil];
        [handle runAction:cSeq1];
    }
}


- (void)initPhysics
{
	_world = new b2World(b2Vec2(0.0f, [SharedActions sharedActions].gravityY));
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);

    _contactListener = new MyContactListener();
    _contactListener->gameLayer = self;
    _world->SetContactListener(_contactListener);

    
//    // Enable debug draw
//    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//    _world->SetDebugDraw(m_debugDraw);
//
//	uint32 flags = 0;
//	flags += b2Draw::e_shapeBit;
//    flags += b2Draw::e_jointBit;
////    flags += b2Draw::e_aabbBit;
////    flags += b2Draw::e_pairBit;
////    flags += b2Draw::e_centerOfMassBit;
//	m_debugDraw->SetFlags(flags);
}


//- (void)draw
//{
//	[super draw];
//
//    if (m_debugDraw != nil)
//    {
//        ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
//        kmGLPushMatrix();
//        _world->DrawDebugData();
//        kmGLPopMatrix();
//    }
//}


- (void)addCandy
{
    // Add top tree
    CCSprite *topTree = [CCSprite spriteWithSpriteFrameName:@"tree-top.png"];
    [topTree setPosition:CGPointMake(topTree.contentSize.width / 2, self.contentSize.height - topTree.contentSize.height / 2)];
    [_gameSheet addChild:topTree];


    // Add candy
    _candySprite = [CandySprite spriteWithSpriteFrameName:@"candy.png"];
    [_candySprite setSurfaceVelocity:b2Vec2(0, 0)];
    [_candySprite setTag:TAG_CANDY];

    // Define the dynamic body
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    bodyDef.allowSleep = false;
    bodyDef.userData = _candySprite;
    bodyDef.linearDamping = [SharedActions sharedActions].damping;
	b2Body *candyBody = _world->CreateBody(&bodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:candyBody forShapeName:@"candy"];

    [_candySprite setBody:candyBody];
    [_candySprite setPosition:CGPointMake(356 / 2, self.contentSize.height - 252 / 2)];
    [_gameSheet addChild:_candySprite z:-5];

    _candyOverlaySprite = [CCSprite spriteWithSpriteFrameName:@"candy-overlay.png"];
    [_candyOverlaySprite setPosition:_candySprite.position];
    [_gameSheet addChild:_candyOverlaySprite z:-5];
}



- (void)addGroundAtPoint:(CGPoint)point
{
    point.y += 20;

    _characterSprite = [PhysicsSprite spriteWithSpriteFrameName:@"lacis-1.png"];
    [_characterSprite setTag:TAG_CHARACTER];
    [_characterSprite setAnchorPoint:CGPointMake(0.5, 0.0)];
    [_characterSprite setPosition:point];

    b2BodyDef snailBodyDef;
    snailBodyDef.type = b2_staticBody;
    snailBodyDef.userData = _characterSprite;
    snailBodyDef.position = b2Vec2(_characterSprite.position.x / PTM_RATIO, _characterSprite.position.y / PTM_RATIO);
    b2Body *snailBody = _world->CreateBody(&snailBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:snailBody forShapeName:@"lacis"];

    [_characterSprite setBody:snailBody];
    [_gameSheet addChild:_characterSprite z:-10];


    // Animate bored
    [_characterSprite runAction:[[SharedActions sharedActions] characterBored]];


    // Feet and shadow
    CCSprite *feetShadowSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-ena.png"];
    [feetShadowSprite setAnchorPoint:CGPointMake(0.5, 0)];
    [feetShadowSprite setPosition:_characterSprite.position];
    [_gameSheet addChild:feetShadowSprite z:-11];

    CCSprite *feetSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-kajas.png"];
    [feetSprite setAnchorPoint:CGPointMake(0.5, 0)];
    [feetSprite setPosition:_characterSprite.position];
    [_gameSheet addChild:feetSprite z:-8];
}



- (void)generateLevel
{
    // -- Load pre-generated levels and finished levels
    NSString *theme_index = [NSString stringWithFormat:@"%d", _theme];
    NSString *level_index = [NSString stringWithFormat:@"%d", _level];

    NSDictionary *levels = [[SharedActions sharedActions] loadLevels];
    NSAssert(levels != nil, @"Levels are not loaded, probably a missing Levels.plist file");

    NSDictionary *theme = [levels objectForKey:theme_index];
    NSAssert(theme != nil, ([NSString stringWithFormat:@"Missing theme: %@", theme_index]));

    NSDictionary *level = [theme objectForKey:level_index];
    NSAssert(level != nil, ([NSString stringWithFormat:@"Missing level: %@", level_index]));

    // Finished levels
    NSDictionary *finishedLevels = [[NSUserDefaults standardUserDefaults] objectForKey:@"FinishedLevels"];
    NSDictionary *level_done = [finishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", _theme, _level]];

    // -- Set track length and speed
    _scrollSpeed = [[level objectForKey:@"Speed"] intValue];
    _checkpoints = [[NSMutableSet alloc] init];

    if (_removedObjects == nil)
    {
        _removedObjects = [[NSMutableSet alloc] init];
    }


    // -- Add candy
    [self addCandy];


    // -- Add our character
    float length = [[level objectForKey:@"Length"] floatValue];
    CGPoint groundMidPoint = CGPointMake(self.contentSize.width / 2, self.contentSize.height - length);
    [self addGroundAtPoint:groundMidPoint];


    // -- SCORE
    if (level_done)
    {
        _currHighScore = [[level_done objectForKey:@"score"] intValue];
    }
    if (_currHighScore > 0)
    {
        [_highScoreLabel setText:[NSString stringWithFormat:@"Highscore# %d", _currHighScore]];
    }
    else
    {
        [_currScoreLabel setPosition:CGPointMake(_currScoreLabel.position.x, _currScoreLabel.position.y + _highScoreLabel.contentSize.height)];
        [_highScoreLabel removeFromParentAndCleanup:YES], _highScoreLabel = nil;
    }


    // -- Loop through all other objects
    int spriteId = 0;
    NSArray *objects = [level objectForKey:@"Objects"];
    for (NSDictionary *the_object in objects)
    {
        spriteId += 1;
        int tag = [[the_object objectForKey:@"Tag"] integerValue];
        NSString *pointString = [the_object objectForKey:@"Point"];
        CGPoint objectPoint = rCGPoint(CGPointFromString(pointString));
        NSString *name = [the_object objectForKey:@"Name"];


        // Special objects
        switch (tag)
        {
            // Checkpoint
            case 700:
            {
                [_checkpoints addObject:[NSValue valueWithCGPoint:objectPoint]];
                continue;
                break;
            }

            case 1025:
            {
                // BG
                PhysicsSprite *objectSprite = [PhysicsSprite spriteWithSpriteFrameName:@"sling-bg.png"];
                [objectSprite setTag:tag];
                [objectSprite setSpriteId:spriteId];
                [objectSprite setPosition:objectPoint];
                [_gameSheet addChild:objectSprite];

                // Branch
                spriteId += 1;
                PhysicsSprite *branchSprite = [PhysicsSprite spriteWithSpriteFrameName:@"sling-branch2.png"];
                [branchSprite setTag:tag];
                [branchSprite setSpriteId:spriteId];
                [branchSprite setPosition:CGPointMake(objectPoint.x + 36, objectPoint.y - 6)];

                b2BodyDef branchBodyDef;
                branchBodyDef.type = b2_kinematicBody;
                branchBodyDef.userData = branchSprite;
                branchBodyDef.position = b2Vec2(branchSprite.position.x / PTM_RATIO, branchSprite.position.y / PTM_RATIO);
                b2Body *branchBody = _world->CreateBody(&branchBodyDef);
                branchBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:branchBody forShapeName:@"sling-branch2"];

                [branchSprite setBody:branchBody];
                [_gameSheet addChild:branchSprite];


                // Top gear
                spriteId += 1;
                PhysicsSprite *topGear = [PhysicsSprite spriteWithSpriteFrameName:@"sling-top-gear.png"];
                [topGear setTag:tag];
                [topGear setSpriteId:spriteId];
                [topGear setPosition:CGPointMake(objectPoint.x - 8, objectPoint.y + 32.5f)];

                b2BodyDef topGearBodyDef;
                topGearBodyDef.type = b2_kinematicBody;
                topGearBodyDef.userData = topGear;
                topGearBodyDef.position = b2Vec2(topGear.position.x / PTM_RATIO, topGear.position.y / PTM_RATIO);
                b2Body *topGearBody = _world->CreateBody(&topGearBodyDef);
                topGearBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:topGearBody forShapeName:@"sling-top-gear"];
                
                [topGear setBody:topGearBody];
                [_gameSheet addChild:topGear];


                // Middle gear
                spriteId += 1;
                PhysicsSprite *middleGear = [PhysicsSprite spriteWithSpriteFrameName:@"sling-middle-gear.png"];
                [middleGear setTag:tag];
                [middleGear setSpriteId:spriteId];
                [middleGear setPosition:CGPointMake(objectPoint.x, objectPoint.y + 6.5f)];

                b2BodyDef middleGearBodyDef;
                middleGearBodyDef.type = b2_kinematicBody;
                middleGearBodyDef.userData = middleGear;
                middleGearBodyDef.position = b2Vec2(middleGear.position.x / PTM_RATIO, middleGear.position.y / PTM_RATIO);
                b2Body *middleGearBody = _world->CreateBody(&middleGearBodyDef);
                middleGearBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:middleGearBody forShapeName:@"sling-middle-gear"];

                [middleGear setBody:middleGearBody];
                [_gameSheet addChild:middleGear];


                // Bottom gear
                spriteId += 1;
                PhysicsSprite *bottomGear = [PhysicsSprite spriteWithSpriteFrameName:@"sling-bottom-gear.png"];
                [bottomGear setTag:tag];
                [bottomGear setSpriteId:spriteId];
                [bottomGear setPosition:CGPointMake(objectPoint.x + 11, objectPoint.y - 21.5f)];

                b2BodyDef bottomGearBodyDef;
                bottomGearBodyDef.type = b2_kinematicBody;
                bottomGearBodyDef.userData = bottomGear;
                bottomGearBodyDef.position = b2Vec2(bottomGear.position.x / PTM_RATIO, bottomGear.position.y / PTM_RATIO);
                b2Body *bottomGearBody = _world->CreateBody(&bottomGearBodyDef);
                bottomGearBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:bottomGearBody forShapeName:@"sling-bottom-gear"];

                [bottomGear setBody:bottomGearBody];
                [_gameSheet addChild:bottomGear];


                // Animate
                id cDelay1 = [CCDelayTime actionWithDuration:3.0f];
                id cDelay2 = [CCDelayTime actionWithDuration:2.0f];
                id cFunc1 = [CCCallBlock actionWithBlock:^{
                    float time1 = 1.2f;
                    id cRot1 = [CCRotateBy actionWithDuration:time1 angle:360];
                    id cRot2 = [CCRotateBy actionWithDuration:time1 angle:420];
                    id cRot3 = [CCRotateBy actionWithDuration:time1 angle:-360];

                    [topGear runAction:cRot1];
                    [middleGear runAction:cRot2];
                    [bottomGear runAction:cRot3];

//                    id cMov1 = [CCMoveTo actionWithDuration:time1 position:CGPointMake(branchSprite.position.x - 60, branchSprite.position.y - 28)];
                    id cMov1 = [CCMoveTo actionWithDuration:time1 position:CGPointMake(branchSprite.position.x - 60, branchSprite.position.y)];
//                    id cRot4 = [CCRotateTo actionWithDuration:time1 angle:-5];
                    [branchSprite runAction:cMov1];
//                    [branchSprite runAction:cRot4];
                }];

                id cFunc2 = [CCCallBlock actionWithBlock:^{
                    float time1 = 0.2f;
                    id cRot1 = [CCRotateBy actionWithDuration:time1 angle:-360];
                    id cRot2 = [CCRotateBy actionWithDuration:time1 angle:-420];
                    id cRot3 = [CCRotateBy actionWithDuration:time1 angle:360];

                    [topGear runAction:cRot1];
                    [middleGear runAction:cRot2];
                    [bottomGear runAction:cRot3];

                    id cMov1 = [CCMoveTo actionWithDuration:time1 position:CGPointMake(branchSprite.position.x + 60, branchSprite.position.y)];
//                    id cRot4 = [CCRotateTo actionWithDuration:time1 angle:0];
                    [branchSprite runAction:cMov1];
//                    [branchSprite runAction:cRot4];
                }];

                id cSeq1 = [CCSequence actions:cDelay1, cFunc1, cDelay2, cFunc2, nil];
                id cRep1 = [CCRepeatForever actionWithAction:cSeq1];
                [objectSprite runAction:cRep1];
                continue;
                break;
            }


            // Cage
            // 2011 is also reserved by cage
            case 2010:
            {
                // Make an ordinary object
                PhysicsSprite *objectSprite = [PhysicsSprite spriteWithSpriteFrameName:[name stringByAppendingString:@".png"]];
                [objectSprite setTag:tag + 1];
                [objectSprite setSpriteId:spriteId];
                [objectSprite setPosition:objectPoint];
                [_gameSheet addChild:objectSprite z:-7];

                b2BodyDef cageBodyDef;
                cageBodyDef.type = b2_kinematicBody;
                cageBodyDef.userData = objectSprite;
                cageBodyDef.position = b2Vec2(objectSprite.position.x / PTM_RATIO, objectSprite.position.y / PTM_RATIO);
                b2Body *cageBody = _world->CreateBody(&cageBodyDef);
                cageBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:cageBody forShapeName:@"cage"];
                [objectSprite setBody:cageBody];


                CCSprite *leftGate = [CCSprite spriteWithSpriteFrameName:@"cage-left-gate.png"];
                [leftGate setTag:1];
                [leftGate setAnchorPoint:CGPointMake(0.204, 0.5)];
                [leftGate setPosition:CGPointMake(objectSprite.contentSize.width / 2 - 25, objectSprite.contentSize.height / 2 - 20)];
                [objectSprite addChild:leftGate];


                CCSprite *rightGate = [CCSprite spriteWithSpriteFrameName:@"cage-right-gate.png"];
                [rightGate setTag:2];
                [rightGate setAnchorPoint:CGPointMake(0.791, 0.5)];
                [rightGate setPosition:CGPointMake(objectSprite.contentSize.width / 2 + 25, objectSprite.contentSize.height / 2 - 20)];
                [objectSprite addChild:rightGate];


                // Handle
                PhysicsSprite *handle = [PhysicsSprite spriteWithSpriteFrameName:@"cage-handle.png"];
                [handle setTag:tag];
                [handle setSpriteId:spriteId];
                [handle setAnchorPoint:CGPointMake(0.125, 0.5)];
                [handle setPosition:CGPointMake(objectSprite.position.x, objectSprite.position.y + 16.0)];
                [handle setRotation:-45.0];

                b2BodyDef brickBodyDef;
                brickBodyDef.type = b2_kinematicBody;
                brickBodyDef.userData = handle;
                brickBodyDef.position = b2Vec2(handle.position.x / PTM_RATIO, handle.position.y / PTM_RATIO);
                b2Body *brickBody = _world->CreateBody(&brickBodyDef);
                brickBody->SetActive(NO);
                [[GB2ShapeCache sharedShapeCache] addFixturesToBody:brickBody forShapeName:@"cage-handle"];

                [handle setBody:brickBody];
                [_gameSheet addChild:handle z:-7];


                // Coins
                for (int i = 1; i <= 20; ++i)
                {
                    // Random
                    int x = (arc4random() % (12 - (-12) + 1)) + (-12);

                    // Make an object
                    PhysicsSprite *coinSprite = [PhysicsSprite spriteWithSpriteFrameName:@"coin-1.png"];
                    [coinSprite setTag:TAG_COIN];
                    [coinSprite setSpriteId:spriteId];
                    [coinSprite setPosition:CGPointMake(objectSprite.position.x + x, objectSprite.position.y - 8)];

                    b2BodyDef brickBodyDef;
                    brickBodyDef.type = b2_staticBody;
                    brickBodyDef.allowSleep = true;
                    brickBodyDef.userData = coinSprite;
                    brickBodyDef.position = b2Vec2(coinSprite.position.x / PTM_RATIO, (self.contentSize.height - coinSprite.contentSize.height) / PTM_RATIO);
                    b2Body *brickBody = _world->CreateBody(&brickBodyDef);
                    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:brickBody forShapeName:@"coin-1"];

                    b2Fixture* f = brickBody->GetFixtureList();
                    f->SetSensor(NO);
                    
                    [coinSprite setBody:brickBody];
                    [_gameSheet addChild:coinSprite z:-8];
                    
                    [coinSprite setScore:100];
                    _maxScore += coinSprite.score;
                }

                continue;
                break;
            }
        }



        // Make an ordinary object
        PhysicsSprite *objectSprite = [PhysicsSprite spriteWithSpriteFrameName:[name stringByAppendingString:@".png"]];
        [objectSprite setTag:tag];
        [objectSprite setSpriteId:spriteId];
        [objectSprite setPosition:objectPoint];

        b2BodyDef brickBodyDef;
        brickBodyDef.type = b2_kinematicBody;
        brickBodyDef.userData = objectSprite;
        brickBodyDef.position = b2Vec2(objectSprite.position.x / PTM_RATIO, objectSprite.position.y / PTM_RATIO);
        b2Body *brickBody = _world->CreateBody(&brickBodyDef);
        brickBody->SetActive(NO);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:brickBody forShapeName:name];

        [objectSprite setBody:brickBody];
        [_gameSheet addChild:objectSprite];


        // Set some properties
        switch (tag)
        {
            case TAG_BAD_BRICK_1:
            case TAG_BAD_BRICK_2:
            {
                [objectSprite setScore:50];
                _maxScore += objectSprite.score;
                break;
            }

            case TAG_BRICK_MOVING_LEFT:
            {
                id cMov1 = [CCMoveByXY actionWithDuration:2.0 position:CGPointMake(-70, 0)];
                id cMov2 = [CCMoveByXY actionWithDuration:2.0 position:CGPointMake(70, 0)];
                id cSeq1 = [CCSequence actions:cMov1, cMov2, nil];
                id cRep1 = [CCRepeatForever actionWithAction:cSeq1];
                [objectSprite runAction:cRep1];
                break;
            }

            case TAG_BRICK_MOVING_RIGHT:
            {
                id cMov1 = [CCMoveByXY actionWithDuration:2.0 position:CGPointMake(70, 0)];
                id cMov2 = [CCMoveByXY actionWithDuration:2.0 position:CGPointMake(-70, 0)];
                id cSeq1 = [CCSequence actions:cMov1, cMov2, nil];
                id cRep1 = [CCRepeatForever actionWithAction:cSeq1];
                [objectSprite runAction:cRep1];
                break;
            }


            case 1023:
            case 1024:
            {
                // Add objects
                CCSprite *rope = [CCSprite spriteWithSpriteFrameName:@"b11-rope1.png"];
                [rope setPosition:CGPointMake(objectSprite.contentSize.width / 2, objectSprite.contentSize.height / 2)];
                [objectSprite addChild:rope];

                CCSprite *gearLeft = [CCSprite spriteWithSpriteFrameName:@"b11-gear-left.png"];
                [gearLeft setPosition:CGPointMake(gearLeft.contentSize.width / 2, objectSprite.contentSize.height - gearLeft.contentSize.height / 2)];
                [objectSprite addChild:gearLeft];

                CCSprite *gearRight = [CCSprite spriteWithSpriteFrameName:@"b11-gear-right.png"];
                [gearRight setPosition:CGPointMake(objectSprite.contentSize.width - gearRight.contentSize.width / 2, objectSprite.contentSize.height - gearRight.contentSize.height / 2)];
                [objectSprite addChild:gearRight];

                // Set rotation direction
                [objectSprite setCustomVariable1:(objectSprite.tag == 1023 ? -1 : 1)];

                // Animate
                NSMutableArray *animationFrames = [NSMutableArray array];

                if (objectSprite.customVariable1 == 1)
                {
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"b11-rope1.png"]];
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"b11-rope2.png"]];
                }
                else
                {
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"b11-rope2.png"]];
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"b11-rope1.png"]];
                }

                CCAnimation *ropeAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.09f];
                id cAni = [CCAnimate actionWithAnimation:ropeAnimation];
                [rope runAction:[CCRepeatForever actionWithAction:cAni]];


                id cRot1 = [CCRotateBy actionWithDuration:1.0 angle:objectSprite.customVariable1 * 360];
                [gearLeft runAction:[CCRepeatForever actionWithAction:cRot1]];
                [gearRight runAction:[CCRepeatForever actionWithAction:[[cRot1 copy] autorelease]]];
                break;
            }


            // Radioactive brick
            case 1026:
            {
                ccColor3B oldColor = objectSprite.color;
                id fadeToIn = [CCTintTo actionWithDuration:0.8 red:255 green:0 blue:0];
                id fadeToOut = [CCTintTo actionWithDuration:0.8 red:oldColor.r green:oldColor.g blue:oldColor.b];
                [objectSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:fadeToIn two:fadeToOut]]];

                id scaleDown = [CCScaleTo actionWithDuration:0.8 scale:0.95];
                id scaleUp = [CCScaleTo actionWithDuration:0.8 scale:1.0];
                [objectSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:scaleDown two:scaleUp]]];
                break;
            }


            // Snakes
            case 1005:
            case 1006:
            case 1007:
            {
                CCSprite *eyes = [CCSprite spriteWithSpriteFrameName:@"cuska-acis.png"];
                [eyes setPosition:CGPointMake(objectSprite.contentSize.width / 2, objectSprite.contentSize.height / 2)];
                [objectSprite addChild:eyes z:0 tag:1];
                break;
            }

            case TAG_DART_0:
            case TAG_DART_1:
            case TAG_DART_3:
            case TAG_DART_4:
            {
                id cRot1 = [CCRotateBy actionWithDuration:0.9 angle:360];
                id cRep1 = [CCRepeatForever actionWithAction:cRot1];
                [objectSprite runAction:cRep1];
                break;
            }


            // Cave
            case 3011:
            {
                CCSprite *eyes = [CCSprite spriteWithSpriteFrameName:@"cave-eyes.png"];
                [eyes setPosition:CGPointMake(objectSprite.contentSize.width / 2 + 5, 25.0f)];
                [eyes setOpacity:0];
                [eyes setTag:1];
                [objectSprite addChild:eyes];
                [objectSprite.parent reorderChild:objectSprite z:-7];

                id cFade0 = [CCFadeTo actionWithDuration:0.4 opacity:255];
                id cFade1 = [CCFadeTo actionWithDuration:0.01 opacity:255];
                id cFade2 = [CCFadeTo actionWithDuration:0.01 opacity:0];
                id cFade3 = [CCFadeTo actionWithDuration:0.4 opacity:0];

                id cDelay1 = [CCDelayTime actionWithDuration:1.5f];
                id cDelay2 = [CCDelayTime actionWithDuration:0.1f];
                id cDelay3 = [CCDelayTime actionWithDuration:3.0f];

                id cMov1 = [CCMoveTo actionWithDuration:0.3 position:CGPointMake(eyes.position.x - 5, eyes.position.y)];
                id cMov2 = [CCMoveTo actionWithDuration:0.3 position:CGPointMake(eyes.position.x, eyes.position.y)];

                id cSpawn1 = [CCSpawn actions:cFade0, cMov1, nil];
                id cSpawn2 = [CCSpawn actions:cFade3, cMov2, nil];

                id cSeq = [CCSequence actions:cSpawn1, cDelay1, cFade2, cDelay2, cFade1, [[cDelay3 copy] autorelease], cSpawn2, cDelay3, nil];
                id cRep = [CCRepeatForever actionWithAction:cSeq];
                [eyes runAction:cRep];
                break;
            }


            case TAG_COIN:
            {
                [objectSprite setScore:100];
                _maxScore += objectSprite.score;

                // Add some animation
                NSMutableArray *animationFrames = [NSMutableArray array];
                for (int i = 1; i <= 7; i++)
                {
                    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"coin-%d.png", i]]];
                }
                CCAnimation *coinAnimation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
                id cAni = [CCAnimate actionWithAnimation:coinAnimation];
                [objectSprite runAction:[CCRepeatForever actionWithAction:cAni]];
                break;
            }


            case TAG_STAR:
            {
                [objectSprite setScore:500];
                _maxScore += objectSprite.score;

                id cMov1 = [CCMoveTo actionWithDuration:0.7 position:CGPointMake(objectSprite.position.x, objectSprite.position.y + 5)];
                id cMov2 = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(objectSprite.position.x, objectSprite.position.y)];
                id cSeq = [CCSequence actions:cMov1, cMov2, nil];
                [objectSprite runAction:[CCRepeatForever actionWithAction:cSeq]];

                CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"star-glowe.plist"];
                [particle setPosition:objectSprite.position];
                [particle setTag:spriteId];
                [_particleSheet addChild:particle];
                break;
            }


            case TAG_WHALE:
            {
                // Eye
                CCSprite *eye = [CCSprite spriteWithSpriteFrameName:@"whale-eye.png"];
                [eye setPosition:CGPointMake(objectSprite.contentSize.width / 2, objectSprite.contentSize.height / 2)];
                [objectSprite addChild:eye];

                id cMov1 = [CCMoveTo actionWithDuration:0.7 position:CGPointMake(eye.position.x - 1, eye.position.y - 2)];
                id cMov2 = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(eye.position.x + 2, eye.position.y - 2)];
                id cMov3 = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(eye.position.x + 1, eye.position.y - 2)];
                id cMov4 = [CCMoveTo actionWithDuration:0.9 position:CGPointMake(eye.position.x, eye.position.y)];

                id cDelay1 = [CCDelayTime actionWithDuration:1.0];
                id cDelay2 = [CCDelayTime actionWithDuration:2.5];
                id cDelay3 = [CCDelayTime actionWithDuration:0.3];

                id cSeq1 = [CCSequence actions:cMov1, cDelay1, cMov2, cDelay3, cMov3, [[cDelay1 copy] autorelease], cMov4, cDelay2, nil];
                id cRep1 = [CCRepeatForever actionWithAction:cSeq1];
                [eye runAction:cRep1];


                // Update the body to dynamic one
                objectSprite.body->SetType(b2_dynamicBody);

                // Shape
                b2CircleShape circleShape;
                circleShape.m_radius = 0.2;

                // Fixture
                b2FixtureDef fixtureDef;
                fixtureDef.isSensor = YES;
                fixtureDef.shape = &circleShape;
                fixtureDef.density = 20;

                // New static body where to attach to
                b2BodyDef newBodyDef;
                newBodyDef.type = b2_kinematicBody;
                newBodyDef.position = b2Vec2(objectSprite.position.x / PTM_RATIO, (objectSprite.position.y + objectSprite.contentSize.height / 2) / PTM_RATIO);
                b2Body *newBody = _world->CreateBody(&newBodyDef);
                newBody->CreateFixture(&fixtureDef);
                [objectSprite setBody2:newBody];

                // Create a joint
                b2RevoluteJointDef rjd;
                rjd.Initialize(newBody, objectSprite.body, b2Vec2(objectSprite.position.x / PTM_RATIO, (objectSprite.position.y + objectSprite.contentSize.height / 2) / PTM_RATIO));
                rjd.enableLimit = YES;
                rjd.lowerAngle = -45 * (M_PI / 180);
                rjd.upperAngle = 45 * (M_PI / 180);
                rjd.enableMotor = YES;
                rjd.motorSpeed = -1;
                rjd.maxMotorTorque = 1.0f;
                _world->CreateJoint(&rjd);
                break;
            }
        }
    } // End of the object for loop


    // -- Set background position
    [_backgroundLayer setContentSize:CGSizeMake(_backgroundLayer.contentSize.width, length)];
    [_backgroundLayer setPosition:CGPointMake(rToCenter(_backgroundLayer.contentSize.width, self.contentSize.width), self.contentSize.height - length)];


    // Add some stuff in front
    CCSprite *flower = [CCSprite spriteWithSpriteFrameName:@"flowers1.png"];
    [flower setPosition:CGPointMake(flower.contentSize.width / 2, _backgroundLayer.position.y + flower.contentSize.height / 2)];
    [_gameSheet addChild:flower];

    CCSprite *flower2 = [CCSprite spriteWithSpriteFrameName:@"flowers2.png"];
    [flower2 setPosition:CGPointMake(self.contentSize.width - flower2.contentSize.width / 2 - 5, _backgroundLayer.position.y + flower2.contentSize.height / 2)];
    [_gameSheet addChild:flower2];
}



#pragma mark - Tick


- (void)onEnter
{
    [super onEnter];

    if (_theme == 1 && _level == 1)
    {
        [self addHelp];
    }
    else
    {
        double delayInSeconds = 1.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self scheduleUpdate];
        });
    }
}



- (void)update:(ccTime)dt
{
    // !! Step the world
    dt = 1.0/60;
    int32 velocityIterations = 3;
    int32 positionIterations = 8;
	_world->Step(dt, velocityIterations, positionIterations);

    
    // Remove collided objects (if any)
    std::vector<b2Body *>::iterator pos;
    for(pos = _contactListener->toDestroy.begin(); pos != _contactListener->toDestroy.end(); ++pos)
    {
        b2Body *body = *pos;
        _world->DestroyBody(body);
    }
    _contactListener->toDestroy.clear();


    // Change object type to dynamic
    for(pos = _contactListener->changeTypeDynamic.begin(); pos != _contactListener->changeTypeDynamic.end(); ++pos)
    {
        b2Body *body = *pos;
        body->SetType(b2_dynamicBody);
    }
    _contactListener->changeTypeDynamic.clear();


    // !! Update candy velocity
    float velocity = [SharedActions sharedActions].gravityX * _accelX * dt;
    b2Vec2 v = _candySprite.body->GetLinearVelocity();
    b2Vec2 zero = b2Vec2(velocity, v.y);
    zero += _candySprite.surfaceVelocity;
    _candySprite.body->SetLinearVelocity(zero);


    // !! Move bodies up
    [self updateMoveUp:dt];

    // Update candy overlay position
    [_candyOverlaySprite setPosition:_candySprite.position];


    // Add random coins
    if (_randomCoinSpriteId != 0)
    {
        [self addRandomCoins];
        _randomCoinSpriteId = 0;
    }


    // Open the mouth
    float pos1 = fabsf(_characterSprite.body->GetPosition().y - _candySprite.body->GetPosition().y);
    if (_isHouseOpen == NO && pos1 < 200 / PTM_RATIO)
    {
        [_characterSprite runAction:[[SharedActions sharedActions] characterOpenMouth]];
        _isHouseOpen = YES;
    }


    // Game over
    if (_candySprite.position.x < -_candySprite.contentSize.width || _candySprite.position.x > self.contentSize.width + _candySprite.contentSize.width ||
        _candySprite.position.y + _gameSheet.position.y < -_candySprite.contentSize.height ||
        _candySprite.position.y + _gameSheet.position.y > self.contentSize.height + _candySprite.contentSize.height)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"break.m4a"];
        [self gameFailedWithExplosion:YES];
    }


    // Shake pause button
    [_pauseLayer.pauseButton setRotation:-10 * _accelXButtons];
}


- (void)updateMoveUp:(ccTime)dt
{
    // Move bodies up
    if (_backgroundLayer.position.y < 0)
    {
        float moveBy = (_scrollSpeed * dt);
        if (_gameCompleted == YES)
        {
            moveBy *= 3;
        }
        if (_backgroundLayer.position.y + moveBy > 0)
        {
            moveBy = fabsf(_backgroundLayer.position.y);
        }

        // Move background up
        [_gameSheet setPosition:CGPointMake(_gameSheet.position.x, _gameSheet.position.y + moveBy)];
        [_backgroundLayer setPosition:CGPointMake(_backgroundLayer.position.x, _backgroundLayer.position.y + moveBy)];
        [_particleSheet setPosition:CGPointMake(_particleSheet.position.x, _particleSheet.position.y + moveBy)];


        // Update progress
        float p = (fabsf(_backgroundLayer.position.y)) / (_backgroundLayer.contentSize.height - self.contentSize.height);
        p += (43 / _progressLayer.parent.contentSize.height);
        [_progressLayer setPosition:CGPointMake(_progressLayer.position.x, _progressLayer.parent.contentSize.height * p)];
    }
    else
    {
        [_gameSheet setPosition:CGPointMake(_gameSheet.position.x, _gameSheet.position.y)];
    }
}



- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    _accelX = (acceleration.x * [SharedActions sharedActions].filtering) + (_accelX * (1.0 - [SharedActions sharedActions].filtering));
    _accelXButtons = (acceleration.x * 0.05) + (_accelXButtons * (1.0 - 0.05));
}



//
//CGPoint _originalPoint, _originalPositon;
//
//
//- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	CGPoint touchPoint = [touch locationInView:[touch view]];
//    _originalPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
//	_originalPositon = self.position;
//	return YES;
//}
//
//
//
//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	CGPoint touchPoint = [touch locationInView:[touch view]];
//	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
//
//    float y = _originalPositon.y - (_originalPoint.y - touchPoint.y);
////    if (y < _backgroundLayer.contentSize.height)
////    {
////        y = _backgroundLayer.contentSize.height;
////        // _originalPoint = touchPoint;
////    }
////    else if (y > _backgroundLayer.contentSize.height)
////    {
////        y = _backgroundLayer.contentSize.height;
////    }
//    self.position = ccp(self.position.x, y);
//}
//
//
//
//#pragma mark Touches
//
///** Register with more priority than CCMenu's but don't swallow touches. */
//-(void) registerWithTouchDispatcher
//{
//#if COCOS2D_VERSION >= 0x00020000
//    CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
//    int priority = kCCMenuHandlerPriority - 1;
//#else
//    CCTouchDispatcher *dispatcher = [CCTouchDispatcher sharedDispatcher];
//    int priority = kCCMenuTouchPriority - 1;
//#endif
//
//	[dispatcher addTargetedDelegate:self priority: priority swallowsTouches:NO];
//}


@end
