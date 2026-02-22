//
//  SharedActions.m
//  Falling Candy
//
//  Created by Gints Murans on 3/28/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "SharedActions.h"
#import "Macros.h"
#import "SimpleAudioEngine.h"


@implementation SharedActions
@synthesize gravityX, gravityY, filtering, damping;

+ (SharedActions *)sharedActions
{
    static dispatch_once_t once;
    static SharedActions *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        self.gravityX = 550;
        self.gravityY = -35;
        self.filtering = 0.7;
        self.damping = 0.5;
    }
    return self;
}

- (void)dealloc
{
    [_levels release];
    [super dealloc];
}


#pragma mark - Actions

- (CCAction *)buttonSelectedAction
{
    id action2 = [CCScaleTo actionWithDuration:0.1 scaleX:0.8 scaleY:0.8];
    return action2;
}

- (CCAction *)buttonUnselectedAction
{
    id scale = [CCScaleTo actionWithDuration:0.1 scaleX:1.0 scaleY:1.0];
    return scale;
}

- (CCAction *)buttonActivateAction
{
    id scale1 = [CCScaleTo actionWithDuration:0.1 scaleX:1.3 scaleY:0.4];
    id scale2 = [CCScaleTo actionWithDuration:0.1 scaleX:0.7 scaleY:1.3];
    id scale3 = [CCScaleTo actionWithDuration:0.1 scaleX:1.1 scaleY:0.9];
    id scale4 = [CCScaleTo actionWithDuration:0.1 scaleX:0.9 scaleY:1.1];
    id scaleO = [CCScaleTo actionWithDuration:0.05 scaleX:1.0 scaleY:1.0];

    CCSequence *sequence = [CCSequence actions:scale1, scale2, scale3, scale4, scaleO, nil];
    return sequence;
}

- (CCAction *)buttonDisabledUnselectedAction
{
    id action4 = [CCRotateTo actionWithDuration:0.05 angle:15];
    id action5 = [CCRotateTo actionWithDuration:0.05 angle:-15];
    id action6 = [CCRotateTo actionWithDuration:0.05 angle:0.0];

    CCSequence *scaleSeq = [CCSequence actions:action4, action5, action6, nil];
    CCAction *action = [CCRepeat actionWithAction:scaleSeq times:2];
    return action;
}


#pragma mark Character

- (id)characterBored
{
    // Skew
    id cSkew1 = [CCSkewTo actionWithDuration:2.0f skewX:-3 skewY:0];
    id cSkew2 = [CCSkewTo actionWithDuration:2.0f skewX:+3 skewY:0];
    id cSeq3 = [CCSequence actions:cSkew1, cSkew2, nil];
    id cRep3 = [CCRepeat actionWithAction:cSeq3 times:INFINITY];

    // Scal
    id cScal1 = [CCScaleTo actionWithDuration:0.3f scaleX:1.05f scaleY:0.95f];
    id cScal2 = [CCScaleTo actionWithDuration:0.3f scaleX:1.0f scaleY:1.0f];
    id cSeq4 = [CCSequence actions:cScal1, cScal2, nil];
    id cRep4 = [CCRepeat actionWithAction:cSeq4 times:INFINITY];

    id cSpawn = [CCSpawn actions:cRep3, cRep4, nil];
    [cSpawn setTag:ANI_CHARACTER_BORED];

    return cSpawn;
}


- (id)characterOpenMouth
{
    NSMutableArray *animationFrames = [NSMutableArray array];
    for (int i = 1; i <= 19; i++)
    {
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"lacis-%d.png", i]]];
    }
    CCAnimation *lacisAnimOpen = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.015f];
    [lacisAnimOpen setRestoreOriginalFrame:NO];
    id cAni = [CCAnimate actionWithAnimation:lacisAnimOpen];
    [cAni setTag:ANI_CHARACTER_OPEN_MOUTH];
    return cAni;
}


- (id)characterSad
{
    NSMutableArray *animationFrames = [NSMutableArray array];
    for (int i = 1; i <= 6; i++)
    {
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"negativais-end%d.png", i]]];
    }
    CCAnimation *lacisAnimSad = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.015f];
    [lacisAnimSad setRestoreOriginalFrame:NO];
    id cAni = [CCAnimate actionWithAnimation:lacisAnimSad];
    [cAni setTag:ANI_CHARACTER_SAD];
    return cAni;
}


- (id)characterEating
{
    NSMutableArray *animationFrames = [NSMutableArray array];
    for (int i = 1; i <= 7; i++)
    {
        [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"pozitivais-end%d.png", i]]];
    }
    CCAnimation *lacisAnimHappy = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.09f];
    [lacisAnimHappy setRestoreOriginalFrame:NO];

    id cAni = [CCAnimate actionWithAnimation:lacisAnimHappy];
    [cAni setTag:ANI_CHARACTER_EATING];
    return cAni;
}


- (id)characterEyeBlink
{
    NSMutableArray *animationFrames = [NSMutableArray array];
    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lacis-closed-eyes.png"]];
    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lacis-1.png"]];
    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lacis-closed-eyes.png"]];
    [animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lacis-1.png"]];
    CCAnimation *lacisCloseEyes = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
    [lacisCloseEyes setRestoreOriginalFrame:NO];
    return [CCAnimate actionWithAnimation:lacisCloseEyes];
}



#pragma mark Game buttons
- (CCAction *)pauseButtonSelectedAction
{
    id action2 = [CCScaleTo actionWithDuration:0.1 scaleX:0.9 scaleY:0.9];
    return action2;
}
- (CCAction *)pauseButtonUnselectedAction
{
    id scale = [CCScaleTo actionWithDuration:0.1 scaleX:1.0 scaleY:1.0];
    return scale;
}
- (CCAction *)pauseButtonActivateAction
{
    id scale1 = [CCScaleTo actionWithDuration:0.1 scaleX:1.3 scaleY:0.4];
    id scale2 = [CCScaleTo actionWithDuration:0.1 scaleX:0.7 scaleY:1.3];
    id scale3 = [CCScaleTo actionWithDuration:0.1 scaleX:1.1 scaleY:0.9];
    id scale4 = [CCScaleTo actionWithDuration:0.1 scaleX:0.9 scaleY:1.1];
    id scaleO = [CCScaleTo actionWithDuration:0.1 scaleX:1.0 scaleY:1.0];

    CCSequence *sequence = [CCSequence actions:scale1, scale2, scale3, scale4, scaleO, nil];
    return sequence;
}



- (void)playButtonSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"buttons.m4a"];
}



#pragma mark - Textures

- (CCSprite *)spriteWithColor:(ccColor4F)bgColor textureSize:(CGSize)textureSize
{
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height];

    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];

    // 3: Draw into the texture
    CCSprite *noise = [CCSprite spriteWithFile:@"Noise.jpg"];
    noise.scale = 2.0;
    [noise setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
    noise.position = ccp(textureSize.width/2, textureSize.height/2);
    [noise visit];

    // 4: Call CCRenderTexture:end
    [rt end];

    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}


- (ccColor4F)randomBrightColor
{
    while (true)
    {
        float requiredBrightness = 192;
        ccColor4B randomColor = ccc4(arc4random() % 255, arc4random() % 255, arc4random() % 255, 255);
        if (randomColor.r > requiredBrightness ||
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness)
        {
            return ccc4FFromccc4B(randomColor);
        }
    }
}



- (CCRenderTexture *) createStroke:(CCLabelTTF*) label size:(float)size color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
	[label setColor:cor];
	[label setVisible:YES];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint meio = ccp(label.texture.contentSize.width/2+size, label.texture.contentSize.height/2+size);
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[label setPosition:ccp(meio.x + sin(CC_DEGREES_TO_RADIANS(i))*size, meio.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:originalPos];
	return rt;
}



- (NSString *)documentPath:(NSString *)append
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:append];
}


- (NSDictionary *)loadLevels
{
    if (_levels == nil)
    {
        NSString *levelsPath = [self documentPath:@"Levels.json"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSData *data;
        if ([fileMgr fileExistsAtPath:levelsPath])
        {
            data = [NSData dataWithContentsOfFile:levelsPath];
        }
        else
        {
            levelsPath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"json"];
            data = [NSData dataWithContentsOfFile:levelsPath];
        }
        _levels = [(NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] retain];
    }
    return _levels;
}

- (void)clearLevelCache
{
    [_levels release], _levels = nil;
}



@end
