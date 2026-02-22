//
//  AppDelegate.h
//  Level Creator
//
//  Created by Gints Murans on 2/19/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <DropboxOSX/DropboxOSX.h>


#define NSMidPointFromRect(__RECT__) NSMakePoint((__RECT__.origin.x + (__RECT__.size.width / 2)), (__RECT__.origin.y + (__RECT__.size.height / 2)))
#define NSStartPointFromMidPointAndSize(__POINT__,__SIZE__) NSMakePoint((__POINT__.x - (__SIZE__.width / 2)), (__POINT__.y - (__SIZE__.height / 2)))


@interface AppDelegate : NSObject <NSApplicationDelegate, DBRestClientOSXDelegate>
{
    DBRestClient *restClient;

    IBOutlet NSView *MainView;
    IBOutlet NSView *CustomView;
    IBOutlet NSScrollView *ObjectsView;
    IBOutlet NSScrollView *playground;
    IBOutlet NSImageView *bgImageView;
    IBOutlet NSImageView *candyImageView;
    IBOutlet NSImageView *greenImageView;

    NSImageView *_treeTop;

    IBOutlet NSTextField *themeTextField;
    IBOutlet NSTextField *levelTextField;
    IBOutlet NSTextField *speedTextField;

    IBOutlet NSTextField *nameTextField;
    IBOutlet NSTextView *commentsTextView;
    IBOutlet NSProgressIndicator *loader;

    NSUserDefaults *settings;
    NSMutableDictionary *levels;
    NSDictionary *_tags;


    int puffCurrentImage;
    float puffCounter;
    NSArray *cachedPuffAnimations;
    IBOutlet NSImageView *puffImageView;

    CVDisplayLinkRef displayLink;

    NSString *uploadFile;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) int currTheme;
@property (assign) int currLevel;
@property (assign) NSString *yourName;


- (IBAction)showAdvancedControls:(NSButton *)sender;
- (IBAction)addObject:(NSButton *)sender;
- (IBAction)changeThemeOrLevelStepper:(NSStepper *)sender;
- (IBAction)forceSave:(NSButton *)sender;
- (IBAction)resetLevel:(NSButton *)sender;


- (IBAction)importAll:(NSButton *)sender;
- (IBAction)exportAll:(NSButton *)sender;
- (IBAction)importTheme:(NSButton *)sender;
- (IBAction)exportTheme:(NSButton *)sender;
- (IBAction)importLevel:(NSButton *)sender;
- (IBAction)exportLevel:(NSButton *)sender;

- (IBAction)levelToDropbox:(NSButton *)sender;
- (IBAction)allToDropbox:(NSButton *)sender;

- (void)savePlayground;
- (void)showPuffAnimationAtPoint:(NSPoint)point;

@end
