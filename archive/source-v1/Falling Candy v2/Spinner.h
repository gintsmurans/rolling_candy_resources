//
//  spinner.h
//  loading
//
//  Created by Aigars Mališevs on 3/22/12.
//  Copyright (c) 2012 autozinas.fm. All rights reserved.
//  

#import <UIKit/UIKit.h>

@interface Spinner : UIView
{
    UIActivityIndicatorView *_indicatorView;
}

+ (Spinner *)sharedSpinner;
- (void)presentSpinnerOverView:(UIView *)view;
- (void)presentSpinnerOverApplication;
- (void)dismissSpinner;

@end
