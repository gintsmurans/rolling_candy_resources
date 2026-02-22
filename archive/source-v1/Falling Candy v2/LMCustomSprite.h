//
//  LMCustomSprite.h
//  Falling Candy
//
//  Created by Gints Murans on 5/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "cocos2d.h"
#import "CCTouchDispatcher.h"

typedef void (^GenericBlock)();

@interface LMCustomSprite : CCSprite <CCTouchOneByOneDelegate>
{
    BOOL _touchInProgress;
}
@property (nonatomic, retain) NSString *enabledFrameName;
@property (nonatomic, assign, getter = isDisabled) BOOL disabled;
@property (nonatomic, assign, getter = isDone) BOOL done;
@property (nonatomic, copy) GenericBlock touchUpBlock;
@end
