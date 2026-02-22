//
//  AppDelegate.m
//  Level Creator
//
//  Created by Gints Murans on 2/19/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "ImageSpriteCache.h"

@implementation AppDelegate
@synthesize currTheme, currLevel, yourName;


- (void)dealloc
{
    [cachedPuffAnimations release];
    [settings release];
    [levels release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    settings = [[NSUserDefaults standardUserDefaults] retain];
    [settings registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:1], @"currTheme",
                                [NSNumber numberWithInt:1], @"currLevel",nil]];

    self.currTheme = [settings integerForKey:@"currTheme"];
    self.currLevel = [settings integerForKey:@"currLevel"];
    levels = [[settings dictionaryForKey:@"Levels"] mutableCopy];
    if (levels == nil)
    {
        levels = [[NSMutableDictionary alloc] init];
    }


    // Define some tags
    _tags = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:500], @"candy@2x.png",
//             [NSNumber numberWithInt:500], @"candy@2x.png",
//             [NSNumber numberWithInt:501], @"snail@2x.png",
//             [NSNumber numberWithInt:502], @"ground@2x.png",

             [NSNumber numberWithInt:1000], @"brick1@2x.png",
             [NSNumber numberWithInt:1001], @"brick2@2x.png",
             [NSNumber numberWithInt:1002], @"brick3@2x.png",
             [NSNumber numberWithInt:1003], @"brick4@2x.png",
             [NSNumber numberWithInt:1004], @"brick5@2x.png",

             [NSNumber numberWithInt:2001], @"watermelon@2x.png",
             [NSNumber numberWithInt:2002], @"bananas@2x.png",
             [NSNumber numberWithInt:2003], @"strawberry@2x.png",
             [NSNumber numberWithInt:2004], @"whale@2x.png",
             [NSNumber numberWithInt:2008], @"coin-1@2x.png",

             [NSNumber numberWithInt:3000], @"saw-1@2x.png",
             [NSNumber numberWithInt:3001], @"fire@2x.png",
             nil];

    
    // Cache our sprites
    [[ImageSpriteCache sharedInstance] addSpriteFramesWithFile:@"game-objects.plist"];


    // Sort our cache
    NSDictionary *cache = [ImageSpriteCache sharedInstance].imageCache;
    NSArray *sorted = [cache keysSortedByValueUsingComparator:^NSComparisonResult(NSImage *obj1, NSImage *obj2){
        float c1 = obj1.size.width + obj1.size.height;
        float c2 = obj2.size.width + obj2.size.height;
        if (c1 > c2)
        {
            return NSOrderedDescending;
        }

        if (c1 < c2)
        {

            return NSOrderedAscending;
        }

        return NSOrderedSame;
    }];



    // Filter repeated sprites (animations)
    NSString *regex = @"[A-Za-z]+?-[2-9]+?.*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT SELF MATCHES %@", regex];
    sorted = [sorted filteredArrayUsingPredicate:pred];


    // Go through whats left and add it to our custom view
    float distance = 10.0, x = distance, y = distance, maxHeight = 0.0, width = 0.0, height = 0.0;
    for (NSString *key in sorted)
    {
        int tag = [[_tags objectForKey:key] intValue];
        if (tag == 0)
        {
            NSLog(@"Tag Not Found: %@", key);
            continue;
        }

        NSImage *image = [cache objectForKey:key];
        NSButton *imageView = [[NSButton alloc] initWithFrame:NSMakeRect(x, y, image.size.width, image.size.height)];
        [imageView setAction:@selector(addObject:)];
        [imageView setButtonType:NSMomentaryChangeButton];
        [imageView setBordered:NO];
        [imageView setImage:image];
        [imageView setTitle:nil];
        [imageView setTag:tag];
        [ObjectsView.documentView addSubview:imageView];

        x += image.size.width + distance;
        if (image.size.height > maxHeight)
        {
            maxHeight = image.size.height + distance;
        }
        if (x > width)
        {
            width = x;
        }
        if (x > ObjectsView.frame.size.width)
        {
            y += maxHeight;
            height += maxHeight;
            maxHeight = 0.0;
            x = distance;
        }
    }

    [ObjectsView.documentView setFrame:NSMakeRect(0, 0, width, height + maxHeight + distance)];
    [ObjectsView.documentView scrollPoint:NSMakePoint(0, 0)];



    // Load some assets
    NSImage *topTreeImage = [[ImageSpriteCache sharedInstance] imageWithName:@"tree-top@2x.png"];
    _treeTop = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, topTreeImage.size.width, topTreeImage.size.height)];
    [_treeTop setImage:topTreeImage];
    [_treeTop setAutoresizingMask:NSViewNotSizable];


    NSImage *candyImage = [[ImageSpriteCache sharedInstance] imageWithName:@"candy@2x.png"];
    candyImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, candyImage.size.width, candyImage.size.height)];
    [candyImageView setImage:candyImage];
    [candyImageView setAutoresizingMask:NSViewNotSizable];


    NSImage *groundImage = [[ImageSpriteCache sharedInstance] imageWithName:@"snail@2x.png"];
    greenImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, groundImage.size.width, groundImage.size.height)];
    [greenImageView setImage:groundImage];
    [greenImageView setTag:101];
    [greenImageView setAutoresizingMask:NSViewNotSizable];


    // Puff
    puffCounter = 0;
    puffCurrentImage = 0;
    cachedPuffAnimations = [[NSArray alloc] initWithObjects:
                                [NSImage imageNamed:@"puf1"],
                                [NSImage imageNamed:@"puf2"],
                                [NSImage imageNamed:@"puf3"],
                                [NSImage imageNamed:@"puf4"], nil];


    // Load level
    self.yourName = [settings objectForKey:@"YourName"];
    [self loadThemeAndLevel];


    // Dropbox
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [settings setObject:yourName forKey:@"YourName"];
    [settings synchronize];
}




static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    @autoreleasepool {
        return [(AppDelegate *)displayLinkContext getFrameForTime:outputTime];
    }
}
- (CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    puffCounter += 0.4;
    if (puffCounter >= 1)
    {
        puffCounter = 0;
        puffCurrentImage += 1;
    }
    if (puffCurrentImage >= cachedPuffAnimations.count)
    {
        puffCurrentImage = 0;
        [puffImageView setHidden:YES];
        CVDisplayLinkRelease(displayLink);
        return kCVReturnSuccess;
    }
    [puffImageView setImage:[cachedPuffAnimations objectAtIndex:puffCurrentImage]];

    return kCVReturnSuccess;
}
- (void)showPuffAnimationAtPoint:(NSPoint)point
{
    [puffImageView setImage:[cachedPuffAnimations objectAtIndex:0]];
    [puffImageView setFrameOrigin:point];
    [puffImageView setHidden:NO];

    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
    CVDisplayLinkStart(displayLink);
}




- (void)loadDefaults
{
    [playground.documentView setFrameSize:NSMakeSize([playground.documentView frame].size.width, playground.frame.size.height)];
    [speedTextField setIntegerValue:60 + currLevel * 3];
    [commentsTextView setString:@""];

    // Candy
    float x = (playground.frame.size.width - candyImageView.image.size.width) / 2;
    float y = (playground.frame.size.height / 5);
    [candyImageView setFrameOrigin:NSMakePoint(x, y)];

    // Green
    x = (playground.frame.size.width - greenImageView.image.size.width) / 2;
    y = [playground.documentView frame].size.height - greenImageView.frame.size.height;
    [greenImageView setFrameOrigin:NSMakePoint(x, y)];
}

- (void)loadThemeAndLevel
{
    [themeTextField setIntegerValue:currTheme];
    [levelTextField setIntegerValue:currLevel];

    // Clear playground
    NSArray *views = [[playground.documentView subviews] copy];
    for (id view in views)
    {
        if ([view tag] >= 0)
        {
            [view removeFromSuperview];
        }
    }
    [views release];
    [playground.documentView scrollPoint:NSMakePoint(0, 0)];


    // Load settings and objects from saved theme and level data
    NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
    NSMutableDictionary *theme = [[levels objectForKey:theme_index] mutableCopy];
    if (theme == nil)
    {
        [self loadDefaults];
    }
    else
    {
        NSNumber *level_index = [NSString stringWithFormat:@"%d", currLevel];
        NSMutableDictionary *level = [[theme objectForKey:level_index] mutableCopy];
        if (level == nil)
        {
            [self loadDefaults];
        }
        else
        {
            NSPoint initMidPoint = NSPointFromString([level objectForKey:@"InitPoint"]);
            NSPoint endMidPoint = NSPointFromString([level objectForKey:@"EndPoint"]);

            [playground.documentView setFrameSize:NSMakeSize([playground.documentView frame].size.width, [[level objectForKey:@"Length"] floatValue])];
            [speedTextField setIntegerValue:[[level objectForKey:@"Speed"] integerValue]];
            [candyImageView setFrameOrigin:NSStartPointFromMidPointAndSize(initMidPoint, candyImageView.frame.size)];
            [greenImageView setFrameOrigin:NSStartPointFromMidPointAndSize(endMidPoint, greenImageView.frame.size)];


            NSString *string = [level objectForKey:@"Comments"];
            if (string == nil)
            {
                string = @"";
            }
            [commentsTextView setString:string];


            NSArray *objects = [level objectForKey:@"Objects"];
            for (NSDictionary *object_data in objects)
            {
                NSPoint objMidPoint = NSPointFromString([object_data objectForKey:@"Point"]);
                int tag = [[object_data objectForKey:@"Tag"] intValue];
                NSButton *source_image_view = (NSButton *)[ObjectsView viewWithTag:tag];
                if (source_image_view == nil || tag == 0)
                {
                    NSLog(@"Not Found: %d", tag);
                    continue;
                }

                NSRect frame;
                frame.origin = NSStartPointFromMidPointAndSize(objMidPoint, source_image_view.frame.size);
                frame.size = source_image_view.frame.size;

                NSImageView *image_view = [[NSImageView alloc] init];
                [image_view setAutoresizingMask:NSViewNotSizable];
                [image_view setImage:source_image_view.image];
                [image_view setFrame:frame];
                [image_view setTag:tag];

                if (source_image_view.title != nil && [source_image_view.title isEqualToString:@""] == NO)
                {
                    NSTextField *label = [[NSTextField alloc] init];
                    [label setEditable:NO];
                    [label setBordered:NO];
                    [label setDrawsBackground:NO];
                    [label setTextColor:[NSColor whiteColor]];
                    [label setStringValue:source_image_view.title];
                    [label sizeToFit];
                    [label setFrameOrigin:NSMakePoint(5, (image_view.frame.size.height - label.frame.size.height) / 2)];
                    [image_view addSubview:label];
                    [label release];
                }

                [playground.documentView addSubview:image_view];
                [image_view release];
            }

            [level release];
        }
        [theme release];
        
    }

    
    // Set playground scroll position
    [playground.documentView addSubview:candyImageView];
    [playground.documentView addSubview:greenImageView];
    [playground.documentView addSubview:_treeTop];
    [_treeTop setFrameOrigin:NSMakePoint(([playground.documentView frame].size.width - _treeTop.frame.size.width) / 2, 0)];
}


- (void)saveLevels
{
    [settings setObject:levels forKey:@"Levels"];
    [settings synchronize];
}


- (void)savePlayground
{
    NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
    NSMutableDictionary *theme = [[levels objectForKey:theme_index] mutableCopy];
    if (theme == nil)
    {
        theme = [[NSMutableDictionary alloc] init];
    }

    NSNumber *level_index = [NSString stringWithFormat:@"%d", currLevel];
    NSMutableDictionary *level = [[theme objectForKey:level_index] mutableCopy];
    if (level == nil)
    {
        level = [[NSMutableDictionary alloc] init];
    }

    [level setObject:[NSNumber numberWithFloat:[playground.documentView frame].size.height] forKey:@"Length"];
    [level setObject:[NSNumber numberWithInteger:speedTextField.integerValue] forKey:@"Speed"];
    [level setObject:NSStringFromPoint(NSMidPointFromRect(candyImageView.frame)) forKey:@"InitPoint"];
    [level setObject:NSStringFromPoint(NSMidPointFromRect(greenImageView.frame)) forKey:@"EndPoint"];
    [level setObject:commentsTextView.string forKey:@"Comments"];


    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for (NSImageView *the_object in [playground.documentView subviews])
    {
        if ([the_object isEqual:candyImageView] || [the_object isEqual:greenImageView] || [the_object tag] < 0)
        {
            continue;
        }

        [objects addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            NSStringFromPoint(NSMidPointFromRect(the_object.frame)), @"Point",
                            [NSNumber numberWithInteger:the_object.tag], @"Tag", nil]];
    }

    [level setObject:objects forKey:@"Objects"];
    [objects release];

    [theme setObject:level forKey:level_index];
    [level release];

    [levels setObject:theme forKey:theme_index];
    [theme release];

    [self saveLevels];
}


#pragma mark - IBActions

- (void)showAdvancedControls:(NSButton *)sender
{
    [[MainView viewWithTag:201] setHidden:NO];
}

- (void)addObject:(NSButton *)sender
{
    NSImageView *image_view = [[NSImageView alloc] init];
    [image_view setAutoresizingMask:NSViewNotSizable];
    [image_view setImage:sender.image];
    float x = (playground.frame.size.width - sender.image.size.width) / 2;
    float y = playground.documentVisibleRect.origin.y + (playground.frame.size.height / 2);
    [image_view setFrame:NSMakeRect(x, y, sender.image.size.width, sender.image.size.height)];
    [image_view setTag:sender.tag];

    if (sender.title != nil && [sender.title isEqualToString:@""] == NO)
    {
        NSTextField *label = [[NSTextField alloc] init];
        [label setEditable:NO];
        [label setBordered:NO];
        [label setDrawsBackground:NO];
        [label setTextColor:[NSColor whiteColor]];
        [label setStringValue:sender.title];
        [label sizeToFit];
        [label setFrameOrigin:NSMakePoint(5, (image_view.frame.size.height - label.frame.size.height) / 2)];
        [image_view addSubview:label];
        [label release];
    }
    
    [playground.documentView addSubview:image_view];
    [image_view release];

    [self savePlayground];
}

- (void)changeThemeOrLevelStepper:(NSStepper *)sender
{
    [settings setInteger:self.currTheme forKey:@"currTheme"];
    [settings setInteger:self.currLevel forKey:@"currLevel"];
    [settings synchronize];

    [self loadThemeAndLevel];
}

- (void)forceSave:(NSButton *)sender
{
    [self savePlayground];
}

- (void)resetLevel:(NSButton *)sender
{
    [[playground.documentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self loadDefaults];
    [playground.documentView addSubview:candyImageView];
    [playground.documentView addSubview:greenImageView];
}



#pragma mark - Import / Export

- (void)importAll:(NSButton *)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"All your current changes will be lost! Are you sure?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    NSInteger ret = [alert runModal];
    if (ret == NSAlertAlternateReturn)
    {
        return;
    }

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];

    ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        [levels release], levels = nil;
        levels = [[NSMutableDictionary alloc] initWithContentsOfURL:panel.URL];
        [self saveLevels];
        [self loadThemeAndLevel];
    }
}



- (void)exportAll:(NSButton *)sender
{
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:levels format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Levels.plist"];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];

    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        [data writeToURL:[panel URL] atomically:YES];
    }
}



- (void)importTheme:(NSButton *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];
    
    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
        NSDictionary *theme = [[NSMutableDictionary alloc] initWithContentsOfURL:panel.URL];
        [levels setObject:theme forKey:theme_index];
        [theme release];
        
        [self saveLevels];
        [self loadThemeAndLevel];
    }
}



- (void)exportTheme:(NSButton *)sender
{
    NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
    NSDictionary *theme = [levels objectForKey:theme_index];
    if (theme == nil)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Current theme is not yet created" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        return;
    }

    NSData *data = [NSPropertyListSerialization dataFromPropertyList:theme format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:[NSString stringWithFormat:@"Theme-%d.plist", currTheme]];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];

    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        [data writeToURL:[panel URL] atomically:YES];
    }
}



- (void)importLevel:(NSButton *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];
    
    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
        NSMutableDictionary *theme = [[levels objectForKey:theme_index] mutableCopy];
        if (theme == nil)
        {
            theme = [[NSMutableDictionary alloc] init];
        }

        NSNumber *level_index = [NSString stringWithFormat:@"%d", currLevel];
        NSDictionary *level = [[NSMutableDictionary alloc] initWithContentsOfURL:panel.URL];
        [theme setObject:level forKey:level_index];
        [level release];
        
        [levels setObject:theme forKey:theme_index];
        [theme release];
        
        [self saveLevels];
        [self loadThemeAndLevel];
    }
}



- (void)exportLevel:(NSButton *)sender
{
    NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
    NSDictionary *theme = [levels objectForKey:theme_index];
    if (theme == nil)
    {
        return;
    }

    NSNumber *level_index = [NSString stringWithFormat:@"%d", currLevel];
    NSDictionary *level = [theme objectForKey:level_index];
    if (level == nil)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Current level is not yet created" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        return;
    }

    NSData *data = [NSPropertyListSerialization dataFromPropertyList:level format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:[NSString stringWithFormat:@"Level-%d-%d (%@).plist", currTheme, currLevel, yourName]];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"plist"]];

    NSInteger ret = [panel runModal];
    if (ret == NSFileHandlingPanelOKButton)
    {
        [data writeToURL:[panel URL] atomically:YES];
    }
}


- (void)levelToDropbox:(NSButton *)sender
{
    if ([self initDropbox])
    {
        NSNumber *theme_index = [NSString stringWithFormat:@"%d", currTheme];
        NSDictionary *theme = [levels objectForKey:theme_index];
        if (theme == nil)
        {
            return;
        }
        
        NSNumber *level_index = [NSString stringWithFormat:@"%d", currLevel];
        NSDictionary *level = [theme objectForKey:level_index];
        if (level == nil)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Current level is not yet created" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
            return;
        }

        NSData *data = [NSPropertyListSerialization dataFromPropertyList:level format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
        NSString *filename = [NSString stringWithFormat:@"Level-%d-%d.plist", currTheme, currLevel];
        uploadFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:filename] retain];
        [data writeToFile:uploadFile atomically:YES];

        // Send to dropbox
        [loader setIndeterminate:YES];
        [loader startAnimation:nil];
        [[self restClient] loadRevisionsForFile:[NSString stringWithFormat:@"/%@", filename]];
    }
}

- (void)allToDropbox:(NSButton *)sender
{
    if ([self initDropbox])
    {
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:levels format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
        NSString *filename = @"Levels.plist";
        uploadFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:filename] retain];
        [data writeToFile:uploadFile atomically:YES];

        // Send to dropbox
        [loader setIndeterminate:YES];
        [loader startAnimation:nil];
        [[self restClient] loadRevisionsForFile:[NSString stringWithFormat:@"/%@", filename]];
    }
}


#pragma mark - Dropbox

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (BOOL)initDropbox
{
    if ([DBSession sharedSession] == nil)
    {
        DBSession* dbSession = [[[DBSession alloc] initWithAppKey:@"8eep9mvdfsmiopm" appSecret:@"qg9rk3ciy2evjf7" root:kDBRootAppFolder] autorelease];
        [DBSession setSharedSession:dbSession];
    }

    if ([[DBSession sharedSession] isLinked] == NO)
    {
        [[DBAuthHelperOSX sharedHelper] authenticate];
        return NO;
    }

    return YES;
}


// Authentication
- (void)authHelperStateChangedNotification:(NSNotification *)notification
{
    if ([[DBSession sharedSession] isLinked])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Dropbox is now linked. Try pressing that button again." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
}



// Upload events
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
    [loader setIndeterminate:YES];
    [loader stopAnimation:nil];
    [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
}
- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    [loader setDoubleValue:progress];
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [loader setIndeterminate:YES];
    [loader stopAnimation:nil];

    [[NSFileManager defaultManager] removeItemAtPath:uploadFile error:nil];
    [uploadFile release], uploadFile = nil;
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
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
    [loader setIndeterminate:NO];
    [[self restClient] uploadFile:path toPath:@"/" withParentRev:version fromPath:uploadFile];
}
- (void)restClient:(DBRestClient *)client loadRevisionsFailedWithError:(NSError *)error
{
    if ((int)error.code == 404)
    {
        [self restClient:client loadedRevisions:nil forFile:[error.userInfo objectForKey:@"path"]];
        return;
    }

    [loader setIndeterminate:YES];
    [loader stopAnimation:nil];

    [[NSFileManager defaultManager] removeItemAtPath:uploadFile error:nil];
    [uploadFile release], uploadFile = nil;
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

@end
