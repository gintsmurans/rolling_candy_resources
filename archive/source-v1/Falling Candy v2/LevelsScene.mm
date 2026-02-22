//
//  LevelsScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "LevelsScene.h"
#import "HomeScene.h"
#import "GameScene.h"
#import "SharedActions.h"
#import "SimpleAudioEngine.h"
#import "LMCustomSprite.h"
#import "LoaderLayer.h"
#import "FSNConnection.h"
#import "CCShake.h"
#import "IAPHelper.h"
#import "Spinner.h"
#import "OverlayColorLayer.h"


@implementation LevelsScene
@synthesize layer = _layer;

+ (LevelsScene *)scene
{
 	LevelsScene *scene = [[[LevelsScene alloc] init] autorelease];
	return scene;
}

- (void)dealloc
{
    NSLog(@"Levels Dealloc");
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _layer = [LevelsLayer layer];
        [self addChild:_layer z:0];
    }
    return self;
}
@end



@implementation LevelsLayer
@synthesize preloading = _preloading;

+ (void)loadResources
{
    // Load music

    // Load shared sprite frame cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levels-menu.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levels-menu-bg.plist"];

    // Load textures
    [[CCTextureCache sharedTextureCache] addImage:@"levels-menu-bg.pvr"];
    [[CCTextureCache sharedTextureCache] addImage:@"levels-menu.pvr"];

//    // Other
//    [[NSBundle mainBundle] pathForResource:@"levels-menu-positions" ofType:@"plist"];
}


+ (LevelsLayer *)layer
{
	LevelsLayer *layer = [[[LevelsLayer alloc] init] autorelease];
	return layer;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        // -- Background and flowers
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"lm-bg.png"];
        [bg setPosition:CGPointMake(self.contentSize.width / 2, rToLeft(bg.contentSize.height, self.contentSize.height))];
        [self addChild:bg z:-1];

        CCSprite *flowersSprite = [CCSprite spriteWithSpriteFrameName:@"lm-flowers.png"];
        [flowersSprite setPosition:CGPointMake(self.contentSize.width / 2, flowersSprite.contentSize.height / 2)];
        [self addChild:flowersSprite z:10];


        // -- Scroll layer
        _scrollLayer = [CustomScrollLayer node];
        [_scrollLayer setDelegate:self];
        [_scrollLayer setContentSize:CGSizeMake(self.contentSize.width, 4785 / 2)];
        [_scrollLayer setIgnoreAnchorPointForPosition:NO];
        [_scrollLayer setAnchorPoint:CGPointMake(0.5, 1)];
        [_scrollLayer setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height)];

        [self addChild:_scrollLayer z:0];


        // -- Paper sheet
        CCSpriteBatchNode *bgSheet = [CCSpriteBatchNode batchNodeWithFile:@"levels-menu-bg.pvr"];
        [_scrollLayer addChild:bgSheet z:1];

        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"lm-cels1.png"];
        [bg1 setAnchorPoint:CGPointMake(0.5, 1)];
        [bg1 setPosition:CGPointMake(self.contentSize.width / 2, _scrollLayer.contentSize.height)];
        [bgSheet addChild:bg1];

        CCSprite *bg2 = [CCSprite spriteWithSpriteFrameName:@"lm-cels2.png"];
        [bg2 setAnchorPoint:CGPointMake(0.5, 1)];
        [bg2 setPosition:CGPointMake(bg1.position.x, bg1.position.y - bg1.contentSize.height + 1)];
        [bgSheet addChild:bg2];

        CCSprite *bg3 = [CCSprite spriteWithSpriteFrameName:@"lm-cels3.png"];
        [bg3 setAnchorPoint:CGPointMake(0.5, 1)];
        [bg3 setPosition:CGPointMake(bg2.position.x, bg2.position.y - bg2.contentSize.height + 1)];
        [bgSheet addChild:bg3];


        // -- Levels menu
        _menuSheet = [CCSpriteBatchNode batchNodeWithFile:@"levels-menu.pvr" capacity:250];
        [_scrollLayer addChild:_menuSheet z:20];


        // -- Load item postions
        NSString *path = [[NSBundle mainBundle] pathForResource:@"levels-menu-positions" ofType:@"plist"];
        NSDictionary *items = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];


        // -- Add level buttons
        BOOL isLevelUnlocked =  [[IAPHelper sharedInstance] isProductIdentifierPurchased:@"PUnlockAllLevels"];
        BOOL nextLevelUnlockButton = YES;
        BOOL isLevelDone;
        int stars;
        int levelNr = 0;

        NSString *spriteName;
        NSDictionary *levelDone;
        NSDictionary *finishedLevels = [[NSUserDefaults standardUserDefaults] objectForKey:@"FinishedLevels"];
        if (finishedLevels == nil)
        {
            finishedLevels = [NSDictionary dictionary];
        }

        for (int theme = 1; theme <= TOTAL_THEMES; ++theme)
        {
            for (int level = 1; level <= TOTAL_LEVELS; ++level)
            {
                levelNr++;
                stars = 0;
                // isLevelUnlocked = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"unlocked:%d:%d", theme, level]];
                levelDone = [finishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", theme, level]];
                
                if (levelDone != nil)
                {
                    stars = [[levelDone objectForKey:@"stars"] intValue];
                    isLevelDone = YES;
                }
                else if (theme == 1 && level == 1)
                {
                    isLevelDone = YES;
                }
                else
                {
                    isLevelDone = NO;
                }


                // Load sprite
                spriteName = [NSString stringWithFormat:@"lm-%d.%d.png", theme, level];
                NSDictionary *settings = [items objectForKey:spriteName];
                CGPoint point = CGPointFromString([settings objectForKey:@"position"]);


                if ((theme == 1 && level != 1) || theme != 1)
                {
                    spriteName = [NSString stringWithFormat:@"lm-%d.%dsepia.png", theme, level];
                }

                LMCustomSprite *sprite = [LMCustomSprite spriteWithSpriteFrameName:spriteName];
                [sprite setEnabledFrameName:[NSString stringWithFormat:@"lm-%d.%d.png", theme, level]];
                [sprite setDisabled:!isLevelDone && !isLevelUnlocked];
                [sprite setDone:isLevelDone || isLevelUnlocked];
                [sprite setPosition:CGPointMake(point.x / 2, _scrollLayer.contentSize.height - point.y / 2)];
                [sprite setTag:theme * THEME_MULTIPLIER + level];
                [sprite setTouchUpBlock:^(){
                    GameScene *scene = [GameScene sceneWithTheme:theme andLevel:level withLevelNr:levelNr];
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:scene withColor:ccWHITE]];
                }];
                [_menuSheet addChild:sprite];


                // Level number and stars
                if (isLevelDone == YES || isLevelUnlocked == YES)
                {
                    _theme = theme;
                    _level = level;

                    // Level nr
                    spriteName = [NSString stringWithFormat:@"lm-n%d.png", levelNr];
                    settings = [items objectForKey:spriteName];
                    point = CGPointFromString([settings objectForKey:@"position"]);
                    CCSprite *nrSprite = [CCSprite spriteWithSpriteFrameName:spriteName];
                    [nrSprite setPosition:CGPointMake(point.x / 2, _scrollLayer.contentSize.height - point.y / 2)];
                    [_menuSheet addChild:nrSprite];

                    NSString *starName = (stars > 0 ? @"lm-star-left.png" : @"lm-star-left-inactive.png");
                    CCSprite *star1 = [CCSprite spriteWithSpriteFrameName:starName];
                    [star1 setOpacity:(stars > 0 ? 255 : 150)];
                    [star1 setPosition:CGPointMake(sprite.position.x - star1.contentSize.width, sprite.position.y + sprite.contentSize.height / 2 + star1.contentSize.height / 2 - 2)];
                    [_menuSheet addChild:star1];

                    starName = (stars > 1 ? @"lm-star-center.png" : @"lm-star-center-inactive.png");
                    CCSprite *star2 = [CCSprite spriteWithSpriteFrameName:starName];
                    [star2 setOpacity:(stars > 1 ? 255 : 150)];
                    [star2 setPosition:CGPointMake(sprite.position.x, sprite.position.y + sprite.contentSize.height / 2 + star2.contentSize.height / 2 + 2)];
                    [_menuSheet addChild:star2];

                    starName = (stars > 2 ? @"lm-star-right.png" : @"lm-star-right-inactive.png");
                    CCSprite *star3 = [CCSprite spriteWithSpriteFrameName:starName];
                    [star3 setOpacity:(stars > 2 ? 255 : 150)];
                    [star3 setPosition:CGPointMake(sprite.position.x + star3.contentSize.width, sprite.position.y + sprite.contentSize.height / 2 + star3.contentSize.height / 2 - 2)];
                    [_menuSheet addChild:star3];


                    if (theme * THEME_MULTIPLIER + level == 2 * THEME_MULTIPLIER + 1)
                    {
                        [star1 setPosition:CGPointMake(star1.position.x, star1.position.y - 20)];
                        [star2 setPosition:CGPointMake(star2.position.x, star2.position.y - 20)];
                        [star3 setPosition:CGPointMake(star3.position.x, star3.position.y - 20)];
                    }
                }



                // Level lock
                CCSprite *lockSprite = nil;
                if (isLevelDone == NO && isLevelUnlocked == NO && nextLevelUnlockButton == YES)
                {
                    nextLevelUnlockButton = NO;
                    [sprite setDisabled:NO];
                    [sprite setTouchUpBlock:^(){
                        [self unlockTheme:theme andLevel:level];
                    }];

                    lockSprite = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-key.png"];
                    [lockSprite setPosition:CGPointMake(sprite.position.x - sprite.contentSize.width / 5, sprite.position.y - lockSprite.contentSize.height / 2)];
                    [_menuSheet addChild:lockSprite z:20];

                    id cSca1 = [CCScaleTo actionWithDuration:0.4 scale:1.2f];
                    id cSca2 = [CCScaleTo actionWithDuration:0.2 scale:1.0f];
                    id cDelay1 = [CCDelayTime actionWithDuration:0.3f];
                    id cDelay2 = [CCDelayTime actionWithDuration:3.0f];
                    id cSeq = [CCSequence actions:cSca1, cSca2, cDelay1, [[cSca1 copy] autorelease], [[cSca2 copy] autorelease], cDelay2, nil];
                    id cRep = [CCRepeatForever actionWithAction:cSeq];
                    [lockSprite runAction:cRep];

//                    id action4 = [CCRotateTo actionWithDuration:0.05 angle:15];
//                    id action5 = [CCRotateTo actionWithDuration:0.05 angle:-15];
//                    id action6 = [CCRotateTo actionWithDuration:0.05 angle:0.0];
//                    id cDelay = [CCDelayTime actionWithDuration:5.0f];
//
//                    CCSequence *scaleSeq = [CCSequence actions:action4, action5, action6, cDelay, nil];
//                    CCAction *action = [CCRepeatForever actionWithAction:scaleSeq];
//                    [sprite runAction:action];
                }
                else if (isLevelDone == NO && isLevelUnlocked == NO)
                {
                    if (level == 1)
                    {
                        lockSprite = [CCSprite spriteWithSpriteFrameName:@"lm-lock-big.png"];
                        [lockSprite setPosition:CGPointMake(sprite.position.x - sprite.contentSize.width / 5, sprite.position.y - lockSprite.contentSize.height / 2)];
                        [_menuSheet addChild:lockSprite z:20];
                    }
                    else
                    {
                        lockSprite = [CCSprite spriteWithSpriteFrameName:@"lm-lock-small.png"];
                        [lockSprite setPosition:CGPointMake(sprite.position.x + sprite.contentSize.width / 5, sprite.position.y - lockSprite.contentSize.height / 2)];
                        [_menuSheet addChild:lockSprite z:20];
                    }
                }

                // Level's individual settings
                if (lockSprite != nil)
                {
                    switch (theme * THEME_MULTIPLIER + level) {
                        case 3 * THEME_MULTIPLIER + 1:
                        {
                            [lockSprite setPosition:CGPointMake(sprite.position.x + sprite.contentSize.width / 2 - 50, sprite.position.y - 10)];
                        }
                            break;

                        default:
                            break;
                    }
                }
            }
        }


        // -- Add back button
        CCSprite *buttonSprite = [CCSprite spriteWithSpriteFrameName:@"lm-back.png"];
        _backButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(CCSprite *sender){
            [[CCDirector sharedDirector] replaceScene:[HomeScene scene]];
        }];
        [_backButton setButtonSound:@"buttons.m4a"];
        [_backButton setAnchorPoint:CGPointMake(0.5, 1)];
        [_backButton setPosition:ccp(_backButton.contentSize.width / 2 + 30, self.contentSize.height + 30)];

        id cMov1 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(_backButton.position.x, _backButton.position.y - 10)];
        id cMov2 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(_backButton.position.x, _backButton.position.y)];
        id cMov4 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(_backButton.position.x, self.contentSize.height + _backButton.contentSize.height)];

        [_backButton setSelectedAction:cMov1];
        [_backButton setUnselectedAction:cMov2];
        [_backButton setActivateAction:cMov4];


//        // Unlock button
//        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-3.png"];
//
//        CCSprite *tmpSprite = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-2.png"];
//        [tmpSprite setAnchorPoint:CGPointMake(0, 0)];
//        [buttonSprite addChild:tmpSprite];
//
//        CCSprite *tmpSprite2 = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-1.png"];
//        [tmpSprite2 setAnchorPoint:CGPointMake(0, 0)];
//        [buttonSprite addChild:tmpSprite2];
//
//        _unlockButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(CCSprite *sender){
//            [self unlockAllLevels];
//        }];
//        [_unlockButton setVisible:!levelsUnlocked];
//        [_unlockButton setButtonSound:@"buttons.m4a"];
//        [_unlockButton setAnchorPoint:CGPointMake(0.5, 1)];
//        [_unlockButton setPosition:CGPointMake(self.contentSize.width - _unlockButton.contentSize.width / 2 - 24, self.contentSize.height + 25)];



        // Button menu
        CCMenu *buttonMenu = [CCMenu menuWithItems:_backButton, nil];
        [buttonMenu setTouchSwallow:YES];
        [buttonMenu setPosition:CGPointZero];
        [self addChild:buttonMenu z:20];



        // -- Add our character
        CCSprite *_characterSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-1.png"];
        [_characterSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [_characterSprite setPosition:CGPointMake(_scrollLayer.contentSize.width / 2, 40)];
        [_scrollLayer addChild:_characterSprite z:3];

        CCSprite *feetSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-kajas.png"];
        [feetSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [feetSprite setPosition:_characterSprite.position];
        [_scrollLayer addChild:feetSprite z:3];


        // Animate
        id cDelay2 = [CCDelayTime actionWithDuration:5.0f];
        id cDelay3 = [CCDelayTime actionWithDuration:1.0f];

        id cBored1 = [[SharedActions sharedActions] characterBored];
        id cBlink1 = [[SharedActions sharedActions] characterEyeBlink];

        id cSeq1 = [CCSequence actions:cDelay3, cBlink1, cDelay2, nil];
        id cRep1 = [CCRepeatForever actionWithAction:cSeq1];

        [_characterSprite runAction:cRep1];
        [_characterSprite runAction:cBored1];



        // -- Find max theme and max level
//        _theme = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MaxTheme"] intValue];
//        _level = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MaxLevel"] intValue];
        if (_theme == 0 || _level == 0)
        {
            _theme = 1;
            _level = 1;
        }

        // -- Play backgroundmusic
        BOOL musicIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"MusicIsOn"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(musicIsOn ? 0.2f : 0.0f)];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-levels.m4a"];


        // -- Animate stuff
        if (_theme == 1 && _level == 1)
        {
            [_scrollLayer setPosition:CGPointMake(_scrollLayer.position.x, _scrollLayer.contentSize.height)];
            id cMov = [CCMoveTo actionWithDuration:3.0f position:CGPointMake(_scrollLayer.position.x, self.contentSize.height)];
            id cEase = [CCEaseInOut actionWithAction:cMov rate:7];
            [_scrollLayer runAction:cEase];
        }
        else
        {
            LMCustomSprite *sprite = (LMCustomSprite *)[_menuSheet getChildByTag:_theme * THEME_MULTIPLIER + _level];

            id cSca1 = [CCScaleTo actionWithDuration:0.6 scale:1.2];
            id cSca2 = [CCScaleTo actionWithDuration:0.6 scale:1.0];
            id cSeq = [CCSequence actions:cSca1, cSca2, nil];
            id cRep = [CCRepeatForever actionWithAction:cSeq];
            [sprite runAction:cRep];

            CGPoint pos = _scrollLayer.position;
            pos.y = _scrollLayer.contentSize.height - sprite.position.y + self.contentSize.height / 2;
            pos.y = MAX(pos.y, self.contentSize.height);
            pos.y = MIN(pos.y, _scrollLayer.contentSize.height);
            id cMov = [CCMoveTo actionWithDuration:((((float)_theme+1.0) * 2) / TOTAL_THEMES) position:pos];
            id cEase2 = [CCEaseIn actionWithAction:cMov rate:4.0];
            [_scrollLayer runAction:cEase2];

            _shouldScroll = YES;
        }

        // Do something rare
//        [self schedule:@selector(updateWithInterval:) interval:5.0];


        [TestFlight passCheckpoint:@"Levels Scene"];
    }
    return self;
}



- (void)scheduleUpdate
{
    [super scheduleUpdate];
    [self setAccelerometerEnabled:YES];
}


- (void)unscheduleUpdate
{
    [super unscheduleUpdate];
    [self setAccelerometerEnabled:NO];
}



- (void)onEnter
{
    [super onEnter];
    [self scheduleUpdate];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}



- (void)updateWithInterval:(ccTime)dt
{
//    id cSca1 = [CCScaleTo actionWithDuration:0.5 scale:1.1];
//    id cEase1 = [CCEaseOut actionWithAction:cSca1 rate:3.0];
//
//    id cSca2 = [CCScaleTo actionWithDuration:1.0 scale:1.2];
//    id cEase2 = [CCEaseOut actionWithAction:cSca2 rate:3.0];
//
//    id cSca3 = [CCScaleTo actionWithDuration:1.0 scale:1.3];
//    id cEase3 = [CCEaseOut actionWithAction:cSca3 rate:3.0];
//
//    id cSca4 = [CCScaleTo actionWithDuration:0.5 scale:1.0];
//    id cEase4 = [CCEaseOut actionWithAction:cSca4 rate:3.0];
//
//    id cSeq1 = [CCSequence actions:cSca1, cSca4, [[cSca1 copy] autorelease], [[cSca4 copy] autorelease], nil];
//    [_unlockButton runAction:cSeq1];
//
//    //id cShake = [CCShake actionWithDuration:0.5 amplitude:CGPointMake(4, 4) shakes:25];
//    //[_unlockButton runAction:cShake];
}


- (void)update:(ccTime)dt
{
    static int currTheme = 1, currLevel = 1, seconds = 0, test = 10;

    if (_shouldScroll == YES)
    {
        if (currTheme >= _theme && currLevel >= _level)
        {
            currTheme = 1;
            currLevel = 1;
            test = 10;
            _shouldScroll = NO;
            return;
        }

        seconds = roundf((seconds + 1) * 100) / 100;
        if (fmodf(seconds, test) == 0)
        {
            seconds = 0;
            test = MAX(roundf((test - 1) * 100) / 100, 3);
            currLevel += 1;
            if (currLevel > 6)
            {
                currTheme += 1;
                currLevel = 1;
            }

            LMCustomSprite *sprite = (LMCustomSprite *)[_menuSheet getChildByTag:currTheme * THEME_MULTIPLIER + currLevel];
            if ([sprite isDone])
            {
                [sprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:sprite.enabledFrameName]];
            }
        }
    }

    [_backButton setRotation:-20 * _accelX];
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    _accelX = (acceleration.x * 0.05) + (_accelX * (1.0 - 0.05));
}



#pragma mark - CustomScrollLayerDelegate

- (void)scrolling
{
    if ([_backButton getActionByTag:kActivateAction] != nil)
    {
        return;
    }

    float y = fabsf(self.contentSize.height - _scrollLayer.position.y);
    CGPoint pos = _backButton.position;
    pos.y = MIN(self.contentSize.height + 110 / 2, self.contentSize.height + 30 + y);
    [_backButton setPosition:pos];
}


#pragma mark - In-App Purchase
- (void)unlockTheme:(int)theme andLevel:(int)level
{
    __block OverlayColorLayer *layer = [OverlayColorLayer layerWithColor:ccc4(0, 0, 0, 150)];
    [layer setTouchUpBlock:^{
        [layer removeFromParentAndCleanup:YES];
    }];
    [self addChild:layer z:40];

    CCSprite *unlockFrame = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-level-frame.png"];
    [unlockFrame setPosition:CGPointMake(layer.contentSize.width / 2, layer.contentSize.height / 2)];
    [layer addChild:unlockFrame];

    CCSprite *unlockButtonSprite = [CCSprite spriteWithSpriteFrameName:@"lm-unlock-button.png"];
    AnimatedCCMenuItemImage *unlockButton = [AnimatedCCMenuItemImage itemWithNormalSprite:unlockButtonSprite selectedSprite:nil block:^(id sender) {
        // Show loader
        LoaderLayer *loader = [LoaderLayer layer];
        [loader setShowProgress:NO];
        [self addChild:loader.parent z:50];
        [self unscheduleUpdate];

        // Do stuff
        [[IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(NSArray *products, NSError *error) {
            if (error == nil)
            {
                SKProduct *product = nil;
                for (SKProduct *tmp in products)
                {
                    if ([tmp.productIdentifier isEqualToString:@"PUnlockAllLevels"])
                    {
                        product = tmp;
                    }
                }

                if (product == nil)
                {
                    return; // Should never happen
                }

                // buy
                [[IAPHelper sharedInstance] buyProduct:product withCompletionHandler:^(SKPaymentTransaction *transaction, NSError *error) {
                    [self scheduleUpdate];
                    [layer removeFromParentAndCleanup:YES];
                    [loader removeFromParentAndCleanup:YES];
                    if (error == nil)
                    {
//                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"unlocked:%d:%d", theme, level]];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[LevelsScene scene] withColor:ccWHITE]];
                    }
                    else
                    {
                        [IAPHelper showAlertWithError:error];
                    }
                }];
            }
            else
            {
                [IAPHelper showAlertWithError:error];
                [self scheduleUpdate];
                [layer removeFromParentAndCleanup:YES];
                [loader removeFromParentAndCleanup:YES];
            }
        }];

    }];
    [unlockButton setPosition:CGPointMake(layer.contentSize.width / 2, unlockFrame.position.y - unlockFrame.contentSize.height / 2 + 15)];
    [unlockButton setButtonSound:@"buttons.m4a"];

    [unlockButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
    [unlockButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
    [unlockButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];

    CCMenu *buttonMenu = [CCMenu menuWithItems:unlockButton, nil];
    [buttonMenu setTouchSwallow:YES];
    [buttonMenu setTouchPriority:kCCMenuHandlerPriority - 5];
    [buttonMenu setPosition:CGPointZero];
    [layer addChild:buttonMenu];
}

@end
