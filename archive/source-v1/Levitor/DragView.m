//
//  DragView.m
//  Falling Candy
//
//  Created by Gints Murans on 2/20/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "DragView.h"
#import "AppDelegate.h"

@implementation DragView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint location = [self.documentView convertPoint:[theEvent locationInWindow] fromView:nil];

    for (NSImageView *imageView in ((NSView *)self.documentView).subviews)
    {
        if ([imageView isKindOfClass:[NSImageView class]] == NO || imageView.tag < 0)
        {
            continue;
        }

        CGRect r1 = CGRectMake(location.x, location.y, 5, 5);
        CGRect r2 = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);

        if (CGRectIntersectsRect(r1, r2))
        {
            draggingView = imageView;
            originalRect = imageView.frame;
            originalPoint = [draggingView convertPoint:location fromView:self.documentView];
            originalPoint.y = draggingView.frame.size.height - originalPoint.y;
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (draggingView)
    {
        NSPoint newLocation = [self.documentView convertPoint:[theEvent locationInWindow] fromView:nil];
        [draggingView setFrameOrigin:NSMakePoint(newLocation.x - originalPoint.x, newLocation.y - originalPoint.y)];

        if (draggingView.tag < 1000)
        {
            if (draggingView.frame.size.width > [self.documentView frame].size.width)
            {
                [draggingView setFrameOrigin:NSMakePoint(([self.documentView frame].size.width - draggingView.frame.size.width) / 2, draggingView.frame.origin.y)];
            }
            else
            {
                if (draggingView.frame.origin.x < 0)
                {
                    [draggingView setFrameOrigin:NSMakePoint(0, draggingView.frame.origin.y)];
                }

                if (draggingView.frame.origin.x > [self.documentView frame].size.width - draggingView.frame.size.width)
                {
                    [draggingView setFrameOrigin:NSMakePoint([self.documentView frame].size.width - draggingView.frame.size.width, draggingView.frame.origin.y)];
                }
            }

            if (draggingView.frame.origin.y < 0)
            {
                [draggingView setFrameOrigin:NSMakePoint(draggingView.frame.origin.x, 0)];
            }

            if (draggingView.tag != 101 && draggingView.frame.origin.y > [self.documentView frame].size.height - draggingView.frame.size.height)
            {
                [draggingView setFrameOrigin:NSMakePoint(draggingView.frame.origin.x, [self.documentView frame].size.height - draggingView.frame.size.height)];
            }
        }
    }
}


- (void)mouseUp:(NSEvent *)theEvent
{
    if (draggingView != nil)
    {
        [draggingView removeFromSuperview];
        if ((draggingView.frame.origin.x >= -draggingView.frame.size.width && draggingView.frame.origin.x < self.frame.size.width) || draggingView.tag < 1000)
        {
            [self.documentView addSubview:draggingView positioned:NSWindowAbove relativeTo:nil];
            if (draggingView.tag == 101)
            {
                NSPoint point = draggingView.frame.origin;
                float y = draggingView.frame.origin.y + draggingView.frame.size.height;
                y = MAX(y, self.frame.size.height - 2);
                [self.documentView setFrameSize:NSMakeSize([self.documentView frame].size.width, y)];
                [draggingView setFrameOrigin:point];

                [self.documentView scrollPoint:NSMakePoint(0, [self.documentView frame].size.height)];
            }

            if (draggingView.tag == 1005)
            {
                // Create the animation's path.
                NSPoint startPoint = draggingView.frame.origin;
                NSPoint endPoint = NSMakePoint(startPoint.x + 100, startPoint.y);

                CGMutablePathRef mutablepath = CGPathCreateMutable();
                CGPathMoveToPoint(mutablepath, NULL, startPoint.x, startPoint.y);
                CGPathAddLineToPoint(mutablepath, NULL, endPoint.x, endPoint.y);

                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setRepeatCount:2];
                [anim setPath:mutablepath];
                [anim setDuration:0.7];

                [draggingView setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
                [[draggingView animator] setFrameOrigin:startPoint];

                CGPathRelease(mutablepath);
            }

            if (draggingView.tag == 1006)
            {
                // Create the animation's path.
                NSPoint startPoint = draggingView.frame.origin;
                NSPoint endPoint = NSMakePoint(startPoint.x, startPoint.y + 150);
                
                CGMutablePathRef mutablepath = CGPathCreateMutable();
                CGPathMoveToPoint(mutablepath, NULL, startPoint.x, startPoint.y);
                CGPathAddLineToPoint(mutablepath, NULL, endPoint.x, endPoint.y);
                
                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setRepeatCount:2];
                [anim setPath:mutablepath];
                [anim setDuration:0.7];
                
                [draggingView setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
                [[draggingView animator] setFrameOrigin:startPoint];
                
                CGPathRelease(mutablepath);
            }


            if (draggingView.tag == 1007)
            {
                // Create the animation's path.
                NSPoint startPoint = draggingView.frame.origin;
                NSPoint endPoint = NSMakePoint(startPoint.x - 100, startPoint.y);
                
                CGMutablePathRef mutablepath = CGPathCreateMutable();
                CGPathMoveToPoint(mutablepath, NULL, startPoint.x, startPoint.y);
                CGPathAddLineToPoint(mutablepath, NULL, endPoint.x, endPoint.y);
                
                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setRepeatCount:2];
                [anim setPath:mutablepath];
                [anim setDuration:0.7];
                
                [draggingView setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
                [[draggingView animator] setFrameOrigin:startPoint];
                
                CGPathRelease(mutablepath);
            }


            if (draggingView.tag == 1008)
            {
                // Create the animation's path.
                NSPoint startPoint = draggingView.frame.origin;
                NSPoint endPoint = NSMakePoint(startPoint.x, startPoint.y - 150);
                
                CGMutablePathRef mutablepath = CGPathCreateMutable();
                CGPathMoveToPoint(mutablepath, NULL, startPoint.x, startPoint.y);
                CGPathAddLineToPoint(mutablepath, NULL, endPoint.x, endPoint.y);
                
                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setRepeatCount:2];
                [anim setPath:mutablepath];
                [anim setDuration:0.7];
                
                [draggingView setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"frameOrigin"]];
                [[draggingView animator] setFrameOrigin:startPoint];
                
                CGPathRelease(mutablepath);
            }
        }
        else
        {
            [(AppDelegate *)[[NSApplication sharedApplication] delegate] showPuffAnimationAtPoint:[theEvent locationInWindow]];
        }

        [(AppDelegate *)[[NSApplication sharedApplication] delegate] savePlayground];
        draggingView = nil;
    }
}

@end
