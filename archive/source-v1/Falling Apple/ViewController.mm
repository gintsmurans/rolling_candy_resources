//
//  ViewController.m
//  Falling Apple
//
//  Created by Gints Murans on 1/23/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <StoreKit/StoreKit.h>

#import "SimpleAudioEngine.h"
#import "GAI.h"

#import "ViewController.h"
#import "AppIAPHelper.h"


#define IS_PHONE5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define P(x,y) CGPointMake(x, y)


#define STICKY_THRESHOLD 0.7

#define TAG_BRICK_1 1000
#define TAG_BRICK_2 1001
#define TAG_BRICK_3 1002
#define TAG_RED_BRICK 1004
#define TAG_BRICK_MOVING_RIGHT 1005
#define TAG_BRICK_MOVING_DOWN 1006
#define TAG_BRICK_MOVING_LEFT 1007
#define TAG_BRICK_MOVING_UP 1008

#define TAG_WATERMELON 2001
#define TAG_BANANA 2002
#define TAG_STRAWBERRY 2003
#define TAG_SPRING 2004
#define TAG_BOX 2005
#define TAG_HELPER 2006
#define TAG_SANDCLOCK 2007
#define TAG_COIN 2008
#define TAG_CHEST 2009
#define TAG_COIN_PILE 2010

#define TAG_SAW 3000
#define TAG_FIRE 3001

#define TAG_CAVE 4000


@interface ViewController ()

@end

@implementation ViewController
@synthesize running;


- (void)dealloc
{
    NSLog(@"!! DEALLOC !!");

    [HelperTest release];
    
    [Products release];
    [FinishedLevels release];
    [Settings release];

    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load settings
    Settings = [[NSUserDefaults standardUserDefaults] retain];
    TotalScore = [Settings integerForKey:@"TotalScore"];
    FinishedLevels = [[Settings objectForKey:@"FinishedLevels"] mutableCopy];
    if (FinishedLevels == nil)
    {
        FinishedLevels = [[NSMutableDictionary alloc] init];
    }
    LevelsUnlocked = [Settings boolForKey:@"fb6c4430"];
    // TODO: Remove ->
    LevelsUnlocked = YES;

    // Read pre-generated levels
    NSString *levels_path = [self documentPath:@"Levels.plist"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:levels_path])
    {
        levels = [[NSDictionary alloc] initWithContentsOfFile:levels_path];
    }
    else
    {
        levels_path = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
        levels = [[NSDictionary alloc] initWithContentsOfFile:levels_path];
    }

    // Setup some variables
    GameOverPosition = CandyView.frame.size.width * 2;
    TotalThemes = 3;
    TotalLevels = 20;
    CurrTheme = 1;
    SoundIsOn = YES;

    // Setup small font
    UIFont *small_font = [UIFont fontWithName:@"GROBOLD" size:15.0f];
    [CurrScoreLabel setFont:small_font];
    [HighScoreLabel setFont:small_font];
    [FruitScoreLabel setFont:small_font];

    // Setup big font
    BigFont = [UIFont fontWithName:@"GROBOLD" size:24.0f];
    [ShareTitleLabel setFont:BigFont];
    [HelperSecondsLabel setFont:BigFont];
    [TotalScoreLabel setFont:BigFont];

    [SuccessScoreLabel setFont:[UIFont fontWithName:@"GROBOLD" size:28.0f]];
    [SuccessLevelLabel setFont:[UIFont fontWithName:@"GROBOLD" size:18.0f]];

    // Setup level's view
    [self initLevels];
    [self updateTotalScore];


    // Setup game's views
    [SuccessView setCenter:GameView.center];
    [SuccessView setAlpha:0.0f];
    [CandyView.layer setShadowColor:[UIColor blackColor].CGColor];
    [CandyView.layer setShadowOpacity:0.7f];
    [CandyView.layer setShadowOffset:CGSizeMake(1.0f, 1.0f)];
    [CandyView.layer setShadowRadius:0.7f];


    // Pre-load game animations
    candyShineAnimation = [[NSArray alloc] initWithObjects:
                           [UIImage imageNamed:@"candy-g1.png"],
                           [UIImage imageNamed:@"candy-g2.png"],
                           [UIImage imageNamed:@"candy-g3.png"],
                           [UIImage imageNamed:@"candy-g4.png"],
                           [UIImage imageNamed:@"candy-g5.png"],nil];

    // Home screen rotating candy
    [RCandy setAnimationImages:[NSArray arrayWithObjects:
                                [UIImage imageNamed:@"rcandy-1.png"],
                                [UIImage imageNamed:@"rcandy-2.png"],
                                [UIImage imageNamed:@"rcandy-3.png"],nil]];
    [RCandy setAnimationDuration:0.30f];
    [RCandy setAnimationRepeatCount:INFINITY];
    [RCandy startAnimating];

    // Put all views on wrapper view
    [self.view addSubview:GameView];
    [self.view addSubview:LevelsView];
    [self.view addSubview:HomeView];


    // Setup Loader
    [LoaderView setAlpha:0.0f];
    [LoaderView setCenter:LevelsView.center];
    [LoaderBg.layer setCornerRadius:10.0];
    [LoaderBg.layer setMasksToBounds:YES];

    // Load audio files
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-home.m4a"];


    // Add white view
    UIView *white_view = [[UIView alloc] initWithFrame:GameView.frame];
    [white_view setBackgroundColor:[UIColor whiteColor]];
    [white_view setTag:-1000];
    [GameView insertSubview:white_view belowSubview:SuccessView];
    [white_view release];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"!! MEMORY WARNING !!");
    [super didReceiveMemoryWarning];
}



#pragma mark - Purchases

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];

    // TODO: Remove ->
    [self initDropbox];
    if ([[DBSession sharedSession] isLinked])
    {
        [loadAllLevelsFromDropboxButton setTitle:@"Load All" forState:UIControlStateNormal];
    }
    else
    {
        [loadAllLevelsFromDropboxButton setTitle:@"Dropbox Access" forState:UIControlStateNormal];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadProducts:(void (^)(BOOL))callback
{
    [[AppIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            if (Products != nil)
            {
                [Products release], Products = nil;
            }
            Products = [products retain];
        }
        callback(success);
    }];
}


- (void)productPurchased:(NSNotification *)notification
{
    LevelsUnlocked = [Settings boolForKey:@"fb6c4430"];
    
    if (LevelsUnlocked)
    {
        UIButton *button;
        int theme = 1, level = 1;
        while ((button = (UIButton *)[LevelsView viewWithTag:100 * theme + level]))
        {
            [button setEnabled:YES];
            [[button viewWithTag:1] setHidden:NO];
            [[button viewWithTag:2] setHidden:NO];
            [[button viewWithTag:3] setHidden:NO];
            
            level += 1;
            if (level >= 21)
            {
                level = 1;
            }
            theme += 1;
        }
    }

    [UIView animateWithDuration:0.2 animations:^{
        [LoaderView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [LoaderIndicator stopAnimating];
        if (LevelsUnlocked)
        {
            UIButton *button;
            while ((button = (UIButton *)[LevelsView viewWithTag:-20000]))
            {
                [button removeFromSuperview];
            }
        }
    }];
}



#pragma mark - Init levels

- (void)initLevels
{
    // Doors
    float door_pos_x = 0, door_pos_y = 0;
    CGSize frame_size = [UIScreen mainScreen].bounds.size;
    UIButton *doorView;

    // Buttons
    float button_gap_x = 10, button_gap_y = 10;
    float button_initial_x = 30, button_initial_y = 75;
    float star_initial_x, star_initial_y = 35;
    CGRect button_frame;
    UIImageView *theme_view;
    UIButton *button;
    UIImageView *star;

    // Open levels
    NSDictionary *level_done;
    BOOL is_level_open;
    int stars;

    // Set themes view wrapper size
    [ThemesView setContentSize:CGSizeMake(frame_size.width * TotalThemes, frame_size.height)];

    // Add themes views
    for (int theme = 1; theme <= TotalThemes; ++theme)
    {
        // Make doors view
        doorView = [[UIButton alloc] init];
        [doorView addTarget:self action:@selector(openThemeDoors:) forControlEvents:UIControlEventTouchUpInside];
        [doorView setTag:-theme];
        [doorView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"themes-doors-%d.png", theme]] forState:UIControlStateNormal];
        [doorView setTitle:@"" forState:UIControlStateNormal];
        [doorView sizeToFit];

        if (theme == 1)
        {
            door_pos_y = frame_size.height - doorView.frame.size.height - (235.0 / 2);
        }
        else
        {
            door_pos_y = frame_size.height - doorView.frame.size.height - (202.0 / 2);
        }
        [doorView setFrame:CGRectMake((frame_size.width - doorView.frame.size.width) / 2 + door_pos_x, door_pos_y, doorView.frame.size.width, doorView.frame.size.height)];
        [ThemesView addSubview:doorView];
        door_pos_x += frame_size.width;


        // Make hidden levels button view
        theme_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame_size.width, frame_size.height)];
        [theme_view setHidden:YES];
        [theme_view setAlpha:0.0f];
        [theme_view setImage:[UIImage imageNamed:[NSString stringWithFormat:@"open-levels-bg-%d.png", theme]]];
        [theme_view setUserInteractionEnabled:YES];
        [theme_view setTag:-(100 * theme)];

        // Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 25.0f, 320, 35)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont fontWithName:@"GROBOLD" size:26.0f]];
        [title setTextAlignment:NSTextAlignmentCenter];
        [title setText:@"Stonehenge"];
        [title.layer setShadowColor:[UIColor blackColor].CGColor];
        [title.layer setShadowOffset:CGSizeMake(0, 1)];
        [title.layer setShadowOpacity:1.0f];
        [title.layer setShadowRadius:1.0f];
        [theme_view addSubview:title];

        // Close doors
        UIButton *close_doors_button = [[UIButton alloc] init];
        [close_doors_button addTarget:self action:@selector(closeThemeDoors:) forControlEvents:UIControlEventTouchUpInside];
        [close_doors_button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [close_doors_button sizeToFit];
        [close_doors_button setFrame:CGRectMake(30, theme_view.frame.size.height - close_doors_button.frame.size.height - 17, close_doors_button.frame.size.width, close_doors_button.frame.size.height)];
        [theme_view addSubview:close_doors_button];
        [close_doors_button release];

        // Unlock all levels
        if (LevelsUnlocked == NO)
        {
            UIButton *unlock_all_button = [[UIButton alloc] init];
            [unlock_all_button setTag:-20000];
            [unlock_all_button addTarget:self action:@selector(unlockAllAction:) forControlEvents:UIControlEventTouchUpInside];
            [unlock_all_button setImage:[UIImage imageNamed:@"btn-unlock-all.png"] forState:UIControlStateNormal];
            [unlock_all_button sizeToFit];
            [unlock_all_button setFrame:CGRectMake(theme_view.frame.size.width - unlock_all_button.frame.size.width - 30, theme_view.frame.size.height - unlock_all_button.frame.size.height - 20, unlock_all_button.frame.size.width, unlock_all_button.frame.size.height)];
            [theme_view addSubview:unlock_all_button];
            [unlock_all_button release];
        }


        button_frame = CGRectMake(button_initial_x, button_initial_y, 57, 54);
        for (int level = 1; level <= TotalLevels; ++level)
        {
            stars = 0;

            // Play level button
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(playLevelAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setFrame:button_frame];
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"level-%d.png", theme]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"level-locked-%d.png", theme]] forState:UIControlStateDisabled];
            [button setTitle:[NSString stringWithFormat:@"%d", level] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateDisabled];
            [button.titleLabel setFont:BigFont];
            [button.titleLabel setTextColor:[UIColor whiteColor]];
            [button.titleLabel setShadowColor:[UIColor blackColor]];
            [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
            [button setTag:100 * theme + level];
            [theme_view addSubview:button];

            level_done = [FinishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", theme, level]];
            if (level_done != nil)
            {
                stars = [[level_done objectForKey:@"stars"] intValue];
                is_level_open = YES;
            }
            else if (theme == 1 && level == 1)
            {
                is_level_open = YES;
            }
            else
            {
                is_level_open = LevelsUnlocked;
            }
            [button setEnabled:is_level_open];
            
            
            star_initial_x = 9;
            star = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"star-small-empty-%d.png", theme]]] autorelease];
            [star setFrame:CGRectMake(star_initial_x, star_initial_y, star.frame.size.width, star.frame.size.height)];
            [star setHighlightedImage:[UIImage imageNamed:@"star-small.png"]];
            [star setHidden:!is_level_open];
            [star setTag:1];
            if (stars > 0)
            {
                [star setHighlighted:YES];
            }
            [button addSubview:star];

            star_initial_x += star.frame.size.width + 1;
            star = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"star-small-empty-%d.png", theme]]] autorelease];
            [star setFrame:CGRectMake(star_initial_x, star_initial_y, star.frame.size.width, star.frame.size.height)];
            [star setHighlightedImage:[UIImage imageNamed:@"star-small.png"]];
            [star setHidden:!is_level_open];
            [star setTag:2];
            if (stars > 1)
            {
                [star setHighlighted:YES];
            }
            [button addSubview:star];
            
            star_initial_x += star.frame.size.width + 1;
            star = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"star-small-empty-%d.png", theme]]] autorelease];
            [star setFrame:CGRectMake(star_initial_x, star_initial_y, star.frame.size.width, star.frame.size.height)];
            [star setHighlightedImage:[UIImage imageNamed:@"star-small.png"]];
            [star setHidden:!is_level_open];
            [star setTag:3];
            if (stars > 2)
            {
                [star setHighlighted:YES];
            }
            [button addSubview:star];

            button_frame.origin.x += button_frame.size.width + button_gap_x;
            if (level % 4 == 0)
            {
                button_frame.origin.x = button_initial_x;
                button_frame.origin.y += button_frame.size.height + button_gap_y;
            }
        }
        [LevelsView addSubview:theme_view];
        [theme_view release];
    }
}


- (void)openThemeDoors:(UIButton *)sender
{
    CurrTheme = (int)(ThemesView.contentOffset.x / [UIScreen mainScreen].bounds.size.width) + 1;
    UIView *theme_view = [LevelsView viewWithTag:sender.tag * 100];
    [ThemesView setScrollEnabled:NO];

    [theme_view setHidden:NO];
    [UIView animateWithDuration:0.3f animations:^{
        [theme_view setAlpha:1.0f];
    }];
}

- (void)closeThemeDoors:(UIButton *)sender
{
    UIView *theme_view = [LevelsView viewWithTag:-CurrTheme * 100];
    [UIView animateWithDuration:(sender == nil ? 0.0f : 0.3f) animations:^{
        [theme_view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [ThemesView setScrollEnabled:YES];
        [theme_view setHidden:YES];
    }];
}



#pragma mark - Sounds


- (void)playButtonSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"buttons.m4a" pitch:1.0f pan:0.0f gain:1.0];
}
- (void)playPuffSound
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"puff.m4a" pitch:1.0f pan:0.0f gain:1.0];
}




#pragma mark - Helpers


- (void)saveFinishedLevels
{
    [Settings setObject:FinishedLevels forKey:@"FinishedLevels"];
    [Settings synchronize];
}


- (void)refreshScore
{
    [CurrScoreLabel setText:[NSString stringWithFormat:@"SCORE\n%d", CurrScore]];
}


- (void)animateSuccessStars:(CADisplayLink *)sender
{
    if (SuccessView.alpha == 0.0f)
    {
        [displayLink invalidate], displayLink = nil;
        return;
    }


    int cc_score = [[SuccessScoreLabel.text stringByReplacingOccurrencesOfString:@"Score: " withString:@""] intValue];
    cc_score += ceilf(((float)CurrScore) / 500 * 20);

    if (cc_score >= CurrScore)
    {
        cc_score = CurrScore;
        successInterval += 1;
        if (successInterval % 10 == 0)
        {
            successStar += 1;
        }

        if (successStar > CurrStars)
        {
            [displayLink invalidate], displayLink = nil;

            if (CurrStars > 0)
            {
                UIImage *greeting;
                if (CurrStars == 1)
                {
                    greeting = [UIImage imageNamed:@"well-done.png"];
                }
                else if (CurrStars == 2)
                {
                    greeting = [UIImage imageNamed:@"great.png"];
                }
                else
                {
                    greeting = [UIImage imageNamed:@"perfect.png"];
                }

                [GreetingsImageView setImage:greeting];
                [GreetingsImageView setHidden:NO];

                // Add animation
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                anim.toValue = [NSNumber numberWithDouble:1.5];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setDuration:0.4];
                [GreetingsImageView.layer addAnimation:anim forKey:@"race"];
            }
        }
        else
        {
            UIImageView *star = (UIImageView *)[SuccessView viewWithTag:successStar];
            if (star.isHighlighted == NO)
            {
                [star setHighlighted:YES];
                [[SimpleAudioEngine sharedEngine] playEffect:@"timp.m4a" pitch:1.0f pan:0.0f gain:1.0];

                // Add animation
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                anim.toValue = [NSNumber numberWithDouble:1.5];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [anim setRemovedOnCompletion:YES];
                [anim setAutoreverses:YES];
                [anim setDuration:0.4];
                [star.layer addAnimation:anim forKey:@"race"];
            }
        }
    }

    [SuccessScoreLabel setText:[NSString stringWithFormat:@"Score: %d", cc_score]];
}


- (void)showSuccessViewWithFailed:(BOOL)failed
{
    [self stopGame];
    successAnimating = YES;
    successInterval = 0;
    successStar = 1;

    if (failed)
    {
        [TheWorm setImage:[UIImage imageNamed:@"green-sad.png"]];
        [UIView animateWithDuration:0.5 animations:^{
            [CandyView setCenter:CGPointMake(playground.center.x, fabs(playground.frame.origin.y) + (playground.frame.size.height / 3))];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [CandyView setCenter:CGPointMake(playground.center.x, fabs(playground.frame.origin.y) + playground.frame.size.height + CandyView.frame.size.height)];
            } completion:^(BOOL finished) {
                successAnimating = NO;
                [self SuccessReplayButtonAction:nil];
            }];
        }];
    }
    else
    {
        float scored_progress = ((CurrScore + 10) * 100 / MaxScore);
        if (scored_progress >= 80)
        {
            CurrStars = 3;
        }
        else if (scored_progress >= 60)
        {
            CurrStars = 2;
        }
        else if (scored_progress >= 40)
        {
            CurrStars = 1;
        }
        else
        {
            CurrStars = 0;
        }

        // Save result
        NSString *level_number = [NSString stringWithFormat:@"%d:%d", CurrTheme, CurrLevel];
        NSMutableDictionary *level_done = [[FinishedLevels objectForKey:level_number] mutableCopy];
        if (level_done == nil)
        {
            level_done = [[NSMutableDictionary alloc] init];
            [level_done setObject:[NSNumber numberWithInt:CurrLevel] forKey:@"level"];
        }

        if (CurrScore > CurrHighScore)
        {
            [level_done setObject:[NSNumber numberWithInt:CurrScore] forKey:@"score"];
            TotalScore = TotalScore - CurrHighScore + CurrScore;
            [Settings setInteger:TotalScore forKey:@"TotalScore"];
            [self updateTotalScore];
        }

        // Current level button
        int stars = [[level_done objectForKey:@"stars"] intValue];
        if (CurrStars > stars)
        {
            [level_done setObject:[NSNumber numberWithInt:CurrStars] forKey:@"stars"];

            UIButton *button = (UIButton *)[LevelsView viewWithTag:100 * CurrTheme + CurrLevel];
            if (CurrStars > 0)
            {
                [((UIImageView *)[button viewWithTag:1]) setHighlighted:YES];
            }
            if (CurrStars > 1)
            {
                [((UIImageView *)[button viewWithTag:2]) setHighlighted:YES];
            }
            if (CurrStars > 2)
            {
                [((UIImageView *)[button viewWithTag:3]) setHighlighted:YES];
            }
        }
        [FinishedLevels setObject:level_done forKey:level_number];
        [level_done release], level_done = nil;

        // Open next level
        if (CurrTheme < TotalThemes || CurrLevel < TotalLevels)
        {
            int theme = (CurrLevel == TotalLevels ? CurrTheme + 1 : CurrTheme);
            int level = (CurrLevel == TotalLevels ? 1 : CurrLevel + 1);
            level_number = [NSString stringWithFormat:@"%d:%d", theme, level];
            level_done = [[FinishedLevels objectForKey:level_number] mutableCopy];
            if (level_done == nil)
            {
                level_done = [[NSMutableDictionary alloc] init];
                [level_done setObject:[NSNumber numberWithInt:CurrLevel+1] forKey:@"level"];
                [FinishedLevels setObject:level_done forKey:level_number];
            }
            [level_done release], level_done = nil;

            UIButton *button = (UIButton *)[LevelsView viewWithTag:100 * theme + level];
            [button setEnabled:YES];
            [[button viewWithTag:1] setHidden:NO];
            [[button viewWithTag:2] setHidden:NO];
            [[button viewWithTag:3] setHidden:NO];
        }

        // Sync settings
        [self saveFinishedLevels];


        // Update Views
        [GreetingsImageView setHidden:YES];
        [SuccessScoreLabel setText:[NSString stringWithFormat:@"Score: 0"]];
        [SuccessLevelLabel setText:[NSString stringWithFormat:@"Level %d completed", CurrLevel]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"crunch.m4a" pitch:1.0f pan:0.0f gain:1.0];

        UIImageView *star = (UIImageView *)[SuccessView viewWithTag:1];
        [star setHighlighted:NO];
        star = (UIImageView *)[SuccessView viewWithTag:2];
        [star setHighlighted:NO];
        star = (UIImageView *)[SuccessView viewWithTag:3];
        [star setHighlighted:NO];

        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        anim.toValue = [NSNumber numberWithDouble:(M_PI * 360) / 180];
        [anim setRemovedOnCompletion:NO];
        [anim setAutoreverses:NO];
        [anim setRepeatCount:INFINITY];
        [anim setDuration:10.0];
        [SuccessSunView.layer addAnimation:anim forKey:@"race"];


        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.3 animations:^{
                [CandyView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    [SuccessView setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    successAnimating = NO;

                    // Start stars animation
                    displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(animateSuccessStars:)] retain];
                    [displayLink setFrameInterval:1];
                    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                }];
            }];
        });
    }
}

- (void)updateTotalScore
{
    [TotalScoreLabel setText:[NSString stringWithFormat:@"Total Score: %d", TotalScore]];
}


- (void)showLevels:(UIView *)fromView
{
    [[[GAI sharedInstance] defaultTracker] sendView:@"Levels View"];

    [UIView transitionFromView:fromView toView:LevelsView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        if (SoundIsOn)
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-levels.m4a"];
        }
    }];
}



#pragma mark - IBActions

- (void)homePlayButtonAction:(id)sender
{
    [self playButtonSound];

    if (SoundIsOn)
    {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-home.m4a"];
    }
    [self showLevels:HomeView];
    [RCandy stopAnimating];
}


- (void)pauseSoundAction:(UIButton *)sender
{
    if (sender.isSelected)
    {
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Pause Sound" withLabel:@"Play" withValue:0];
        SoundIsOn = YES;
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-home.m4a"];
        [sender setSelected:NO];
    }
    else
    {
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Pause Sound" withLabel:@"Pause" withValue:0];
        SoundIsOn = NO;
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [sender setSelected:YES];
    }
}


- (void)pauseGameAction:(UIButton *)sender
{
    if (successAnimating == YES)
    {
        return;
    }

    [self playButtonSound];

    if (running)
    {
        // Lower the music volume and stop the game
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.03f];
        [self stopGame];
        [pauseButton setSelected:YES];

        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Pause Button" withLabel:nil withValue:0];
    }
    else
    {
        [pauseButton setSelected:NO];
        [self startGame];

        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Resume Button" withLabel:nil withValue:0];
    }
}



- (void)goBackButtonAction:(UIButton *)sender
{
    [self playButtonSound];

    [RCandy startAnimating];
    [UIView transitionFromView:LevelsView toView:HomeView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        if (SoundIsOn)
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games-home.m4a"];
        }
    }];
}

- (void)shareButtonAction:(UIButton *)sender
{
    [[[GAI sharedInstance] defaultTracker] sendView:@"Share View"];
    [self playButtonSound];
    
    if (NSClassFromString(@"SLComposeViewController") == nil && FacebookButton.isHidden == NO)
    {
        [FacebookButton setHidden:YES];
        [ShareTitleLabel setCenter:CGPointMake(ShareTitleLabel.center.x, ShareTitleLabel.center.y + 102)];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [ShareView setCenter:LevelsView.center];
    }];
}
- (void)shareFacebookAction:(UIButton *)sender
{
    [self playButtonSound];
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"Has reached a total score of %d points in Falling Candy.", TotalScore]];
    [controller addImage:[UIImage imageNamed:@"logo.png"]];
    [controller addURL:[NSURL URLWithString:@"http://indriksandteam.com/falling-candy"]];
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)shareTwitterAction:(UIButton *)sender
{
    [self playButtonSound];
    if (NSClassFromString(@"SLComposeViewController") == nil) {
        TWTweetComposeViewController *vc = [[TWTweetComposeViewController alloc] init];
        [vc setInitialText:[NSString stringWithFormat:@"Has reached a total score of %d points in Falling Candy.", TotalScore]];
        [vc addImage:[UIImage imageNamed:@"logo.png"]];
        [vc addURL:[NSURL URLWithString:@"http://indriksandteam.com/falling-candy"]];
        [self presentViewController:vc animated:YES completion:nil];
        [vc release];
    }
    else
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller setInitialText:[NSString stringWithFormat:@"Has reached a total score of %d points in Falling Candy.", TotalScore]];
        [controller addImage:[UIImage imageNamed:@"logo.png"]];
        [controller addURL:[NSURL URLWithString:@"http://indriksandteam.com/falling-candy"]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}
- (void)shareCancelAction:(UIButton *)sender
{
    [self playButtonSound];
    [UIView animateWithDuration:0.2 animations:^{
        [ShareView setCenter:CGPointMake(ShareView.center.x, -ShareView.frame.size.height)];
    }];
}


- (void)unlockAllAction:(UIButton *)sender
{
    [LoaderIndicator startAnimating];
    [LevelsView bringSubviewToFront:LoaderView];
    [UIView animateWithDuration:0.2 animations:^{
        //[LoaderView setCenter:LevelsView.center];
        [LoaderView setAlpha:1.0f];
    }];
    
    [self loadProducts:^(BOOL success) {
        if (success && Products != nil)
        {
            NSLog(@"%@", Products);
            SKPayment *payment = [SKPayment paymentWithProduct:(SKProduct *)[Products objectAtIndex:0]];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                //[LoaderView setCenter:CGPointMake(LoaderView.center.x, -LoaderView.frame.size.height)];
                [LoaderView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [LoaderIndicator stopAnimating];
            }];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                              message:@"Failed to process the payment. Please try again later."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            [message release];
        }
    }];
}


- (void)playLevelAction:(UIButton *)sender
{
    [[[GAI sharedInstance] defaultTracker] sendView:@"Play Level"];
    [self playButtonSound];

    int level = sender.tag - 100 * CurrTheme;
    [self resetPlayground:level];
    [UIView transitionFromView:LevelsView toView:GameView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        if (SoundIsOn)
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"playing-games.m4a"];
        }
        [self startGame];
    }];
}



#pragma mark success

- (void)SuccessNextButtonAction:(UIButton *)sender
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Next Button" withLabel:nil withValue:0];
    [self playButtonSound];

    if (CurrLevel == TotalLevels)
    {
        [self closeThemeDoors:nil];
        [self SuccessMenuButtonAction:nil];

        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [ThemesView setContentOffset:CGPointMake(CurrTheme * ThemesView.frame.size.width, 0) animated:YES];
        });
    }
    else
    {
        CurrLevel += 1;
        [self resetPlayground:CurrLevel];
        [UIView animateWithDuration:0.3 animations:^{
            [SuccessView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self startGame];
        }];
    }
}


- (void)SuccessReplayButtonAction:(UIButton *)sender
{
    if (successAnimating == YES)
    {
        return;
    }

    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Replay Button" withLabel:nil withValue:0];
    [self playButtonSound];

    if (running == YES)
    {
        [self stopGame];
    }

    [self resetPlayground:CurrLevel];
    [UIView animateWithDuration:0.3 animations:^{
        [SuccessView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self startGame];
        [pauseButton setSelected:NO];
    }];
}


- (void)SuccessMenuButtonAction:(UIButton *)sender
{
    if (successAnimating == YES)
    {
        return;
    }

    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Main Events" withAction:@"Menu Button" withLabel:nil withValue:0];
    [self playButtonSound];

    if (running == YES)
    {
        [self stopGame];
    }

    [self showLevels:GameView];

    [SuccessView setAlpha:0.0f];
    [pauseButton setSelected:NO];
}




#pragma mark - The Game


- (void)resetPlayground:(int)level
{
    CurrScore = 0;
    CurrHighScore = 0;
    MaxScore = 0;
    CurrLevel = level;
    ScrollRate = 60 + level * 3;
    CandyFallRate = 100;
    TimeDifference = 1;

    CandyView.Vy = 0.0;
    CandyView.Vx = 0.0;
    CandyView.restitution = 0.5;

    movingX = 0;
    rollingX = 0;

    // Reset highscore label
    [HighScoreLabel setHidden:YES];
    [CurrScoreLabel setFrame:CGRectMake(5.0f, 5.0f, CurrScoreLabel.frame.size.width, CurrScoreLabel.frame.size.height)];
    [HelperSecondsLabel setHidden:YES];

    // Zero some labels
    [self refreshScore];

    // Clear playground
    for (UIImageView *aView in [playground subviews])
    {
        if (aView.tag >= 1000)
        {
            [aView removeFromSuperview];
        }
    }

    // Reset progress indicator
    [ProgressIndicator setCenter:CGPointMake(ProgressIndicator.center.x, ProgressBar.frame.origin.y)];
    [ProgressFill setFrame:CGRectMake(ProgressFill.frame.origin.x, ProgressFill.frame.origin.y, ProgressFill.frame.size.width, 0)];

    // Reset our wormy
    [TheWorm setImage:[UIImage imageNamed:@"green1.png"]];

    // Generate level
    [self generateLevel];

    UIView *white_view = [GameView viewWithTag:-1000];
    [white_view setAlpha:0.9f];
}


- (void)startGame
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    running = YES;

    // Restore music volume
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2f];

    UIView *white_view = [GameView viewWithTag:-1000];
    [UIView animateWithDuration:0.51 animations:^{
        [white_view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        motionManager = [[CMMotionManager alloc] init];
        motionManager.gyroUpdateInterval = 1.0/60.0;
        [motionManager startAccelerometerUpdates];

        if (displayLink != nil)
        {
            [displayLink invalidate], displayLink = nil;
        }

        displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(Render:)] retain];
        [displayLink setFrameInterval:1];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        // Shine animation
        UIImageView *cb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [cb setAnimationImages:candyShineAnimation];
        [cb setAnimationRepeatCount:1];
        [cb setAnimationDuration:0.5];
        [cb startAnimating];
        [CandyView addSubview:cb];
    }];
}



- (void)stopGame
{
    running = NO;
    [motionManager stopAccelerometerUpdates];
    [displayLink invalidate], displayLink = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}



- (void)generateLevel
{
    NSString *theme_index = [NSString stringWithFormat:@"%d", CurrTheme];
    NSDictionary *theme = [levels objectForKey:theme_index];
    if (theme == nil)
    {
        [self generateLevelRandom];
        return;
    }

    NSString *level_index = [NSString stringWithFormat:@"%d", CurrLevel];
    NSDictionary *level = [theme objectForKey:level_index];
    if (level == nil)
    {
        [self generateLevelRandom];
        return;
    }


    // Highscore
    NSDictionary *level_done = [FinishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", CurrTheme, CurrLevel]];
    if (level_done)
    {
        CurrHighScore = [[level_done objectForKey:@"score"] intValue];
    }
    if (CurrHighScore > 0)
    {
        [HighScoreLabel setText:[NSString stringWithFormat:@"HIGHSCORE\n%d", CurrHighScore]];
        [HighScoreLabel setFrame:CGRectMake(5.0f, 5.0f, HighScoreLabel.frame.size.width, HighScoreLabel.frame.size.height)];
        [HighScoreLabel setHidden:NO];
        [CurrScoreLabel setFrame:CGRectMake(5.0f, HighScoreLabel.frame.origin.y + HighScoreLabel.frame.size.height, CurrScoreLabel.frame.size.width, CurrScoreLabel.frame.size.height)];
    }
    
    // Playground
    NSString *filename = [NSString stringWithFormat:@"game-bg-%d-%d", CurrTheme, CurrLevel];
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"png"];
    if (path != nil)
    {
        [GameView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"game-bg-%d-%d.png", CurrTheme, CurrLevel]]]];
    }
    else
    {
        [GameView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"game-bg-%d.png", CurrTheme]]]];
    }
    [playground setBackgroundColor:[UIColor clearColor]];

    // Speed
    ScrollRate = [[level objectForKey:@"Speed"] integerValue];

    // Init point
    [CandyView setFrame:CGRectFromString([level objectForKey:@"InitRect"])];
    [CandyView setAlpha:1.0f];
    [CandyView setHidden:NO];

    // End point
    CGRect frame = CGRectFromString([level objectForKey:@"EndRect"]);
    [WormWrapperView setFrame:frame];
    [Ground setCenter:CGPointMake(playground.center.x, frame.origin.y + frame.size.height - 10)];
    CurrTrackLength = Ground.frame.origin.y + Ground.frame.size.height;

    NSArray *objects = [level objectForKey:@"Objects"];
    for (NSDictionary *the_object in objects)
    {
        int tag = [[the_object objectForKey:@"Tag"] integerValue];
        CGRect rect = CGRectFromString([the_object objectForKey:@"Rect"]);

        switch (tag) {
            case TAG_BRICK_1:
            {
                // Bricks
                UIImage *brick_image = [UIImage imageNamed:@"brick-1.png"];
                PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
                [brick setFrame:rect];
                [brick setTag:tag];
                [brick setScore:10];
                [brick setTestFrame:CGRectMake(5, 2, 75, 29)];
                [playground addSubview:brick];
                [brick release];

                // Add to max possible score
                MaxScore += brick.score;
            }
                break;


            case TAG_BRICK_2:
            {
                // Bricks
                UIImage *brick_image = [UIImage imageNamed:@"brick-2.png"];
                PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
                [brick setFrame:rect];
                [brick setTag:tag];
                [brick setScore:10];
                [brick setTestFrame:CGRectMake(10, 5, 70, 28)];
                [playground addSubview:brick];
                [brick release];
                
                // Add to max possible score
                MaxScore += brick.score;
            }
                break;


            case TAG_BRICK_3:
            {
                // Bricks
                UIImage *brick_image = [UIImage imageNamed:@"brick-3.png"];
                PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
                [brick setFrame:rect];
                [brick setTag:tag];
                [brick setScore:10];
                [brick setTestFrame:CGRectMake(10, 0, 66, 23)];
                [playground addSubview:brick];
                [brick release];

                // Add to max possible score
                MaxScore += brick.score;
            }
                break;

                
            case TAG_RED_BRICK:
            {
                PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] init];
                [brick setFrame:rect];
                [brick setTag:tag];
                [brick setStickiness:1.3];
                [brick setScore:10];
                [brick setTestFrame:CGRectMake(5, 1, 75, 32)];

                UIImage *brick_image = [UIImage imageNamed:@"red-brick1"];
                UIImageView *brick_part1 = [[UIImageView alloc] initWithImage:brick_image];
                [brick_part1 setTag:1];
                [brick addSubview:brick_part1];
                [brick_part1 release];

                brick_image = [UIImage imageNamed:@"red-brick2"];
                UIImageView *brick_part2 = [[UIImageView alloc] initWithImage:brick_image];
                [brick_part2 setTag:2];
                CGRect frame = brick_part2.frame;
                frame.origin.x += brick_part1.frame.size.width - 5;
                [brick_part2 setFrame:frame];
                [brick addSubview:brick_part2];
                [brick_part2 release];

                [playground addSubview:brick];
                [brick release];
                
                // Add to max possible score
                MaxScore += brick.score;
            }
                break;

                

            case TAG_BRICK_MOVING_LEFT:
            case TAG_BRICK_MOVING_RIGHT:
            case TAG_BRICK_MOVING_UP:
            case TAG_BRICK_MOVING_DOWN:
            {
                // Bricks
                UIImage *brick_image = [UIImage imageNamed:@"brick-1.png"];
                PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
                [brick setFrame:rect];
                [brick setTestFrame:CGRectMake(5, 2, 75, 29)];
                [brick setTag:tag];
                [brick setScore:20];

                
                if (tag == TAG_BRICK_MOVING_LEFT)
                {
                    [brick setMoveX:-100];
                    [brick setMovingXV:-70];
                }
                else if (tag == TAG_BRICK_MOVING_RIGHT)
                {
                    [brick setMoveX:100];
                    [brick setMovingXV:70];
                }
                else if (tag == TAG_BRICK_MOVING_UP)
                {
                    [brick setMoveY:-150];
                    [brick setMovingYV:-70];
                }
                else if (tag == TAG_BRICK_MOVING_DOWN)
                {
                    [brick setMoveY:150];
                    [brick setMovingYV:70];
                }
                
                [playground addSubview:brick];
                [brick release];

                // Add to max possible score
                MaxScore += brick.score;
            }
                break;
                
                
                
            case TAG_CAVE:
            {
                // Cache animations
                if (CachedMonsterAnimation == nil)
                {
                    CachedMonsterAnimation = [[NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"monster-1.png"],
                                               [UIImage imageNamed:@"monster-2.png"],
                                               [UIImage imageNamed:@"monster-3.png"],
                                               [UIImage imageNamed:@"monster-4.png"],
                                               [UIImage imageNamed:@"monster-3.png"],
                                               [UIImage imageNamed:@"monster-2.png"],
                                               [UIImage imageNamed:@"monster-1.png"],nil] retain];
                }

                PhysicsUIImageView *caveView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
                [caveView setImage:[UIImage imageNamed:@"cave.png"]];
                
                [caveView setFrame:rect];
                [caveView setContentMode:UIViewContentModeBottom];
                [caveView setTag:tag];
                
                PhysicsUIImageView *monsterView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 14)];
                [monsterView setCenter:CGPointMake(caveView.frame.size.width / 2 + 3, caveView.frame.size.height / 2 + 7)];
                [monsterView setContentMode:UIViewContentModeCenter];
                [monsterView setAnimationImages:[NSArray arrayWithArray:CachedMonsterAnimation]];
                [monsterView setAnimationDuration:0.7f];
                [monsterView setAnimationRepeatCount:INFINITY];
                [monsterView startAnimating];
                
                [caveView addSubview:monsterView];
                
                [playground addSubview:caveView];
                [playground sendSubviewToBack:caveView];
                
                [monsterView release];
                [caveView release];
            }
                break;


            case TAG_BOX:
            {
                if (CachedPuffAnimation == nil)
                {
                    CachedPuffAnimation = [[NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"puf1.png"],
                                            [UIImage imageNamed:@"puf2.png"],
                                            [UIImage imageNamed:@"puf3.png"],
                                            [UIImage imageNamed:@"puf4.png"],nil] retain];
                }

                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-box.png"]];
                [sawView setFrame:rect];
                [sawView setTestFrame:CGRectMake(4, 6, 33, 31)];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setTag:tag];
                [sawView setScore:200];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];
                
                // Add to max possible score
                MaxScore += sawView.score;
                
                if (HelperTest == nil)
                {
                    HelperTest = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-helper.png"]];
                    [HelperTest setTestFrame:CGRectMake(8, 6, 302, 12)];
                    [HelperTest setTag:TAG_HELPER];
                }
            }
                break;


            case TAG_SANDCLOCK:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"sandclock.png"]];
                [sawView setFrame:rect];
                [sawView setTestFrame:CGRectMake(4, 6, 33, 31)];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setTag:tag];
                [sawView setScore:220];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];

                // Add to max possible score
                MaxScore += sawView.score;
            }
                break;

                
            case TAG_COIN:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 21)];
                [sawView setFrame:rect];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setAnimationImages:[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"coin1.png"],
                                             [UIImage imageNamed:@"coin2.png"],
                                             [UIImage imageNamed:@"coin3.png"],
                                             [UIImage imageNamed:@"coin4.png"],
                                             [UIImage imageNamed:@"coin5.png"],
                                             [UIImage imageNamed:@"coin6.png"],nil]];
                [sawView setAnimationDuration:0.60f];
                [sawView setAnimationRepeatCount:INFINITY];
                [sawView startAnimating];
                [sawView setTag:tag];
                [sawView setScore:100];
                [sawView setMoveY:5];
                [sawView setMovingYV:20];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];

                // Add to max possible score
                MaxScore += sawView.score;
            }
                break;
                

            case TAG_HELPER:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-helper.png"]];
                [sawView setFrame:rect];
                [sawView setTestFrame:CGRectMake(8, 6, 302, 12)];
                [sawView setTag:tag];
                [sawView setScore:20];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];

                // Add to max possible score
                MaxScore += sawView.score;
            }
                break;

                
            case TAG_SPRING:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-spring.png"]];
                [sawView setContentMode:UIViewContentModeScaleToFill];
                [sawView setFrame:rect];
                [sawView setOriginalSize:sawView.frame.size];
                [sawView setTestFrame:CGRectMake(1, 3, sawView.frame.size.width - 8, sawView.frame.size.height - 5)];
                [sawView setTag:tag];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];
            }
                break;


            case TAG_FIRE:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 21)];
                [sawView setFrame:rect];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setAnimationImages:[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"fire-1.png"],
                                             [UIImage imageNamed:@"fire-2.png"],
                                             [UIImage imageNamed:@"fire-3.png"],
                                             [UIImage imageNamed:@"fire-4.png"],
                                             [UIImage imageNamed:@"fire-5.png"],nil]];
                [sawView setAnimationDuration:0.50f];
                [sawView setAnimationRepeatCount:INFINITY];
                [sawView startAnimating];
                [sawView setTag:tag];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];
            }
                break;

                
            case TAG_SAW:
            {
                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] init];
                //PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"saw-1.png"]];
                [sawView setFrame:rect];
                [sawView setTestFrame:CGRectMake(8, 9, 29, 34)];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setAnimationImages:[NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"saw-1.png"],
                                             [UIImage imageNamed:@"saw-2.png"],
                                             [UIImage imageNamed:@"saw-3.png"],
                                             [UIImage imageNamed:@"saw-4.png"],nil]];
                [sawView setAnimationDuration:0.30f];
                [sawView setAnimationRepeatCount:INFINITY];
                [sawView startAnimating];
                [sawView setTag:tag];

                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];
            }
                break;


            case TAG_WATERMELON:
            case TAG_BANANA:
            case TAG_STRAWBERRY:
            case TAG_CHEST:
            case TAG_COIN_PILE:
            {
                if (CachedPuffAnimation == nil)
                {
                    CachedPuffAnimation = [[NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"puf1.png"],
                                            [UIImage imageNamed:@"puf2.png"],
                                            [UIImage imageNamed:@"puf3.png"],
                                            [UIImage imageNamed:@"puf4.png"],nil] retain];
                }
                
                UIImage *image;
                int score;
                if (tag == TAG_WATERMELON)
                {
                    image = [UIImage imageNamed:@"arbuzs.png"];
                    score = 300;
                }
                else if (tag == TAG_BANANA)
                {
                    image = [UIImage imageNamed:@"bananas.png"];
                    score = 400;
                }
                else if (tag == TAG_STRAWBERRY)
                {
                    image = [UIImage imageNamed:@"strawberry.png"];
                    score = 500;
                }
                else if (tag == TAG_CHEST)
                {
                    image = [UIImage imageNamed:@"chest.png"];
                    score = 500;
                }
                else
                {
                    image = [UIImage imageNamed:@"treasure.png"];
                    score = 300;
                }

                PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:image];
                [sawView setFrame:rect];
                [sawView setContentMode:UIViewContentModeBottom];
                [sawView setTag:tag];
                [sawView setScore:score];
                [playground addSubview:sawView];
                [playground sendSubviewToBack:sawView];
                [sawView release];

                // Add to max possible score
                MaxScore += sawView.score;
            }
                break;
                
            default:
                break;
        }
    } // End of object for loop
}



- (void)generateLevelRandom
{
    // Update Content size
    int screens = CurrLevel;
    if (screens == 1)
    {
        screens = 1;
    }

    // Highscore
    NSDictionary *level_done = [FinishedLevels objectForKey:[NSString stringWithFormat:@"%d:%d", CurrTheme, CurrLevel]];
    if (level_done)
    {
        CurrHighScore = [[level_done objectForKey:@"score"] intValue];
    }
    if (CurrHighScore > 0)
    {
        [HighScoreLabel setText:[NSString stringWithFormat:@"HIGHSCORE\n%d", CurrHighScore]];
        [HighScoreLabel setFrame:CGRectMake(5.0f, 5.0f, HighScoreLabel.frame.size.width, HighScoreLabel.frame.size.height)];
        [HighScoreLabel setHidden:NO];
        [CurrScoreLabel setFrame:CGRectMake(5.0f, HighScoreLabel.frame.origin.y + HighScoreLabel.frame.size.height, CurrScoreLabel.frame.size.width, CurrScoreLabel.frame.size.height)];
    }

    // Playground
    // TODO:
    if (CurrLevel == 20)
    {
        [playground setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"game-bg-%d-%d.png", CurrTheme, CurrLevel]]]];
    }
    else
    {
        [playground setBackgroundColor:[UIColor clearColor]];
        [GameView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"game-bg-%d.png", CurrTheme]]]];
    }

    // Finish point
    [WormWrapperView setCenter:CGPointMake(playground.center.x, playground.frame.size.height * screens)];
    [Ground setCenter:CGPointMake(playground.center.x, WormWrapperView.frame.origin.y + WormWrapperView.frame.size.height - 10)];
    CurrTrackLength = Ground.frame.origin.y + Ground.frame.size.height;

    
    // Bricks
    UIImage *brick_image = [UIImage imageNamed:[NSString stringWithFormat:@"brick-%d.png", CurrTheme]];
    CGRect brick_rect;

    if (CurrTheme == 1)
    {
        brick_rect = CGRectMake(5, 1, 75, 32);
    }
    else if (CurrTheme == 2)
    {
        brick_rect = CGRectMake(10, 5, 70, 28);
    }
    else
    {
        brick_rect = CGRectMake(10, 0, 66, 23);
    }
    
    //CGRecto
    nextYPos = 200;
    
    PhysicsUIImageView *brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
    [brick setCenter:CGPointMake(playground.center.x, nextYPos)];
    [brick setTag:TAG_BRICK_1 - 1 + CurrTheme];
    [brick setScore:10];
    [brick setTestFrame:brick_rect];
    [playground addSubview:brick];
    lastBrick = brick;
    [brick release];

    [CandyView setAlpha:1.0f];
    [CandyView setHidden:NO];
    [CandyView setCenter:CGPointMake(brick.center.x, nextYPos - brick.testFrame.size.height / 2 - CandyView.frame.size.height / 2)];

    // Add to max possible score
    MaxScore += brick.score;

    int min_distance = 80;
    int max_distance = 160;
    int brick_count = ceil(CurrTrackLength / min_distance);
    int monster_count = 0;
    
    nextYPos += (arc4random() % (max_distance - min_distance + 1)) + min_distance;
    for (int i = 1; i <= brick_count; ++i)
    {
        // Add brick
        brick = [[PhysicsUIImageView alloc] initWithImage:brick_image];
        [brick setCenter:CGPointMake((arc4random() % (int)(playground.frame.size.width - (brick.frame.size.width / 3))), nextYPos)];
        [brick setTag:TAG_BRICK_1 - 1 + CurrTheme];
        [brick setScore:10];
        [brick setTestFrame:brick_rect];
        [playground addSubview:brick];
        [brick release];

        // Add to max possible score
        MaxScore += brick.score;
        
        // Calculate next brick position
        nextYPos += (arc4random() % (max_distance - min_distance)) + min_distance;
        
        // Add stars and stuff
        int random = arc4random() % 100;
        if (CurrLevel >= 13 && monster_count < 3 && random > 70 && random < 80)
        {
            // Cache animations
            if (CachedMonsterAnimation == nil)
            {
                CachedMonsterAnimation = [[NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"monster-1.png"],
                                           [UIImage imageNamed:@"monster-2.png"],
                                           [UIImage imageNamed:@"monster-3.png"],
                                           [UIImage imageNamed:@"monster-4.png"],
                                           [UIImage imageNamed:@"monster-3.png"],
                                           [UIImage imageNamed:@"monster-2.png"],
                                           [UIImage imageNamed:@"monster-1.png"],nil] retain];
            }

            monster_count += 1;
            PhysicsUIImageView *caveView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
            [caveView setImage:[UIImage imageNamed:@"cave.png"]];

            int difference = (((brick.frame.size.width - 10) - caveView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));

            [caveView setCenter:CGPointMake(x, brick.center.y - brick.frame.size.height / 2 - caveView.frame.size.height / 2 + brick_rect.origin.y)];
            [caveView setContentMode:UIViewContentModeBottom];
            [caveView setTag:TAG_CAVE];

            PhysicsUIImageView *monsterView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 14)];
            [monsterView setCenter:CGPointMake(caveView.frame.size.width / 2 + 3, caveView.frame.size.height / 2 + 7)];
            [monsterView setContentMode:UIViewContentModeCenter];
            [monsterView setAnimationImages:[NSArray arrayWithArray:CachedMonsterAnimation]];
            [monsterView setAnimationDuration:0.7f];
            [monsterView setAnimationRepeatCount:INFINITY];
            [monsterView startAnimating];

            [caveView addSubview:monsterView];

            [playground addSubview:caveView];
            [playground sendSubviewToBack:caveView];

            [monsterView release];
            [caveView release];
        }
        else if (CurrTheme >= 2 && random > 90 && random < 100)
        {
            if (CachedPuffAnimation == nil)
            {
                CachedPuffAnimation = [[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"puf1.png"],
                                        [UIImage imageNamed:@"puf2.png"],
                                        [UIImage imageNamed:@"puf3.png"],
                                        [UIImage imageNamed:@"puf4.png"],nil] retain];
            }
            
            PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-box.png"]];
            int difference = ((brick.frame.size.width - sawView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));

            [sawView setCenter:CGPointMake(x, brick.center.y - brick.frame.size.height / 2 - sawView.frame.size.height / 2 + brick_rect.origin.y + 12)];
            [sawView setTestFrame:CGRectMake(4, 6, 33, 31)];
            [sawView setContentMode:UIViewContentModeBottom];
            [sawView setTag:TAG_BOX];
            [sawView setScore:100];
            [playground addSubview:sawView];
            [playground sendSubviewToBack:sawView];
            [sawView release];
            
            // Add to max possible score
            MaxScore += sawView.score;

            if (HelperTest == nil)
            {
                HelperTest = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-helper.png"]];
                [HelperTest setTestFrame:CGRectMake(8, 6, 302, 12)];
                [HelperTest setTag:TAG_HELPER];
            }
        }
        else if (CurrTheme >= 2 && random > 80 && random < 90)
        {
            PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:[UIImage imageNamed:@"thm1-spring.png"]];
            [sawView setContentMode:UIViewContentModeScaleToFill];

            int difference = (((brick.frame.size.width - 10) - sawView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));
            float y = brick.center.y - brick.testFrame.size.height / 2 - sawView.frame.size.height / 2 + brick_rect.origin.y;

            [sawView setCenter:CGPointMake(x, y)];
            [sawView setOriginalSize:sawView.frame.size];
            [sawView setTestFrame:CGRectMake(1, 3, sawView.frame.size.width - 8, sawView.frame.size.height - 5)];
            [sawView setTag:TAG_SPRING];
            [playground addSubview:sawView];
            [playground sendSubviewToBack:sawView];
            [sawView release];
        }
        else if (CurrLevel >= 9 && random > 10 && random < 20)
        {
            PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 21)];

            int difference = (((brick.frame.size.width - 10) - sawView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));

            [sawView setCenter:CGPointMake(x, brick.center.y - brick.frame.size.height / 2 - sawView.frame.size.height / 2 + brick_rect.origin.y)];
            [sawView setContentMode:UIViewContentModeBottom];
            [sawView setAnimationImages:[NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"fire-1.png"],
                                         [UIImage imageNamed:@"fire-2.png"],
                                         [UIImage imageNamed:@"fire-3.png"],
                                         [UIImage imageNamed:@"fire-4.png"],
                                         [UIImage imageNamed:@"fire-5.png"],nil]];
            [sawView setAnimationDuration:0.50f];
            [sawView setAnimationRepeatCount:INFINITY];
            [sawView startAnimating];
            [sawView setTag:TAG_FIRE];
            [playground addSubview:sawView];
            [playground sendSubviewToBack:sawView];
            [sawView release];
        }
        else if (CurrLevel >= 5 && random < 10)
        {
            PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithFrame:CGRectMake(0, 0, 53, 54)];
            [sawView setTestFrame:CGRectMake(8, 9, 29, 34)];

            int difference = (((brick.frame.size.width - 10) - sawView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));
            float y = brick.center.y - brick.frame.size.height / 2 - sawView.frame.size.height / 2 + brick_rect.origin.y + 6;
            
            [sawView setCenter:CGPointMake(x, y)];
            [sawView setContentMode:UIViewContentModeBottom];
            [sawView setAnimationImages:[NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"saw-1.png"],
                                         [UIImage imageNamed:@"saw-2.png"],
                                         [UIImage imageNamed:@"saw-3.png"],
                                         [UIImage imageNamed:@"saw-4.png"],nil]];
            [sawView setAnimationDuration:0.30f];
            [sawView setAnimationRepeatCount:INFINITY];
            [sawView startAnimating];
            [sawView setTag:TAG_SAW];
            [playground addSubview:sawView];
            [playground sendSubviewToBack:sawView];
            [sawView release];
        }
        else if (CurrTheme == 1 && CurrLevel >= 5 && random > 60 && random < 70)
        {
            [brick setImage:[UIImage imageNamed:@"red-brick.png"]];
            [brick setTag:TAG_RED_BRICK];
        }
        else if (CurrLevel >= 2 && random > 20 && random < 60)
        {
            if (CachedPuffAnimation == nil)
            {
                CachedPuffAnimation = [[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"puf1.png"],
                                        [UIImage imageNamed:@"puf2.png"],
                                        [UIImage imageNamed:@"puf3.png"],
                                        [UIImage imageNamed:@"puf4.png"],nil] retain];
            }

            UIImage *image;
            int tag;
            int rand = (arc4random() % 3) + 1;
            int score;
            if (rand == 1)
            {
                image = [UIImage imageNamed:@"arbuzs.png"];
                tag = TAG_WATERMELON;
                score = 300;
            }
            else if (rand == 2)
            {
                image = [UIImage imageNamed:@"bananas.png"];
                tag = TAG_BANANA;
                score = 200;
            }
            else
            {
                image = [UIImage imageNamed:@"strawberry.png"];
                tag = TAG_STRAWBERRY;
                score = 500;
            }

            PhysicsUIImageView *sawView = [[PhysicsUIImageView alloc] initWithImage:image];
            int difference = ((brick.frame.size.width - sawView.frame.size.width) / 2);
            float x = (brick.center.x - difference) + (arc4random() % (difference * 2));

            [sawView setCenter:CGPointMake(x, brick.center.y - brick.frame.size.height / 2 - sawView.frame.size.height / 2 + brick_rect.origin.y)];
            [sawView setContentMode:UIViewContentModeBottom];
            [sawView setTag:tag];
            [sawView setScore:score];
            [playground addSubview:sawView];
            [playground sendSubviewToBack:sawView];
            [sawView release];

            // Add to max possible score
            MaxScore += sawView.score;
        }

        // Stop if we go over the ground
        if (nextYPos + min_distance >= WormWrapperView.frame.origin.y)
        {
            break;
        }
    }

    
    [playground bringSubviewToFront:CandyView];
}


- (BOOL)circle:(CGRect)circle intersectsRect:(CGRect)rect
{
    CGPoint circleDistance = CGPointMake(fabs(CGRectGetMidX(circle) - CGRectGetMidX(rect)), fabs(CGRectGetMidY(circle) - CGRectGetMidY(rect)));
    int radius = (int)circle.size.height / 2;

    if (circleDistance.x > (rect.size.width/2 + radius)) { return false; }
    if (circleDistance.y > (rect.size.height/2 + radius)) { return false; }

    if (circleDistance.x <= (rect.size.width/2)) { return true; }
    if (circleDistance.y <= (rect.size.height/2)) { return true; }

    int cornerDistance_sq = (int)pow((circleDistance.x - rect.size.width/2), 2) + pow((circleDistance.y - rect.size.height/2), 2);

    return (cornerDistance_sq <= (int)pow(radius, 2));
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    PhysicsUIImageView *aView = (PhysicsUIImageView *)[anim valueForUndefinedKey:@"RemoveObject"];
    if (aView != nil)
    {
        [aView removeFromSuperview];
    }
}




// ---------------------------------------------------------------------------------------------------



- (void)Render:(CADisplayLink *)sender
{
    // Get accelerometer data
    CMAccelerometerData *newestAcc = motionManager.accelerometerData;

    // Setup some position variables
    CFTimeInterval duration = sender.duration * TimeDifference;
    CGRect CandyFrame = CandyView.frame;

    // Scroll playground
    float playground_position = ScrollRate * duration;
    if (Ground.frame.origin.y + Ground.frame.size.height <= playground.frame.size.height)
    {
        playground_position = (Ground.frame.origin.y + Ground.frame.size.height) - playground.frame.size.height;
    }

    // Move Y
    float gy = 20 * duration;
    CandyView.Vy += gy;
    CandyFrame.origin.y += CandyView.Vy - playground_position;

    // Move X
    movingX = (newestAcc.acceleration.x * 0.1) + (movingX * (1.0 - 0.1));
    float distance = (300 * movingX * duration);
    CandyFrame.origin.x += CandyView.Vx;
    CandyView.Vx = distance;


    // Find collisions
    float distance_from_worm = sqrt(pow((WormWrapperView.center.x - CandyView.center.x), 2.0) + pow((WormWrapperView.center.y - CandyView.center.y), 2.0));
    if (distance_from_worm < 50)
    {
        [TheWorm setImage:[UIImage imageNamed:@"green5.png"]];
    }
    else if (distance_from_worm < 100)
    {
        [TheWorm setImage:[UIImage imageNamed:@"green4.png"]];
    }
    else if (distance_from_worm < 150)
    {
        [TheWorm setImage:[UIImage imageNamed:@"green3.png"]];
    }
    else if (distance_from_worm < 200)
    {
        [TheWorm setImage:[UIImage imageNamed:@"green2.png"]];
    }
    else
    {
        [TheWorm setImage:[UIImage imageNamed:@"green1.png"]];
    }
    
    // Touching the box
    if (CGRectContainsRect(WormWrapperView.frame, CandyFrame))
    {
        [TheWorm setImage:[UIImage imageNamed:@"green6.png"]];
        [CandyView setHidden:YES];
        [self stopGame];
        
        [self showSuccessViewWithFailed:NO];
        return;
    }

    // Update positions
    for (PhysicsUIImageView *aView in [playground subviews])
    {
        [aView setCenter:CGPointMake(aView.center.x, aView.center.y - playground_position)];

        // Move them around
        if ([[aView class] isSubclassOfClass:[PhysicsUIImageView class]])
        {
            CGRect frame = aView.frame;
            // X
            frame.origin.x += aView.movingXV * duration;
            aView.movingX += aView.movingXV * duration;
            if (fabs(aView.movingX) >= fabs(aView.moveX) || ((aView.movingX > 0) != (aView.moveX > 0)))
            {
                aView.movingXV = -aView.movingXV;
            }
            // Y
            frame.origin.y += aView.movingYV * duration;
            aView.movingY += aView.movingYV * duration;
            if (fabs(aView.movingY) >= fabs(aView.moveY) || ((aView.movingY > 0) != (aView.moveY > 0)))
            {
                aView.movingYV = -aView.movingYV;
            }
            // Set frame only if anything has changed
            if (CGRectEqualToRect(frame, aView.frame) == NO)
            {
                [aView setFrame:frame];
            }
        }
    }


    // Test for collisions
    BOOL hitIt = NO, firstHit = NO;
    int score = 0;
    for (PhysicsUIImageView *aView in [playground subviews])
    {
        // Stop collision detection if current object is not collidable with
        if (aView.tag < TAG_BRICK_1 || aView.isAnimatingCustom)
        {
            continue;
        }

        // Saw
        if (aView.tag == TAG_SAW)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"saw.m4a" pitch:1.0f pan:0.0f gain:1.0];
                [self showSuccessViewWithFailed:YES];
                break;
            }

            //aView.rotation += 200 * duration;
            //CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * aView.rotation / 180.0);
            //[aView setTransform:transform];
        }
        
        // Fire
        if (aView.tag == TAG_FIRE && CGRectIntersectsRect(CandyFrame, aView.frame))
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"fire.m4a" pitch:1.0f pan:0.0f gain:1.0];
            [self showSuccessViewWithFailed:YES];
            break;
        }

        // Monster in a cave
        if (aView.tag == TAG_CAVE)
        {
            CGRect intersection = CGRectIntersection(aView.frame, CandyFrame);
            if (intersection.size.height + intersection.size.width > (CandyFrame.size.height / 1.2) + (CandyFrame.size.width / 1.2))
            {
                [self stopGame];
                [[SimpleAudioEngine sharedEngine] playEffect:@"laugh.m4a" pitch:1.0f pan:0.0f gain:1.0];
                [UIView animateWithDuration:0.2 animations:^{
                    [CandyView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self showSuccessViewWithFailed:YES];
                }];
                break;
            }
        }

        // Touching the fruits
        if (aView.tag == TAG_WATERMELON || aView.tag == TAG_BANANA || aView.tag == TAG_STRAWBERRY || aView.tag == TAG_CHEST || aView.tag == TAG_COIN_PILE)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.frame))
            {
                CurrScore += aView.score;
                [self refreshScore];
                [self playPuffSound];

                [aView setFrame:CGRectMake(aView.frame.origin.x - 20, aView.frame.origin.y - (78 - aView.frame.size.height), 74, 78)];
                [aView setAnimationImages:CachedPuffAnimation];
                [aView setAnimationDuration:0.40f];
                [aView startAnimating];

                [FruitScoreLabel setText:[NSString stringWithFormat:@"%d", aView.score]];
                [FruitScoreLabel sizeToFit];
                [FruitScoreLabel setCenter:aView.center];
                [FruitScoreLabel setHidden:NO];
                [playground insertSubview:FruitScoreLabel belowSubview:CandyView];

                [aView setAnimatingCustom:YES];
                [UIView animateWithDuration:0.7 animations:^{
                    [FruitScoreLabel setCenter:CGPointMake(FruitScoreLabel.center.x, FruitScoreLabel.center.y - 40)];
                    [aView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [aView removeFromSuperview];
                    
                    [FruitScoreLabel setHidden:YES];
                    [FruitScoreLabel setAlpha:1.0f];
                }];
            }
            continue;
        }

        if (aView.tag == TAG_COIN)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.frame))
            {
                CurrScore += aView.score;
                [self refreshScore];
                [[SimpleAudioEngine sharedEngine] playEffect:@"cashregister.m4a" pitch:1.0f pan:0.0f gain:1.0];

                // -------------------------------------------------------------------------------------------

                [aView setAnimatingCustom:YES];
                
                UIBezierPath *trackPath = [UIBezierPath bezierPath];
                [trackPath moveToPoint:P(aView.center.x, aView.center.y)];
                [trackPath addLineToPoint:P(aView.center.x, aView.center.y + 20)];
                [trackPath addLineToPoint:P(aView.center.x, aView.center.y - 100)];

                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [anim setFillMode:kCAFillModeForwards];
                [anim setRemovedOnCompletion:YES];
                [anim setPath:trackPath.CGPath];
                [anim setDuration:0.4];
                [aView.layer addAnimation:anim forKey:@"race"];
                [aView.layer setPosition:P(aView.center.x, aView.center.y - 100)];

                // -----------------------------------------------------------------------------------------------

                [UIView animateWithDuration:0.8 animations:^{
                    [aView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [aView removeFromSuperview];
                }];
            }
            continue;
        }

        // Spring
        if (aView.tag == TAG_SPRING)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                // Find the mid points of the entity and player
                float pMidX = CGRectGetMidX(CandyFrame);
                float pMidY = CGRectGetMidY(CandyFrame);
                float aMidX = CGRectGetMidX(aView.testFrame);
                float aMidY = CGRectGetMidY(aView.testFrame);
                
                // To find the side of entry calculate based on
                // the normalized sides
                float dx = (aMidX - pMidX) / (aView.testFrame.size.width / 2);
                float dy = (aMidY - pMidY) / (aView.testFrame.size.height / 2);

                // Calculate the absolute change in x and y
                float absDX = fabs(dx);
                float absDY = fabs(dy);

                if (absDX > absDY && aView.frame.size.height >= aView.originalSize.height){
                    if (dx >= 0) // Left
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x - CandyFrame.size.width;
                        CandyView.Vx = 0;
                    }
                    else // Right
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x + aView.testFrame.size.width;
                        CandyView.Vx = 0;
                    }
                }
                else if (CandyView.Vy > 0)
                {
                    if (dy >= 0) // Top
                    {
                        CGRect frame = aView.frame;
                        frame.size.height = MAX(10, frame.size.height - CandyView.Vy);
                        float diff = aView.frame.size.height - frame.size.height;
                        frame.origin.y += diff;
                        [aView setFrame:frame];

                        if (frame.size.height <= 10)
                        {
                            CandyFrame.origin.y = aView.testFrame.origin.y - CandyFrame.size.height;
                            CandyView.Vy = (-CandyView.Vy * 1);
                            [[SimpleAudioEngine sharedEngine] playEffect:@"spring.m4a" pitch:1.0f pan:0.0f gain:1.0];
                        }
                    }
                }
            }
            else if (aView.frame.size.height < aView.originalSize.height)
            {
                float diff = aView.originalSize.height - aView.frame.size.height;
                CGRect frame;
                frame.origin = CGPointMake(aView.frame.origin.x, aView.frame.origin.y - diff);
                frame.size = aView.originalSize;
                [aView setFrame:frame];
            }
            continue;
        }

        // Touching the boxes
        if (aView.tag == TAG_BOX)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                CurrScore += aView.score;
                [self refreshScore];
                [self playPuffSound];
                
                [aView setFrame:CGRectMake(aView.frame.origin.x - 20, aView.frame.origin.y - (78 - aView.testFrame.size.height), 74, 78)];
                [aView setAnimationImages:CachedPuffAnimation];
                [aView setAnimationDuration:0.40f];
                [aView startAnimating];

                // -------------------------------------------------------------------------------------------

                float x1 = aView.center.x, y1 = aView.center.y;
                float x2 = playground.center.x + 2,
                        y2 = playground.frame.size.height - 30;

                [HelperTest setAnimatingCustom:YES];
                [playground addSubview:HelperTest];
                [playground bringSubviewToFront:HelperSecondsLabel];
                [HelperSecondsLabel setHidden:YES];

                UIBezierPath *trackPath = [UIBezierPath bezierPath];
                [trackPath moveToPoint:P(x1, y1)];
                [trackPath addCurveToPoint:P(x2, y2) controlPoint1:P(x1 + 20, y1 - 120) controlPoint2:P(x2 + 40, y1 - 110)];

                CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                [anim setFillMode:kCAFillModeForwards];
                [anim setRemovedOnCompletion:YES];
                [anim setDelegate:self];
                [anim setPath:trackPath.CGPath];
                [anim setRepeatCount:1];
                [anim setDuration:0.7];
                [anim setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
                [HelperTest.layer addAnimation:anim forKey:@"race"];
                [HelperTest.layer setPosition:CGPointMake(x2, y2)];

                CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
                [transformAnimation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
                [transformAnimation setDuration:0.7];
                [transformAnimation setRepeatCount:1];
                [transformAnimation setRemovedOnCompletion:NO];
                [transformAnimation setFillMode:kCAFillModeForwards];
                [transformAnimation setFromValue:[NSValue valueWithCGSize:CGSizeMake(50, 4)]];
                [HelperTest.layer addAnimation:transformAnimation forKey:@"transform"];

                // -----------------------------------------------------------------------------------------------

                [aView setAnimatingCustom:YES];
                [UIView animateWithDuration:0.7 animations:^{
                    [aView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [aView removeFromSuperview];
                }];
            }
            continue;
        }

        // First helper
        if (aView.tag == TAG_HELPER)
        {
            // Update helper seconds
            /*HelperSecondsCounter += duration;
            if (HelperSecondsCounter >= 1)
            {
                HelperSeconds -= 1;
                HelperSecondsCounter = 0;
            }
            if (HelperSeconds == 0)
            {
                [HelperTest removeFromSuperview];
                [HelperSecondsLabel setHidden:YES];
            }
            else
            {
                [HelperSecondsLabel setText:[NSString stringWithFormat:@"%d", HelperSeconds]];
            }*/

            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                // Find the mid points of the entity and player
                float pMidX = CGRectGetMidX(CandyFrame);
                float pMidY = CGRectGetMidY(CandyFrame);
                float aMidX = CGRectGetMidX(aView.testFrame);
                float aMidY = CGRectGetMidY(aView.testFrame);
                
                // To find the side of entry calculate based on
                // the normalized sides
                float dx = (aMidX - pMidX) / (aView.testFrame.size.width / 2);
                float dy = (aMidY - pMidY) / (aView.testFrame.size.height / 2);
                
                // Calculate the absolute change in x and y
                float absDX = fabs(dx);
                float absDY = fabs(dy);
                
                if (absDX > absDY){
                    if (dx >= 0) // Left
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x - CandyFrame.size.width;
                    }
                    else // Right
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x + aView.testFrame.size.width;
                    }
                }
                else
                {
                    if (dy >= 0) // Top
                    {
                        hitIt = YES;
                        CandyFrame.origin.y = aView.testFrame.origin.y - CandyFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution);
                        rollingX = CandyView.Vx * 360 / (Candy.frame.size.height * M_PI);

                        if (fabs(CandyView.Vy) < STICKY_THRESHOLD)
                        {
                            CandyView.Vy = 0;
                            hitIt = NO;
                        }
                    }
                }

                if (lastBrick == nil || [aView isEqual:lastBrick] == NO)
                {
                    lastBrick = aView;
                    score = aView.score;
                    firstHit = YES;
                }
                else
                {
                    firstHit = NO;
                }
            }
            continue;
        }

        
        // Touching the sandclock
        if (aView.tag == TAG_SANDCLOCK)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"swoosh.m4a" pitch:1.0f pan:0.0f gain:1.0];
                TimeDifference = 0.22;

                double delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    TimeDifference = 1;
                });

                [aView setAnimatingCustom:YES];
                [UIView animateWithDuration:0.2 animations:^{
                    [aView setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [aView removeFromSuperview];
                }];
            }
            continue;
        }


        // Red Brick
        if (aView.tag == TAG_RED_BRICK)
        {
            //if ([self circle:CandyFrame intersectsRect:aView.testFrame])
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                // Find the mid points of the entity and player
                float pMidX = CGRectGetMidX(CandyFrame);
                float pMidY = CGRectGetMidY(CandyFrame);
                float aMidX = CGRectGetMidX(aView.testFrame);
                float aMidY = CGRectGetMidY(aView.testFrame);
                
                // To find the side of entry calculate based on
                // the normalized sides
                float dx = (aMidX - pMidX) / (aView.testFrame.size.width / 2);
                float dy = (aMidY - pMidY) / (aView.testFrame.size.height / 2);
                
                // Calculate the absolute change in x and y
                float absDX = fabs(dx);
                float absDY = fabs(dy);
                
                if (absDX > absDY){
                    if (dx >= 0) // Left
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x - CandyFrame.size.width;
                    }
                    else // Right
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x + aView.testFrame.size.width;
                    }
                }
                else
                {
                    if (dy >= 0) // Top
                    {
                        hitIt = YES;
                        CandyFrame.origin.y = aView.testFrame.origin.y - CandyFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution * aView.stickiness);

                        if (fabs(CandyView.Vy) < STICKY_THRESHOLD)
                        {
                            CandyView.Vy = 0;
                            hitIt = NO;
                        }
                    }
                    else if (CandyView.Vy <= 0) // Bottom
                    {
                        CandyFrame.origin.y = aView.testFrame.origin.y + aView.testFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution * aView.stickiness);
                    }
                }
                
                if (lastBrick == nil || [aView isEqual:lastBrick] == NO)
                {
                    lastBrick = aView;
                    score = aView.score;
                    firstHit = YES;

                    // Set that we are animating this one
                    [aView setAnimatingCustom:YES];

                    // Brick1
                    UIImageView *brick1 = (UIImageView *)[aView viewWithTag:1];
                    float x1 = brick1.center.x, y1 = brick1.center.y;
                    float x2 = brick1.center.x - 50, y2 = playground.frame.size.height + 50;
                    UIBezierPath *trackPath = [UIBezierPath bezierPath];
                    [trackPath moveToPoint:P(x1, y1)];
                    [trackPath addCurveToPoint:P(x2, y2) controlPoint1:P(x1 - 20, y1 - 50) controlPoint2:P(x2 - 40, y1 - 50)];
                    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                    [anim setFillMode:kCAFillModeForwards];
                    [anim setRemovedOnCompletion:YES];
                    [anim setDelegate:self];
                    [anim setPath:trackPath.CGPath];
                    [anim setRepeatCount:1];
                    [anim setDuration:0.7];
                    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
                    [anim setValue:aView forUndefinedKey:@"RemoveObject"];
                    [brick1.layer addAnimation:anim forKey:@"race"];
                    [brick1.layer setPosition:CGPointMake(x2, y2)];

                    // Brick2
                    UIImageView *brick2 = (UIImageView *)[aView viewWithTag:2];
                    x1 = brick2.center.x, y1 = brick2.center.y;
                    x2 = brick2.center.x + 50, y2 = playground.frame.size.height + 50;
                    trackPath = [UIBezierPath bezierPath];
                    [trackPath moveToPoint:P(x1, y1)];
                    [trackPath addCurveToPoint:P(x2, y2) controlPoint1:P(x1 + 20, y1 - 50) controlPoint2:P(x2 + 40, y1 - 50)];
                    [anim setPath:trackPath.CGPath];
                    [anim setValue:nil forUndefinedKey:@"RemoveObject"];
                    [brick2.layer addAnimation:anim forKey:@"race"];
                    [brick2.layer setPosition:CGPointMake(x2, y2)];
                }
                else
                {
                    firstHit = NO;
                }
            }
            continue;
        }

        
        // Brick type of objects
        if (aView.tag == TAG_BRICK_MOVING_LEFT || aView.tag == TAG_BRICK_MOVING_RIGHT || aView.tag == TAG_BRICK_MOVING_UP || aView.tag == TAG_BRICK_MOVING_DOWN)
        {
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                // Find the mid points of the entity and player
                float pMidX = CGRectGetMidX(CandyFrame);
                float pMidY = CGRectGetMidY(CandyFrame);
                float aMidX = CGRectGetMidX(aView.testFrame);
                float aMidY = CGRectGetMidY(aView.testFrame);
                
                // To find the side of entry calculate based on
                // the normalized sides
                float dx = (aMidX - pMidX) / (aView.testFrame.size.width / 2);
                float dy = (aMidY - pMidY) / (aView.testFrame.size.height / 2);
                
                // Calculate the absolute change in x and y
                float absDX = fabs(dx);
                float absDY = fabs(dy);
                
                if (absDX > absDY){
                    if (dx >= 0) // Left
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x - CandyFrame.size.width;
                    }
                    else // Right
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x + aView.testFrame.size.width;
                    }
                }
                else
                {
                    if (dy >= 0) // Top
                    {
                        hitIt = YES;
                        CandyFrame.origin.y = aView.testFrame.origin.y - CandyFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution);
                        rollingX = CandyView.Vx * 360 / (Candy.frame.size.height * M_PI);
                        
                        if (fabs(CandyView.Vy) < STICKY_THRESHOLD)
                        {
                            CandyView.Vy = 0;
                            hitIt = NO;
                            CandyFrame.origin.x += aView.movingXV * duration;
                            CandyFrame.origin.y += aView.movingYV * duration;
                        }
                    }
                    else if (CandyView.Vy <= 0) // Bottom
                    {
                        CandyFrame.origin.y = aView.testFrame.origin.y + aView.testFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution);
                    }
                }
                
                if (lastBrick == nil || [aView isEqual:lastBrick] == NO)
                {
                    lastBrick = aView;
                    score = aView.score;
                    firstHit = YES;
                }
                else
                {
                    firstHit = NO;
                }
            }
            continue;
        }

        
        // Brick type of objects
        if (aView.tag == TAG_BRICK_1 || aView.tag == TAG_BRICK_2 || aView.tag == TAG_BRICK_3)
        {
            //if ([self circle:CandyFrame intersectsRect:aView.testFrame])
            if (CGRectIntersectsRect(CandyFrame, aView.testFrame))
            {
                // Find the mid points of the entity and player
                float pMidX = CGRectGetMidX(CandyFrame);
                float pMidY = CGRectGetMidY(CandyFrame);
                float aMidX = CGRectGetMidX(aView.testFrame);
                float aMidY = CGRectGetMidY(aView.testFrame);

                // To find the side of entry calculate based on
                // the normalized sides
                float dx = (aMidX - pMidX) / (aView.testFrame.size.width / 2);
                float dy = (aMidY - pMidY) / (aView.testFrame.size.height / 2);
                
                // Calculate the absolute change in x and y
                float absDX = fabs(dx);
                float absDY = fabs(dy);

                if (absDX > absDY){
                    if (dx >= 0) // Left
                    {
                        CandyFrame.origin.x = aView.testFrame.origin.x - CandyFrame.size.width;
                    }
                    else // Right
                    {
//                        [testView setFrame:aView.testFrame];
//                        [testView setHidden:NO];
//                        [playground bringSubviewToFront:testView];
//                        NSLog(@"11");
                        CandyFrame.origin.x = aView.testFrame.origin.x + aView.testFrame.size.width;
                    }
                }
                else
                {
                    if (dy >= 0) // Top
                    {
                        hitIt = YES;
                        CandyFrame.origin.y = aView.testFrame.origin.y - CandyFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution);
                        rollingX = CandyView.Vx * 360 / (Candy.frame.size.height * M_PI);

                        if (fabs(CandyView.Vy) < STICKY_THRESHOLD)
                        {
                            CandyView.Vy = 0;
                            hitIt = NO;
                        }
                    }
                    else if (CandyView.Vy <= 0) // Bottom
                    {
                        CandyFrame.origin.y = aView.testFrame.origin.y + aView.testFrame.size.height;
                        CandyView.Vy = (-CandyView.Vy * CandyView.restitution);
                    }
                }

                if (lastBrick == nil || [aView isEqual:lastBrick] == NO)
                {
                    lastBrick = aView;
                    score = aView.score;
                    firstHit = YES;
                }
                else
                {
                    firstHit = NO;
                }
            }
            continue;
        }
    } // End for 


    if (hitIt)
    {
        float volume = fabs(CandyView.Vy / 7);
        [[SimpleAudioEngine sharedEngine] playEffect:@"bump.m4a" pitch:1.0f pan:0.0f gain:volume];

        if (firstHit)
        {
            CurrScore += score;
            [self refreshScore];
        }
    }

    
    if (CandyFrame.origin.x < -GameOverPosition ||
        CandyFrame.origin.x > playground.frame.size.width + GameOverPosition ||
        CandyFrame.origin.y < -GameOverPosition ||
        CandyFrame.origin.y > playground.frame.size.height + GameOverPosition ||
        CandyFrame.origin.y > Ground.frame.origin.y)
    {
        [[SimpleAudioEngine sharedEngine] playEffect:@"break.m4a" pitch:1.0f pan:0.0f gain:1.0];
        [self showSuccessViewWithFailed:YES];
        return;
    }


    // ----- RENDER -----

    // Rotate
    rotation += rollingX;
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI * rotation / 180.0);
    [Candy setTransform:transform];

    // Set position
    [CandyView setFrame:CandyFrame];

    
    // Scrollbar
    float diff = playground_position * (ProgressBar.frame.size.height / (CurrTrackLength - playground.frame.size.height));
    [ProgressIndicator setCenter:CGPointMake(ProgressIndicator.center.x, ProgressIndicator.center.y + diff)];
    [ProgressFill setFrame:CGRectMake(ProgressFill.frame.origin.x, ProgressFill.frame.origin.y, ProgressFill.frame.size.width, ProgressIndicator.center.y)];
}

- (void)updateFps
{
    double CurrentTime = [displayLink timestamp];
    CurrentTime = CurrentTime * 0.9 + LastTime * 0.1;
    NSTimeInterval timeInterval = CurrentTime - LastTime;
    [Fps setText:[NSString stringWithFormat:@"%d", (int)round(1.0f / timeInterval)]];
    LastTime = CurrentTime;
}




// TODO: Remove ->
- (NSString *)documentPath:(NSString *)append
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:append];
}


- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
- (void)restClient:(DBRestClient*)client loadedFile:(NSString *)localPath
{
    if (CurrLevel == 0)
    {
        [levels release], levels = nil;
        levels = [[NSDictionary alloc] initWithContentsOfFile:localPath];
    }
    else
    {
        NSString *level_index = [NSString stringWithFormat:@"%d", CurrLevel];
        NSDictionary *level = [[NSDictionary alloc] initWithContentsOfFile:localPath];
        
        NSString *theme_index = [NSString stringWithFormat:@"%d", CurrTheme];
        NSMutableDictionary *theme = [[levels objectForKey:theme_index] mutableCopy];
        if (theme == nil)
        {
            theme = [[NSMutableDictionary alloc] init];
        }
        [theme setObject:level forKey:level_index];
        [level release];
        
        NSMutableDictionary *levels_tmp = [levels mutableCopy];
        [levels release], levels = nil;
        [levels_tmp setObject:theme forKey:theme_index];
        levels = [levels_tmp copy];
        
        // Delte tmp file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:localPath error:nil];
        
        // Overwrite default Levels.plist file
        NSString *levels_path = [self documentPath:@"Levels.plist"];
        [levels writeToFile:levels_path atomically:YES];

        [levels_tmp release];
        [levels release];
        [theme release];
    }
    
    // Show alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"File Succesfully Loaded.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}


// Revisions events
- (void)restClient:(DBRestClient *)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path
{
    NSString *version = nil;
    if (revisions && revisions.count > 0)
    {
        DBMetadata *metadata = [revisions objectAtIndex:0];
        version = metadata.rev;
    }

    NSString *levels_path = [self documentPath:@"Levels.plist"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:levels_path] == NO)
    {
        levels_path = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    }
    NSLog(@"Upload file: %@", version);
    [[self restClient] uploadFile:path toPath:@"/" withParentRev:version fromPath:levels_path];
}
- (void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error
{
    if ((int)error.code == 404)
    {
        [self restClient:client loadedRevisions:nil forFile:[error.userInfo objectForKey:@"path"]];
        return;
    }
    NSLog(@"Revisions failed");
}


// Upload events
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"done" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}



- (void)initDropbox
{
    if ([DBSession sharedSession] == nil)
    {
        DBSession* dbSession = [[[DBSession alloc] initWithAppKey:@"8eep9mvdfsmiopm" appSecret:@"qg9rk3ciy2evjf7" root:kDBRootAppFolder] autorelease];
        [DBSession setSharedSession:dbSession];
    }
}
- (void)getDropboxAccess:(UIButton *)sender
{
    [self initDropbox];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        CurrLevel = 0;
        NSString *filename = @"Levels.plist";
        NSString *path = [self documentPath:filename];
        [[self restClient] loadFile:[NSString stringWithFormat:@"/%@", filename] intoPath:path];
    }
}

- (void)loadLevelFromDropbox:(UIButton *)sender
{
    [self initDropbox];
    if (![[DBSession sharedSession] isLinked]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:@"No dropbox access" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSString *filename = [NSString stringWithFormat:@"Level-%d-%d.plist", CurrTheme, CurrLevel];
    NSString *path = [self documentPath:filename];
    [[self restClient] loadFile:[NSString stringWithFormat:@"/%@", filename] intoPath:path];
}

- (void)uploadLevelsToDropbox:(UIButton *)sender
{
    NSLog(@"Load revisions");
    [[self restClient] loadRevisionsForFile:@"/Levels.plist"];
}
// TODO: Remove <-

@end
