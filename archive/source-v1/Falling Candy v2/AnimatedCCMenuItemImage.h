//
//  AnimatedCCMenuItemImage.h
//  Falling Candy
//
//  Created by Gints Murans on 3/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "CCMenuItem.h"

#define kSelectedAction -10
#define kUnselectedAction -11
#define kActivateAction -12

@interface AnimatedCCMenuItemImage : CCMenuItemImage
@property (nonatomic, assign, getter = isDisabled) BOOL disabled;
@property (nonatomic, retain) id selectedAction;
@property (nonatomic, retain) id unselectedAction;
@property (nonatomic, retain) id activateAction;
@property (nonatomic, retain) NSString *buttonSound;
@end
