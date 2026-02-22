//
//  LoaderLayer.m
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "LoaderLayer.h"

@implementation LoaderLayer

+ (LoaderLayer *)layer
{
	LoaderLayer *layer = [[[LoaderLayer alloc] init] autorelease];
	return layer;
}


+ (LoaderLayer *)sharedLoaderLayer
{
    static dispatch_once_t once;
    static LoaderLayer *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[LoaderLayer layer] retain];
    });
    return sharedInstance;
}


- (void)cleanup
{
    [self.parent release];
}


- (void)dealloc
{
    [_lock release], _lock = nil;
    [_auxGLcontext release], _auxGLcontext = nil;
    [super dealloc];
}


- (id)init
{
    if ((self = [super init]))
    {
        _lock = [[NSLock alloc] init];
        _auxGLcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:[[(CCGLView *)[[CCDirector sharedDirector] view] context] sharegroup]];

        // -- Load some cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"loading.plist"];


        // -- Paper sheet
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"loading.pvr"];
        [self addChild:spriteSheet];

        // -- Init parent
        CCScene *scene = [[CCScene node] retain];
        [scene addChild:self];

        // -- Elements
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:(self.contentSize.height == 480 ? @"l-bg-960.png" : @"l-bg-1136.png")];
        [bg setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
        [spriteSheet addChild:bg z:-5];

        CCSprite *candy = [CCSprite spriteWithSpriteFrameName:@"l-candy.png"];
        [candy setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2 + candy.contentSize.height / 2)];
        [spriteSheet addChild:candy];

        CCSprite *candyLight = [CCSprite spriteWithSpriteFrameName:@"l-candy-light.png"];
        [candyLight setPosition:candy.position];
        [spriteSheet addChild:candyLight];

        CCSprite *candyShadow = [CCSprite spriteWithSpriteFrameName:@"l-candy-shadow.png"];
        [candyShadow setPosition:CGPointMake(candy.position.x + 1, candy.position.y - 1)];
        [spriteSheet addChild:candyShadow z:-2];


        CCLabelTTF *_scoreLabel = [CCLabelTTF labelWithString:@"Loading" fontName:@"Snickles" fontSize:24.0f dimensions:CGSizeMake(105, 26) hAlignment:kCCTextAlignmentCenter];
        [_scoreLabel setColor:ccc3(64, 33, 10)];
        [_scoreLabel setPosition:CGPointMake(candy.position.x, candy.position.y - candy.contentSize.height / 2 - _scoreLabel.contentSize.height / 2 - 11)];
        [self addChild:_scoreLabel];



        _progressLayer = [ProgressBarLayer layerWithColor:ccc4(64, 33, 10, 255)];
        [_progressLayer setContentSize:CGSizeMake(0, 1)];
        [_progressLayer setPosition:CGPointZero];

        CCLayerColor *progressBg = [CCLayerColor layerWithColor:ccc4(234, 204, 152, 255)];
        [progressBg setContentSize:CGSizeMake(120, 1)];
        [progressBg setPosition:CGPointMake((self.contentSize.width - progressBg.contentSize.width) / 2, candy.position.y - candy.contentSize.height / 2 - 5)];
        [progressBg addChild:_progressLayer];
        [self addChild:progressBg];

        // -- Start some animation
        id cRot1 = [CCRotateBy actionWithDuration:1.0 angle:360];
        id cRep1 = [CCRepeatForever actionWithAction:cRot1];
        [candy runAction:cRep1];
    }
    return self;
}


- (void)setShowProgress:(BOOL)showProgress
{
    _showProgress = showProgress;
    [_progressLayer.parent setVisible:_showProgress];
}


- (void)setProgress:(int)progress
{
    __block typeof(_progressLayer) myProgressLayer = _progressLayer;
    __block typeof(progress) myProgress = progress;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress == 0)
        {
            [myProgressLayer stopAllActions];
            [myProgressLayer setContentSize:CGSizeMake(0, myProgressLayer.contentSize.height)];
        }
        else
        {
            float x = (float)myProgress * 120 / 100;
            id cSize = [CCActionTween actionWithDuration:0.1 key:@"sizeWidth" from:myProgressLayer.contentSize.width to:x];
            [myProgressLayer stopAllActions];
            [myProgressLayer runAction:cSize];
        }
    });
}


- (void)setOpacity:(GLubyte)opacity
{
    CCNode *node = nil;
    CCARRAY_FOREACH(self.children, node)
    {
        if ([node respondsToSelector:@selector(setOpacity:)])
        {
            [(id<CCRGBAProtocol>)node setOpacity:opacity];
        }
    }
}



- (void)showWithLoadingBlock:(GenericBlock)loadingBlock withCallbackBlock:(GenericBlock)callbackBlock
{
    NSAssert(loadingBlock != nil, @"No loading method");

    // Put self on the scene
    [self setOpacity:255];
    [self setProgress:0];

    // Push scene on director
    if ([CCDirector sharedDirector].runningScene == nil)
    {
        [[CCDirector sharedDirector] pushScene:self.parent];
    }
    else
    {
        [[CCDirector sharedDirector] replaceScene:self.parent];
    }

    // Load
    __block typeof(_lock)myLock = _lock;
    __block typeof(_auxGLcontext)myAuxGLcontext = _auxGLcontext;

    dispatch_queue_t backgroundQueue = dispatch_queue_create("lv.earlybird.queue", 0);
    dispatch_async(backgroundQueue, ^{
        [myLock lock];
        [EAGLContext setCurrentContext:myAuxGLcontext];
        loadingBlock();
        [EAGLContext setCurrentContext:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (callbackBlock != nil)
            {
                callbackBlock();
            }
        });
        [myLock unlock];
    });
}


@end
