//
//  LoaderLayer.h
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "ProgressBarLayer.h"
#import "CCExtensions.h"


typedef void (^GenericBlock)();


@interface LoaderLayer : CCLayer
{
    ProgressBarLayer *_progressLayer;
    NSLock *_lock;
    EAGLContext *_auxGLcontext;
}
@property (nonatomic, retain) CCScene *parent;
@property (nonatomic, assign, getter = shouldShowProgress) BOOL showProgress;

+ (LoaderLayer *)layer;
+ (LoaderLayer *)sharedLoaderLayer;

- (void)showWithLoadingBlock:(GenericBlock)loadingBlock withCallbackBlock:(GenericBlock)callbackBlock;
- (void)setProgress:(int)progress;

@end

