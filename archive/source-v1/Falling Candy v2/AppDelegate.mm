//
//  AppDelegate.m
//  Falling Candy v2
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeScene.h"
#import "LevelCompletedScene.h"
#import "SimpleAudioEngine.h"
#import "LoaderLayer.h"
#import "SharedActions.h"
#import "FSNConnection.h"
#import "CCExtensions.h"
#import "BackgroundLayer.h"
#import "Appirater.h"
#import "TestFlight+AsyncLogging.h"
#import <FacebookSDK/FacebookSDK.h>


//@implementation CCDirectorIOS (tmp)
//
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self becomeFirstResponder];
//}
//
//
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//    if (event.subtype == UIEventSubtypeMotionShake)
//    {
////        FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://dev:root@ct.earlybird.lv/Gravity.json"] method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:^id(FSNConnection *c, NSError **e) {
////            return [NSJSONSerialization JSONObjectWithData:c.responseData options:0 error:e];
////        } completionBlock:^(FSNConnection *c) {
////            if (c.error != nil)
////            {
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:c.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////                [alert show];
////                [alert release];
////            }
////            else
////            {
////                NSDictionary *response = (NSDictionary *)c.parseResult;
////                [[SharedActions sharedActions] setGravityX:[[response objectForKey:@"gravityX"] floatValue]];
////                [[SharedActions sharedActions] setGravityY:[[response objectForKey:@"gravityY"] floatValue]];
////                [[SharedActions sharedActions] setFiltering:[[response objectForKey:@"filtering"] floatValue]];
////                [[SharedActions sharedActions] setDamping:[[response objectForKey:@"damping"] floatValue]];
////
////                NSLog(@"_gravityX: %f, _gravityY: %f, _filtering: %f, _damping: %f", [SharedActions sharedActions].gravityX, [SharedActions sharedActions].gravityY, [SharedActions sharedActions].filtering, [SharedActions sharedActions].damping);
////
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:@"Speed and stuff loaded..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////                [alert show];
////                [alert release];
////            }
////        } progressBlock:nil];
////        [connection start];
//
//
//        FSNConnection *connection2 = [FSNConnection withUrl:[NSURL URLWithString:@"http://dev:root@ct.earlybird.lv/Levels.json"] method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:nil completionBlock:^(FSNConnection *c) {
//            if (c.error != nil)
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:c.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//            else
//            {
//                NSString *levelsPath = [[SharedActions sharedActions] documentPath:@"Levels.json"];
//                [c.responseData writeToFile:levelsPath atomically:YES];
//                [[SharedActions sharedActions] clearLevelCache];
//
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:@"Levels loaded..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//        } progressBlock:nil];
//        [connection2 start];
//    }
//}
//
//@end



@implementation AppDelegate


- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Testflight
    [TestFlight takeOff:@"8d85e71a-eeaf-412b-8ede-1615b5a9b4e3"];


    // App rating
    [Appirater setAppId:@"747676903"];
    [Appirater setOpenInAppStore:NO];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:5];
    [Appirater setTimeBeforeReminding:2];


    // Facebook
    [FBSettings setDefaultAppID:@"566090670078943"];
    [FBAppEvents activateApp];


    // Google analytics
//    [GAI sharedInstance].trackUncaughtExceptions = NO;
//    [GAI sharedInstance].dispatchInterval = 20;
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-36236390-11"];


    // Default settings
    NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:YES], @"MusicIsOn",
                                          [NSNumber numberWithBool:YES], @"EffectsAreOn",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];


    // Set background music volume
    BOOL musicIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"MusicIsOn"];
    BOOL effectsAreOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"EffectsAreOn"];

    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:(musicIsOn ? 0.2f : 0.0f)];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:(effectsAreOn ? 0.5f : 0.0f)];


    // Update accelerometer update interval
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0/60];


    // Set filename suffixes
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    [sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
    [sharedFileUtils setiPhoneRetinaDisplaySuffix:@"@2x"];		// Default on iPhone RetinaDisplay is "-hd"

    // Assume that PVR images have premultiplied alpha
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    // Setup opengl view
    CCGLView *GLPlayground = [CCGLView viewWithFrame:UIScreen.mainScreen.bounds pixelFormat:kEAGLColorFormatRGBA8 depthFormat:GL_DEPTH_COMPONENT24_OES preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];

    director = (CCDirectorIOS *)[CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    [director setAnimationInterval:1.0/60];
    [director setView:GLPlayground];
    [director setDelegate:self];
    [director setProjection:kCCDirectorProjection2D];
    [director enableRetinaDisplay:YES];
    [director setDisplayStats:NO];
    [director setDepthTest:NO];

    // Show home layer with loader + pre-cache some stuff
    LoaderLayer *loader = [LoaderLayer layer];
    [loader showWithLoadingBlock:^{
        [loader setProgress:10];

        [HomeLayer loadResources];
        [loader setProgress:30];

        [LevelsLayer loadResources];
        [loader setProgress:40];

        [GameLayer loadResources];
        [loader setProgress:70];

        [BackgroundLayer loadResources];
        [loader setProgress:80];

        [[SharedActions sharedActions] loadLevels];
        [loader setProgress:90];

        [LevelCompletedLayer loadResources];
        [LevelCompletedLayer sharedLayer];

        [loader setProgress:100];
    } withCallbackBlock:^{
        [[CCDirector sharedDirector] replaceScene:[HomeScene scene]];
    }];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window setRootViewController:director];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];


    // App rating
    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationResignActive" object:self userInfo:nil];
    [director pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [director stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [director startAnimation];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (director.isPaused)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationBecomeActive" object:self userInfo:nil];
        [director resume];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    TFLog_async(@"Memory Warning");
    [[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
