//
//  SettingsScene.m
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "SettingsScene.h"
#import "LevelsScene.h"
#import "HomeScene.h"
#import "SharedActions.h"
#import "SimpleAudioEngine.h"
#import "Appirater.h"
#import "IAPHelper.h"


@implementation SettingsScene
@synthesize layer = _layer;

+ (SettingsScene *)scene
{
 	SettingsScene *scene = [[[SettingsScene alloc] init] autorelease];
	return scene;
}

- (void)dealloc
{
    NSLog(@"Settings Dealloc");
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _layer = [SettingsLayer layer];
        [self addChild:_layer z:0];
    }
    return self;
}

@end



@implementation SettingsLayer


+ (void)loadResources
{

}


+ (SettingsLayer *)layer
{
	SettingsLayer *layer = [[[SettingsLayer alloc] init] autorelease];
	return layer;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        __block CCSprite *bg = [CCSprite spriteWithSpriteFrameName:(self.contentSize.height == 480 ? @"completed-bg-960.png" : @"completed-bg.png")];
        [bg setAnchorPoint:CGPointMake(0.5, 0)];
        [bg setPosition:CGPointMake(self.contentSize.width / 2, 0)];
        [self addChild:bg];


        CCSprite *buttonSprite = [CCSprite spriteWithSpriteFrameName:@"lm-back.png"];
        _backButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(id sender) {
            [self unschedule:@selector(updateSettings)];
            [self setAccelerometerEnabled:NO];
            [[CCDirector sharedDirector] popScene];
        }];
        [_backButton setButtonSound:@"buttons.m4a"];
        [_backButton setAnchorPoint:CGPointMake(0.5, 1.0)];
        [_backButton setPosition:ccp(_backButton.contentSize.width / 2 + 20, self.contentSize.height + 40)];

        id cMov1 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(_backButton.position.x, _backButton.position.y - 10)];
        id cMov2 = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(_backButton.position.x, _backButton.position.y)];
        id cMov4 = [CCMoveTo actionWithDuration:0.2 position:CGPointMake(_backButton.position.x, self.contentSize.height + _backButton.contentSize.height)];

        [_backButton setSelectedAction:cMov1];
        [_backButton setUnselectedAction:cMov2];
        [_backButton setActivateAction:cMov4];



        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Settings" fontName:@"Snickles" fontSize:45.0f dimensions:CGSizeMake(self.contentSize.width, 50) hAlignment:kCCTextAlignmentCenter];
        [label setColor:ccc3(64, 33, 14)];
        [label setAnchorPoint:CGPointMake(0.5, 1)];
        [label setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height - 70)];
        [self addChild:label];



        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"s-restore.png"];
        AnimatedCCMenuItemImage *restoreButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(CCSprite *sender){
            [[IAPHelper sharedInstance] restoreCompletedTransactionsWithCompletionHandler:^(SKPaymentTransaction *transaction, NSError *error) {
                if (error == nil)
                {
                    if ([transaction.payment.productIdentifier isEqualToString:@"PUnlockAllLevels"])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Purchases restored" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    }
                }
                else
                {
                    [IAPHelper showAlertWithError:error];
                }
            } withVerifyCompletionHandler:nil];
        }];
        [restoreButton setButtonSound:@"buttons.m4a"];
        [restoreButton setPosition:ccp(self.contentSize.width / 2, self.contentSize.height / 2 + restoreButton.contentSize.height / 2 + 35)];
        [restoreButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [restoreButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        [restoreButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];



        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"s-reset.png"];
        AnimatedCCMenuItemImage *resetButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(id sender) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FinishedLevels"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Game is now reset!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }];
        [resetButton setButtonSound:@"buttons.m4a"];
        [resetButton setPosition:ccp(self.contentSize.width / 2, restoreButton.position.y - restoreButton.contentSize.height - 7.0f)];
        [resetButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [resetButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];



        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"s-rate.png"];
        AnimatedCCMenuItemImage *rateButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(id sender) {
            [Appirater rateApp];
        }];
        [rateButton setButtonSound:@"buttons.m4a"];
        [rateButton setPosition:ccp(self.contentSize.width / 2, resetButton.position.y - resetButton.contentSize.height - 7.0f)];
        [rateButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [rateButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];



        __block BOOL musicIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"MusicIsOn"];
        __block BOOL effectsAreOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"EffectsAreOn"];

        buttonSprite = [CCSprite spriteWithSpriteFrameName:(musicIsOn ? @"s-music-on.png" : @"s-music-off.png")];
        __block AnimatedCCMenuItemImage *musicButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(id sender) {
            musicIsOn = !musicIsOn;
            [[NSUserDefaults standardUserDefaults] setBool:musicIsOn forKey:@"MusicIsOn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [musicButton setNormalImage:[CCSprite spriteWithSpriteFrameName:(musicIsOn ? @"s-music-on.png" : @"s-music-off.png")]];
            [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(musicIsOn ? 0.2f : 0.0f)];
        }];
        [musicButton setButtonSound:@"buttons.m4a"];
        [musicButton setPosition:ccp(self.contentSize.width / 2 - musicButton.contentSize.width / 2 - 5, rateButton.position.y - 70)];
        [musicButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [musicButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];



        buttonSprite = [CCSprite spriteWithSpriteFrameName:(musicIsOn ? @"s-effects-on.png" : @"s-effects-off.png")];
        __block AnimatedCCMenuItemImage *effectsButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(id sender) {
            effectsAreOn = !effectsAreOn;
            [[NSUserDefaults standardUserDefaults] setBool:effectsAreOn forKey:@"EffectsAreOn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [effectsButton setNormalImage:[CCSprite spriteWithSpriteFrameName:(effectsAreOn ? @"s-effects-on.png" : @"s-effects-off.png")]];
            [[SimpleAudioEngine sharedEngine] setEffectsVolume:(effectsAreOn ? 0.5f : 0.0f)];
        }];
        [effectsButton setButtonSound:@"buttons.m4a"];
        [effectsButton setPosition:ccp(self.contentSize.width / 2 + effectsButton.contentSize.width / 2 + 5, rateButton.position.y - 70)];
        [effectsButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [effectsButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        
        
        CCMenu *buttonMenu = [CCMenu menuWithItems:restoreButton, resetButton, rateButton, musicButton, effectsButton, _backButton, nil];
        [buttonMenu setPosition:CGPointZero];
        [self addChild:buttonMenu z:20];
        
        
        [self schedule:@selector(updateSettings)];
        [self setAccelerometerEnabled:YES];

        [TestFlight passCheckpoint:@"Settings Scene"];
    }
    return self;
}




- (void)updateSettings
{
    [_backButton setRotation:-20 * _accelX];
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    _accelX = (acceleration.x * 0.05) + (_accelX * (1.0 - 0.05));
}

@end
