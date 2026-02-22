//
//  PauseScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "LevelCompletedScene.h"
#import "SharedActions.h"
#import "AnimatedCCMenuItemImage.h"
#import "SimpleAudioEngine.h"
#import "GameScene.h"
#import "LevelsScene.h"
#import "LoaderLayer.h"
#import "CommingSoonScene.h"
#import "Appirater.h"



@implementation LevelCompletedLayer
@synthesize stars = _stars, score = _score, theme = _theme, level = _level, levelNr = _levelNr, nextTheme = _nextTheme, nextLevel = _nextLevel, newHighScore = _newHighScore;

+ (void)loadResources
{
    // Load music
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"timp.m4a"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"stamp.m4a"];

    // Load shared sprite frame cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"level-completed.plist"];

    // Load textures
    [[CCTextureCache sharedTextureCache] addImage:@"level-completed.pvr"];
}

+ (LevelCompletedLayer *)layer
{
	LevelCompletedLayer *layer = [[[LevelCompletedLayer alloc] init] autorelease];
	return layer;
}


+ (LevelCompletedLayer *)sharedLayer
{
    static dispatch_once_t once;
    static LevelCompletedLayer *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[LevelCompletedLayer layer] retain];
    });
    return sharedInstance;
}


- (void)cleanup
{
    // Stop from cleaning up because this should be a shared object
}


- (void)dealloc
{
    [super cleanup]; // Cleanup here, because this supposed to be a shared object
    [super dealloc];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        _screenSize = [[CCDirector sharedDirector] winSize];

        // Game Sheet
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"level-completed.pvr"];
        [self addChild:_batchNode z:-1];


        // bg
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:(self.contentSize.height == 480 ? @"completed-bg-960.png" : @"completed-bg.png")];
        [bg setAnchorPoint:CGPointMake(0.5, 0)];
        [bg setPosition:CGPointMake(_screenSize.width / 2, 0)];
        [_batchNode addChild:bg];


        // Stars
        _starsHolder = [CCSprite spriteWithSpriteFrameName:@"star-holder.png"];
        [_starsHolder setAnchorPoint:CGPointMake(0.5, 1)];
        [_batchNode addChild:_starsHolder];


        _star1 = [CCSprite spriteWithSpriteFrameName:@"star-left.png"];
        [_star1 setOpacity:0.0];
        [_star1 setPosition:CGPointMake(53.5, 67.5)];
        [_starsHolder addChild:_star1];


        _star2 = [CCSprite spriteWithSpriteFrameName:@"star-middle.png"];
        [_star2 setOpacity:0.0];
        [_star2 setPosition:CGPointMake(124.6, 115.3)];
        [_starsHolder addChild:_star2];


        _star3 = [CCSprite spriteWithSpriteFrameName:@"star-right.png"];
        [_star3 setOpacity:0.0];
        [_star3 setPosition:CGPointMake(204, 68.7)];
        [_starsHolder addChild:_star3];


        // Add buttons
        AnimatedCCMenuItemImage *restartButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"lc-restart.png"] selectedSprite:nil block:^(id sender) {
            GameScene *scene = [GameScene sceneWithTheme:_theme andLevel:_level withLevelNr:_levelNr];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
        }];
        [restartButton setButtonSound:@"buttons.m4a"];
        [restartButton setPosition:ccp(65, 140)];
        [restartButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [restartButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        [restartButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];


        AnimatedCCMenuItemImage *menuButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"lc-menu.png"] selectedSprite:nil block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[LevelsScene scene]];

    //        [[LoaderLayer sharedLoaderLayer] showWithScene:scene withLoadingBlock:^{
    //            [scene.layer loadLayer];
    //        } withCallbackBlock:^{
    //            [scene.layer startLayer];
    //        }];
        }];
        [menuButton setButtonSound:@"buttons.m4a"];
        [menuButton setPosition:ccp(255, 140)];
        [menuButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [menuButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        [menuButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];


        AnimatedCCMenuItemImage *nextButton = [AnimatedCCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"lc-next.png"] selectedSprite:nil block:^(id sender) {

            NSDictionary *finishedLevels = [[NSUserDefaults standardUserDefaults] objectForKey:@"FinishedLevels"];
            NSDictionary *level_done = [finishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", _nextTheme, _nextLevel]];

            if (_nextTheme > 7)
            {
                CommingSoonScene *scene = [CommingSoonScene scene];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:scene withColor:ccWHITE]];
            }
            else if (_nextTheme != _theme && (level_done == nil || [level_done objectForKey:@"stars"] == nil))
            {
                [[CCDirector sharedDirector] replaceScene:[LevelsScene scene]];
            }
            else
            {
                GameScene *scene = [GameScene sceneWithTheme:_nextTheme andLevel:_nextLevel withLevelNr:_levelNr + 1];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:scene withColor:ccWHITE]];
            }
        }];
        [nextButton setButtonSound:@"buttons.m4a"];
        [nextButton setPosition:ccp(161, 105)];
        [nextButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [nextButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        [nextButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];


        CCMenu *buttonMenu = [CCMenu menuWithItems:restartButton, nextButton, menuButton, nil];
        buttonMenu.position = CGPointZero;
        [self addChild:buttonMenu];


        // Add score labels
        _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:NSLocalizedString(@"Score: %d", @""), 0] fontName:@"Snickles" fontSize:26.0 dimensions:CGSizeMake(200.0f, 31.0f) hAlignment:kCCTextAlignmentCenter];
        [_scoreLabel setColor:ccc3(64, 33, 10)];
        [_scoreLabel setPosition:CGPointMake(_screenSize.width / 2, 210)];
        [self addChild:_scoreLabel];

        _levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:NSLocalizedString(@"Level %d completed", @""), _level] fontName:@"Snickles" fontSize:26.0 dimensions:CGSizeMake(140, 31) hAlignment:kCCTextAlignmentCenter];
        [_levelLabel setColor:ccc3(64, 33, 10)];
        [_levelLabel setPosition:CGPointMake(_screenSize.width / 2, _scoreLabel.position.y - _scoreLabel.contentSize.height / 1.3)];
        [self addChild:_levelLabel];


        _highScore = [CCSprite spriteWithSpriteFrameName:@"lc-new-highscore.png"];
        [_highScore setPosition:CGPointMake(self.contentSize.width - _highScore.contentSize.width - 10, _scoreLabel.position.y + 5)];
        [_batchNode addChild:_highScore];


        _msgLabel = [CCLabelTTF labelWithString:@"" fontName:@"Snickles" fontSize:47.0 dimensions:CGSizeMake(260, 55) hAlignment:kCCTextAlignmentCenter];
        [_msgLabel setPosition:CGPointMake(self.contentSize.width / 2, _scoreLabel.position.y + _scoreLabel.contentSize.height + 10)];
        [_msgLabel setColor:ccc3(64, 33, 10)];
        [_msgLabel setOpacity:0];
        [self addChild:_msgLabel];
    }
    return self;
}



- (void)onEnter
{
    [super onEnter];
    [_highScore setOpacity:0];

    // Update level and start counting the score
    _currScore = 0;
    _showingStar = 0;
    [_msgLabel setOpacity:0];
    [_levelLabel setString:[NSString stringWithFormat:NSLocalizedString(@"Level %d completed", @""), _levelNr]];
    [_scoreLabel setString:[NSString stringWithFormat:NSLocalizedString(@"Score: %d", @""), 0]];
    [self scheduleUpdate];


    // Start animating the stars
    [_star1 setOpacity:0.0];
    [_star2 setOpacity:0.0];
    [_star3 setOpacity:0.0];

    [_starsHolder setPosition:CGPointMake(_screenSize.width / 2, _screenSize.height + _starsHolder.contentSize.height)];
    id cMov = [CCMoveTo actionWithDuration:1.0 position:CGPointMake(_starsHolder.position.x, _screenSize.height + 10)];
    id cEase = [CCEaseBounceOut actionWithAction:cMov];
    id cFunc = [CCCallBlock actionWithBlock:^{
        [self showStars];
    }];
    id cSeq = [CCSequence actions:cEase, cFunc, nil];
    [_starsHolder runAction:cSeq];


    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Level Completed Scene: %d", _levelNr]];
}



- (void)showStars
{
    if (_showingStar >= self.stars)
    {
        // TODO: Show the message
        NSString *msg;
        switch(self.stars)
        {
            case 0:
                msg = @"";
                break;
            case 1:
                msg = NSLocalizedString(@"Good", @"");
                break;
            case 2:
                msg = NSLocalizedString(@"Very Well", @"");
                break;
            default:
                msg = NSLocalizedString(@"Perfect", @"");
        }
        [_msgLabel setString:msg];

        // Show the label
        id cFad = [CCFadeIn actionWithDuration:0.2];
        id cSca1 = [CCScaleTo actionWithDuration:0.5 scale:1.3];
        id cSca2 = [CCScaleTo actionWithDuration:0.5 scale:1.0];
        id cSeq = [CCSequence actions:cSca1, cSca2, nil];
        [_msgLabel runAction:cFad];
        [_msgLabel runAction:cSeq];

        return;
    }


    // Find correct star
    CCSprite *star;
    if (_showingStar == 0)
    {
        star = _star1;
    }
    else if (_showingStar == 1)
    {
        star = _star2;
    }
    else
    {
        star = _star3;
    }
    _showingStar += 1;


    // Show it
    id cFad = [CCFadeIn actionWithDuration:0.2];
    id cSca = [CCScaleTo actionWithDuration:0.2 scale:1.0];
    id cDelay = [CCDelayTime actionWithDuration:0.2];
    id cFunc = [CCCallBlock actionWithBlock:^{
        [self showStars];
    }];
    id cSeq = [CCSequence actions:cSca, cDelay, cFunc, nil];

    [star setScale:30.0];
    [star runAction:cFad];
    [star runAction:cSeq];

    // Play sound
    [[SimpleAudioEngine sharedEngine] playEffect:@"timp.m4a" pitch:1.2f pan:0.0f gain:1.0f];
}



- (void)update:(ccTime)dt
{
    static float seconds = 2;
    float x = dt * (float)self.score / seconds;

    _currScore = fmin(_currScore + x, self.score);
    [_scoreLabel setString:[NSString stringWithFormat:NSLocalizedString(@"Score: %d", @""), (int)_currScore]];

    if (_currScore >= self.score)
    {
        [self unscheduleUpdate];

        if (_newHighScore == YES)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"stamp.m4a"];

            [_highScore setScale:30.0f];
            [_highScore setOpacity:255];
            id cSca = [CCScaleTo actionWithDuration:0.3 scale:1.0f];
            [_highScore runAction:cSca];
        }

        if (_stars == 3)
        {
            [Appirater userDidSignificantEvent:YES];
        }
    }
}


@end
