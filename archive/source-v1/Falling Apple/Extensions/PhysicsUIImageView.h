//
//  PhysicsUIImageView.h
//  Falling Candy
//
//  Created by Gints Murans on 2/11/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//


@interface PhysicsUIImageView : UIImageView

@property (nonatomic, assign) int score;
@property (nonatomic, assign, getter = isAnimatingCustom) BOOL animatingCustom;
@property (nonatomic, assign) CGRect testFrame;
@property (nonatomic, assign) CGSize originalTestSize;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) float stickiness;
@property (nonatomic, assign) float rotation;

@property (nonatomic, assign) float moveX;
@property (nonatomic, assign) float moveY;
@property (nonatomic, assign) float movingX;
@property (nonatomic, assign) float movingY;
@property (nonatomic, assign) float movingXV;
@property (nonatomic, assign) float movingYV;

@end
