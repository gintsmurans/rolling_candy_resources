//
//  HomeLayer.m
//  Falling Candy
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "HomeScene.h"
#import "LevelsScene.h"
#import "SharedActions.h"
#import "SimpleAudioEngine.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "IAPHelper.h"
#import "SettingsScene.h"
#import "Appirater.h"


@implementation HomeScene
@synthesize layer = _layer;

+ (HomeScene *)scene
{
 	HomeScene *scene = [[[HomeScene alloc] init] autorelease];
	return scene;
}

- (void)dealloc
{
    NSLog(@"Home Dealloc");
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _layer = [HomeLayer layer];
        [self addChild:_layer z:0];
    }
    return self;
}

@end



@implementation HomeLayer


+ (void)loadResources
{
    // Load music
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"playing-games-levels.m4a"];

    // Load shared sprite frame cache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"home-scene.plist"];

    // Load textures
    [[CCTextureCache sharedTextureCache] addImage:@"home-scene.pvr"];
}


+ (HomeLayer *)layer
{
	HomeLayer *layer = [[[HomeLayer alloc] init] autorelease];
	return layer;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        // -- Sheet
        _sheet = [CCSpriteBatchNode batchNodeWithFile:@"home-scene.pvr"];
        [self addChild:_sheet z:1];


        // -- Background
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"h-bg.png"];
        [bg setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
        [_sheet addChild:bg z:-5];


        // -- Sun
        CCSprite *sun = [CCSprite spriteWithSpriteFrameName:@"h-sun.png"];
        [sun setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2 + 30)];
        [_sheet addChild:sun z:-4];

        id cRot = [CCRotateBy actionWithDuration:10.0f angle:180];
        id cRep = [CCRepeatForever actionWithAction:cRot];
        [sun runAction:cRep];

        // -- Background clouds
        CCSprite *bgClouds = [CCSprite spriteWithSpriteFrameName:@"h-bg-clouds.png"];
        [bgClouds setAnchorPoint:CGPointMake(0.5, 0)];
        [bgClouds setPosition:CGPointMake(self.contentSize.width / 2, 0)];
        [_sheet addChild:bgClouds z:-3];

        // -- Branches
        CCSprite *branches = [CCSprite spriteWithSpriteFrameName:@"h-branches.png"];
        [branches setPosition:CGPointMake(branches.contentSize.width / 2 - 1, self.contentSize.height - branches.contentSize.height / 2)];
        [_sheet addChild:branches];


        // -- Logo
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"h-logo.png"];
        [logo setScale:0.85];
        [logo setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2 + 30)];
        [_sheet addChild:logo];


        // -- Tree
        CCSprite *tree = [CCSprite spriteWithSpriteFrameName:@"h-tree.png"];
        [tree setPosition:CGPointMake(self.contentSize.width - tree.contentSize.width / 2, self.contentSize.height - tree.contentSize.height / 2)];
        [_sheet addChild:tree];


        // Update some scaling for iPhone4
        if (self.contentSize.height <= 480)
        {
//            [logo setScale:0.9f];
//            [logo setPosition:CGPointMake(logo.position.x, logo.position.y + 20)];
            [tree setPosition:CGPointMake(tree.position.x, tree.position.y + 50)];
            [branches setPosition:CGPointMake(branches.position.x, branches.position.y + 50)];
        }


        // Character's cloud
        CCSprite *jefCloud = [CCSprite spriteWithSpriteFrameName:@"h-jef-cloud.png"];
        [jefCloud setAnchorPoint:CGPointMake(0.5, 0)];
        [jefCloud setPosition:CGPointMake(self.contentSize.width / 2, 65)];
        [_sheet addChild:jefCloud];

        CCSprite *jefCloudFront = [CCSprite spriteWithSpriteFrameName:@"h-jef-cloud-front.png"];
        [jefCloudFront setAnchorPoint:CGPointMake(0.5, 0)];
        [jefCloudFront setPosition:jefCloud.position];
        [self addChild:jefCloudFront z:5];


        // Character
        CCSprite *_characterSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-1.png"];
        [_characterSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [_characterSprite setPosition:CGPointMake(self.contentSize.width / 2, jefCloudFront.position.y + 47)];
        [self addChild:_characterSprite z:3];

        CCSprite *feetSprite = [CCSprite spriteWithSpriteFrameName:@"lacis-kajas.png"];
        [feetSprite setAnchorPoint:CGPointMake(0.5, 0)];
        [feetSprite setPosition:_characterSprite.position];
        [self addChild:feetSprite z:3];


        // Animate
        id cAni1 = [[SharedActions sharedActions] characterOpenMouth];
        id cAni2 = [[SharedActions sharedActions] characterEyeBlink];
        id cDelay1 = [CCDelayTime actionWithDuration:5];
        id cDelay2 = [CCDelayTime actionWithDuration:2];
        id cDelay3 = [CCDelayTime actionWithDuration:1];

        // Put it on the sequence
        id cSeq1 = [CCSequence actions:cDelay1, cAni1, cDelay2, [cAni1 reverse], cDelay3, cAni2, nil];
        id cRep1 = [CCRepeatForever actionWithAction:cSeq1];

        // Run those actions
        [_characterSprite runAction:cRep1];
        [_characterSprite runAction:[[SharedActions sharedActions] characterBored]];



        // -- Play Button
        CCSprite *buttonSprite = [CCSprite spriteWithSpriteFrameName:@"h-play.png"];
        AnimatedCCMenuItemImage *playButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil block:^(CCSprite *sender){
            LevelsScene *scene = [LevelsScene scene];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        [playButton setButtonSound:@"buttons.m4a"];
        [playButton setPosition:ccp(self.contentSize.width / 2, playButton.contentSize.height / 2 + 15)];
        [playButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [playButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];
        [playButton setActivateAction:[[SharedActions sharedActions] buttonActivateAction]];


        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"twitter-button.png"];
        AnimatedCCMenuItemImage *twitterButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil target:self selector:@selector(followTwitter)];
        [twitterButton setButtonSound:@"buttons.m4a"];
        [twitterButton setPosition:ccp(twitterButton.contentSize.width / 2 + 10, twitterButton.contentSize.height + (twitterButton.contentSize.height / 2) + 20)];
        [twitterButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [twitterButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];

        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"facebook-button.png"];
        AnimatedCCMenuItemImage *facebookButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil target:self selector:@selector(followFacebook)];
        [facebookButton setButtonSound:@"buttons.m4a"];
        [facebookButton setPosition:ccp(facebookButton.contentSize.width / 2 + 10, facebookButton.contentSize.height / 2 + 10)];
        [facebookButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [facebookButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];



        buttonSprite = [CCSprite spriteWithSpriteFrameName:@"gear-button.png"];
        AnimatedCCMenuItemImage *gearButton = [AnimatedCCMenuItemImage itemWithNormalSprite:buttonSprite selectedSprite:nil target:self selector:@selector(settings)];
        [gearButton setButtonSound:@"buttons.m4a"];
        [gearButton setPosition:ccp(self.contentSize.width - gearButton.contentSize.width / 2 - 10, gearButton.contentSize.height / 2 + 10)];
        [gearButton setSelectedAction:[[SharedActions sharedActions] buttonSelectedAction]];
        [gearButton setUnselectedAction:[[SharedActions sharedActions] buttonUnselectedAction]];


        CCMenu *buttonMenu = [CCMenu menuWithItems:playButton, twitterButton, facebookButton, gearButton, nil];
        [buttonMenu setPosition:CGPointZero];
        [self addChild:buttonMenu z:20];

        // Add a fly
        [self addFly];


        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-levels.m4a"];
//        [self scheduleUpdate];
//        [self update:15];

        [TestFlight passCheckpoint:@"Home Scene"];
    }
    return self;
}


- (void)addFly
{
    CCLayer *flyLayer = [CCLayer node];

    CCSprite *musaSparns1 = [CCSprite spriteWithSpriteFrameName:@"h-musa-sparns1.png"];
    [musaSparns1 setAnchorPoint:CGPointMake(0, 0)];
    [musaSparns1 setPosition:CGPointMake(0, 0)];
    [flyLayer addChild:musaSparns1];

    CCSprite *musaSparns2 = [CCSprite spriteWithSpriteFrameName:@"h-musa-sparns2.png"];
    [musaSparns2 setAnchorPoint:CGPointMake(0, 0)];
    [musaSparns2 setPosition:CGPointMake(0, 0)];
    [flyLayer addChild:musaSparns2];

    CCSprite *musa = [CCSprite spriteWithSpriteFrameName:@"h-musa.png"];
    [musa setAnchorPoint:CGPointMake(0, 0)];
    [musa setPosition:CGPointMake(0, 0)];
    [flyLayer addChild:musa];

    [musa runAction:[[SharedActions sharedActions] characterBored]];

    id cRot1 = [CCRotateTo actionWithDuration:0.03 angle:-7];
    id cRot2 = [CCRotateTo actionWithDuration:0.05 angle:0];
    id cRot3 = [CCRotateTo actionWithDuration:0.05 angle:+7];
    id cSeq1 = [CCSequence actions:cRot1, cRot2, nil];
    id cSeq4 = [CCSequence actions:cRot3, cRot2, nil];

    [musaSparns1 runAction:[CCRepeatForever actionWithAction:cSeq1]];
    [musaSparns2 runAction:[CCRepeatForever actionWithAction:cSeq4]];

    [flyLayer setContentSize:musa.contentSize];

    
    [flyLayer setPosition:CGPointMake(self.contentSize.width + flyLayer.contentSize.width / 2, self.contentSize.height - flyLayer.contentSize.height - 100)];
    [self addChild:flyLayer z:10];

    ccBezierConfig bezier;
    bezier.controlPoint_1 = ccp(flyLayer.position.x - 183, flyLayer.position.y - 346);
    bezier.controlPoint_2 = ccp(flyLayer.position.x - 194, flyLayer.position.y + 96);
    bezier.endPosition = CGPointMake(-flyLayer.contentSize.width - 10, flyLayer.position.y + 17);
    id cMov1 = [CCBezierTo actionWithDuration:7 bezier:bezier];

    id cFunc1 = [CCCallBlock actionWithBlock:^{
        [[SimpleAudioEngine sharedEngine] stopEffect:_effectNr];
        _effectNr = 0;
        CCSprite *sprite = nil;
        CCARRAY_FOREACH(flyLayer.children, sprite)
        {
            [sprite setFlipX:!sprite.flipX];
        }
    }];
    id cFunc2 = [CCCallBlock actionWithBlock:^{
        _effectNr = [[SimpleAudioEngine sharedEngine] playEffect:@"musa.m4a" pitch:1.3f pan:0.0f gain:1.5f];
    }];
    id cDelay = [CCDelayTime actionWithDuration:15.0f];

    ccBezierConfig bezier2;
    bezier2.controlPoint_1 = ccp(flyLayer.position.x - 194, flyLayer.position.y + 96);
    bezier2.controlPoint_2 = ccp(flyLayer.position.x - 183, flyLayer.position.y - 346);
    bezier2.endPosition = flyLayer.position;
    id cMov2 = [CCBezierTo actionWithDuration:4 bezier:bezier2];

    id cSeq5 = [CCSequence actions:cFunc2, cMov1, cFunc1, cDelay, cFunc2, cMov2, cFunc1, cDelay, nil];

    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [flyLayer runAction:[CCRepeatForever actionWithAction:cSeq5]];
    });
}


- (void)onExit
{
    [super onExit];

    // Stop fly sound
    if (_effectNr != 0)
    {
        [[SimpleAudioEngine sharedEngine] stopEffect:_effectNr];
    }
}


- (void)update:(ccTime)dt
{
    _seconds += dt;
    if (_seconds >= 10.0)
    {
        _seconds = 0.0;
        int min = 540 / 2;
        int max = self.contentSize.height;
        int random = (arc4random() % (max - min + 1)) + min;
        int cloundNr = (arc4random() % (3 - 1 + 1)) + 1;
        int cloudSpeed = 50;

        CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"h-cloud%d.png", cloundNr]];
        [cloud setPosition:CGPointMake(-cloud.contentSize.width / 2, random)];
        [_sheet addChild:cloud z:-3];

        id cMov = [CCMoveTo actionWithDuration:cloudSpeed position:CGPointMake(self.contentSize.width + cloud.contentSize.width / 2, cloud.position.y)];
        id cFunc = [CCCallBlock actionWithBlock:^{
            [cloud removeFromParentAndCleanup:YES];
        }];
        [cloud runAction:[CCSequence actions:cMov, cFunc, nil]];
    }
}



-(void)followFacebook
{
    NSURL *url = [NSURL URLWithString:@"fb://profile/576802095663191"];
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO)
    {
        url = [NSURL URLWithString:@"https://www.facebook.com/earlybirdltd"];
    }
    [[UIApplication sharedApplication] openURL:url];
}



-(void)followTwitter
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *acct = [arrayOfAccounts objectAtIndex:0];

                 NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"EB5am", @"screen_name", @"TRUE", @"follow", nil];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];

                 SLRequest *request  = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodPOST
                                                                URL:url
                                                         parameters:dictionary];

                 [request setAccount:acct];
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if ([urlResponse statusCode] == 200)
                      {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Thanks for following us" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                              [alert show];
                              [alert release];
                          });
                      }
                      else
                      {
                          // NSLog(@"Twitter error, HTTP response: %i, %@", [urlResponse statusCode], [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
                      }
                  }];
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter ERROR" message:@"You have no twitter account setup in your phone's settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                     [alert release];
                 });
             }
         }
     }];
}



- (void)settings
{
    [[CCDirector sharedDirector] pushScene:[SettingsScene scene]];
}


@end
