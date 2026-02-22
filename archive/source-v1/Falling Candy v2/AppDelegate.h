//
//  AppDelegate.h
//  Falling Candy v2
//
//  Created by Gints Murans on 3/13/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CCDirectorDelegate>
{
    // OpenGL
    CCDirectorIOS *director;
}

@property (strong, nonatomic) UIWindow *window;

@end
