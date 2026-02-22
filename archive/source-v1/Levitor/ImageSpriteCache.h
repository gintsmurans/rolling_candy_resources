//
//  ImageSpriteCache.h
//  Falling Candy
//
//  Created by Gints Murans on 4/26/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else

#import <Cocoa/Cocoa.h>

#endif



#define DegreesToRadians(degrees) degrees * M_PI / 180
#define RadiansToDegrees(radians) radians * 180/M_PI



#if TARGET_OS_IPHONE

@interface UIImage(SpriteCache)
- (UIImage *)imageFromRect:(CGRect)rect rotated:(BOOL)isRotated offset:(CGPoint)frameOffset originalSize:(CGSize)originalSize;
@end;

#else

@interface NSImage(SpriteCache)
- (NSImage *)imageFromRect:(NSRect)rect rotated:(BOOL)isRotated offset:(NSPoint)frameOffset originalSize:(NSSize)originalSize;
@end;

#endif


@interface ImageSpriteCache : NSObject
{
    NSMutableSet *_loadedFilenames;
}
@property (nonatomic, retain) NSMutableDictionary *imageCache;
@property (nonatomic, retain) NSMutableDictionary *imageDataCache;

+ (ImageSpriteCache *)sharedInstance;
- (void)addSpriteFramesWithFile:(NSString *)filename;
#if TARGET_OS_IPHONE

- (UIImage *)imageWithName:(NSString *)imageName;

#else

- (NSImage *)imageWithName:(NSString *)imageName;

#endif
@end
