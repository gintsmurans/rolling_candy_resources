//
//  PlaygroundView.m
//  Falling Candy
//
//  Created by Gints Murans on 2/21/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "PlaygroundView.h"

@implementation PlaygroundView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    NSColor *color = [NSColor colorWithSRGBRed:1.0 green:0.0 blue:0.0 alpha:0.3];
    NSMutableDictionary *drawStringAttributes = [[NSMutableDictionary alloc] init];
	[drawStringAttributes setValue:color forKey:NSForegroundColorAttributeName];
	[drawStringAttributes setValue:[NSFont fontWithName:@"Helvetica Neue Light" size:14] forKey:NSFontAttributeName];

    float height = [self.superview frame].size.height;
    float width = [self.superview frame].size.width;
    int line_count = (int)(self.frame.size.height / height) + 1;
    for (int i = 1; i <= line_count; ++i)
    {
        [color setStroke];

        float y = height * i + 1;
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(0, y)];
        [line lineToPoint:NSMakePoint([self.superview frame].size.width, y)];
        [line setLineWidth:1.0];
        [line stroke];

        NSString *string = [NSString stringWithFormat:@"%d", i];
        NSSize stringSize = [string sizeWithAttributes:drawStringAttributes];
        NSPoint centerPoint;
        centerPoint.x = width - stringSize.width - 10;
        centerPoint.y = y - height;
        [string drawAtPoint:centerPoint withAttributes:drawStringAttributes];
    }

    [drawStringAttributes release];
}

- (BOOL)isFlipped
{
    return YES;
}

@end
