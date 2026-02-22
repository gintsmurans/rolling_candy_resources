//
//  ProgressBarLayer.m
//  Falling Candy
//
//  Created by Gints Murans on 6/19/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "ProgressBarLayer.h"

@implementation ProgressBarLayer

- (void)setSizeWidth:(float)width
{
    self.contentSize = CGSizeMake(width, self.contentSize.height);
}

@end
