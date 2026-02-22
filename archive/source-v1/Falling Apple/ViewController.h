//
//  ViewController.h
//  Falling Apple
//
//  Created by Gints Murans on 1/23/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "PhysicsUIView.h"
#import "PhysicsUIImageView.h"

// TODO: Remove ->
#import <DropboxSDK/DropboxSDK.h>


@interface ViewController : UIViewController <UIAccelerometerDelegate, DBRestClientDelegate>
{
    // TODO: Remove ->
    DBRestClient *restClient;
    IBOutlet UIButton *loadAllLevelsFromDropboxButton;

    NSUserDefaults *Settings;
    NSDictionary *levels;
    NSMutableDictionary *FinishedLevels;
    NSArray *Products;

    float ScrollRate, CandyFallRate, GameOverPosition, TimeDifference;

    IBOutlet UIView *HomeView;
    IBOutlet UIView *LevelsView;
    IBOutlet UIView *GameView;

    
    // HOME
    IBOutlet UIImageView *RCandy;
    
    
    // LEVELS
    BOOL LevelsUnlocked;
    IBOutlet UIScrollView *ThemesView;
    IBOutlet UIView *ShareView;
    IBOutlet UILabel *ShareTitleLabel;
    IBOutlet UIButton *FacebookButton;
    IBOutlet UIView *LoaderView;
    IBOutlet UIView *LoaderBg;
    IBOutlet UIActivityIndicatorView *LoaderIndicator;
    CGPoint OriginalPoint;


    // GAME
    IBOutlet UIView *playground;
    IBOutlet PhysicsUIView *CandyView;
    IBOutlet UIImageView *Candy;
    IBOutlet UIImageView *Ground;
    IBOutlet UIView *WormWrapperView;
    IBOutlet UIImageView *TheWorm;
    IBOutlet UIButton *pauseButton;
    IBOutlet UIImageView *ProgressBar;
    IBOutlet UIImageView *ProgressIndicator;
    IBOutlet UIImageView *ProgressFill;
    UIFont *BigFont;
    NSArray *CachedPuffAnimation, *CachedMonsterAnimation;

    // Candy Animations
    NSArray *candyShineAnimation;

    BOOL successAnimating;
    int successInterval, successStar;

    IBOutlet UIView *SuccessView;
    IBOutlet UILabel *SuccessScoreLabel;
    IBOutlet UILabel *SuccessLevelLabel;
    IBOutlet UIButton *SucessNextButton;
    IBOutlet UIImageView *GreetingsImageView;
    IBOutlet UIImageView *SuccessSunView;

    IBOutlet UIView *testView;
    IBOutlet UIView *testView2;

    IBOutlet UILabel *FruitScoreLabel;


    PhysicsUIImageView *HelperTest;
    float HelperSecondsCounter;
    int HelperSeconds;
    IBOutlet UILabel *HelperSecondsLabel;
    
    float CurrTrackLength;
    int Distance, CurrTheme, CurrLevel, CurrStars, CurrScore, CurrHighScore, MaxScore, TotalScore, TotalThemes, TotalLevels;
    PhysicsUIImageView *lastBrick;
    IBOutlet UILabel *CurrScoreLabel;
    IBOutlet UILabel *HighScoreLabel;
    IBOutlet UILabel *TotalScoreLabel;

    CMMotionManager *motionManager;
    UIAccelerationValue rollingX, movingX;

    CADisplayLink *displayLink;
    float rotation;
    int nextYPos;

    // Sound
    BOOL SoundIsOn;

    double LastTime;
    IBOutlet UILabel *Fps;
}

@property (nonatomic, assign, getter = isRunning) BOOL running;

- (IBAction)homePlayButtonAction:(id)sender;
- (IBAction)pauseSoundAction:(UIButton *)sender;
- (IBAction)pauseGameAction:(UIButton *)sender;
- (IBAction)playLevelAction:(UIButton *)sender;

- (IBAction)goBackButtonAction:(UIButton *)sender;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)shareFacebookAction:(UIButton *)sender;
- (IBAction)shareTwitterAction:(UIButton *)sender;
- (IBAction)shareCancelAction:(UIButton *)sender;
- (IBAction)unlockAllAction:(UIButton *)sender;

- (IBAction)SuccessNextButtonAction:(UIButton *)sender;
- (IBAction)SuccessReplayButtonAction:(UIButton *)sender;
- (IBAction)SuccessMenuButtonAction:(UIButton *)sender;


//TODO: Remove ->
- (IBAction)getDropboxAccess:(UIButton *)sender;
- (IBAction)loadLevelFromDropbox:(UIButton *)sender;
- (IBAction)uploadLevelsToDropbox:(UIButton *)sender;
//TODO: Remove <-

@end
