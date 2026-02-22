//
//  AppDelegate.m
//  Falling Apple
//
//  Created by Gints Murans on 1/23/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "AppIAPHelper.h"
#import "GAI.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-36236390-11"];
    [tracker setAnonymize:YES];
    [tracker sendView:@"App Launch"];

    // Setup in-background sounds
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // Init in-app purchases
    [AppIAPHelper sharedInstance];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (self.viewController.isRunning)
    {
        [self.viewController pauseGameAction:nil];
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
        }
        return YES;
    }
    return NO;
}


@end
