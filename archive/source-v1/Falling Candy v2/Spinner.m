//
//  spinner.m
//  loading
//
//  Created by Aigars Mališevs on 3/22/12.
//  Copyright (c) 2012 autozinas.fm. All rights reserved.
//

#import "Spinner.h"
#import "QuartzCore/QuartzCore.h"

@implementation Spinner


+ (Spinner *)sharedSpinner
{
    static dispatch_once_t once;
    static Spinner *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    if ((self = [super init]))
    {
        [self setFrame:[UIScreen mainScreen].bounds];
        [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]];

        UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 140.0f, 140.0f)] autorelease];
        [bgView setAutoresizingMask:UIViewAutoresizingNone];
        [bgView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f]];
        [bgView.layer setCornerRadius:10.0f];
        [bgView setCenter:self.center];
        [self addSubview:bgView];

        _indicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        [_indicatorView setAutoresizingMask:UIViewAutoresizingNone];
        [_indicatorView setCenter:self.center];
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)presentSpinnerOverView:(UIView *)view
{
    [_indicatorView startAnimating];
    [self setFrame:view.frame];
    [view addSubview:self];
}

- (void)presentSpinnerOverApplication
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self setFrame:window.frame];
    [_indicatorView startAnimating];
    [window addSubview:self];
}

- (void)dismissSpinner
{
    [self removeFromSuperview];
    [_indicatorView stopAnimating];
}

@end
