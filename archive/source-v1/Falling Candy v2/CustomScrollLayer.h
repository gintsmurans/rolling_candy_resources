//
//  CustomScrollLayer.h
//
//  Copyright 2010 DK101
//  http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
//
//  Copyright 2010 Giv Parvaneh.
//  http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
//
//  Copyright 2011-2012 Stepan Generalov
//  Copyright 2011 Brian Feller
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <Foundation/Foundation.h>
#import "cocos2d.h"


@protocol CustomScrollLayerDelegate<NSObject>

- (void)scrolling;

@end


@interface CustomScrollLayer : CCLayer
{
    CGPoint _originalPositon;
    CGPoint _originalPoint;
    CGSize _screenSize;

	// Internal state of scrollLayer (scrolling or idle).
	int _state;
	UITouch *_scrollTouch;
    NSDate *_time;
}

#pragma mark Scroll Config Properties

@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;
@property(readwrite) BOOL stealTouches;
@property(nonatomic, retain) id<CustomScrollLayerDelegate> delegate;


#pragma mark Init/Creation

+ (id)node;
- (id)init;

@end
