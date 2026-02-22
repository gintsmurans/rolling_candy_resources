//
//  ImageSpriteCache.m
//  Falling Candy
//
//  Created by Gints Murans on 4/26/13.
//  Copyright (c) 2013 4Apps. All rights reserved.
//

#import "ImageSpriteCache.h"


#if TARGET_OS_IPHONE

@implementation UIImage(SpriteCache)

- (UIImage *)imageFromRect:(CGRect)rect rotated:(BOOL)isRotated offset:(CGPoint)frameOffset originalSize:(CGSize)originalSize
{
    CGRect cropRect = rect;
    if (isRotated == YES)
    {
        cropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }

    CGRect zeroRect = CGRectZero;
    CGImageRef imageRef = [self CGImageForProposedRect:&zeroRect context:[NSGraphicsContext currentContext] hints:nil];
    CGImageRef targetImage = CGImageCreateWithImageInRect(imageRef, cropRect);

    // Rotate
    if (isRotated == YES)
    {
        CGContextRef context = CGBitmapContextCreate(nil,
                                                     rect.size.width,
                                                     rect.size.height,
                                                     CGImageGetBitsPerComponent(targetImage),
                                                     0,
                                                     CGImageGetColorSpace(targetImage),
                                                     kCGImageAlphaPremultipliedFirst);

        CGContextRotateCTM (context, DegreesToRadians(90));
        CGContextTranslateCTM(context, 0, -rect.size.width);

        CGContextDrawImage(context, CGRectMake(0, 0, rect.size.height, rect.size.width), targetImage);
        targetImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
    }

    // Return new NSImage
    return [[[UIImage alloc] initWithCGImage:targetImage scale:1.0 orientation:nil] autorelease];
}

@end


#else


@implementation NSImage(SpriteCache)

- (NSImage *)imageFromRect:(NSRect)rect rotated:(BOOL)isRotated offset:(NSPoint)frameOffset originalSize:(NSSize)originalSize
{
    NSRect cropRect = rect;
    if (isRotated == YES)
    {
        cropRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }

    NSRect zeroRect = NSZeroRect;
    CGImageRef imageRef = [self CGImageForProposedRect:&zeroRect context:[NSGraphicsContext currentContext] hints:nil];
    CGImageRef targetImage = CGImageCreateWithImageInRect(imageRef, cropRect);

    // Rotate
    if (isRotated == YES)
    {
        CGContextRef context = CGBitmapContextCreate(nil,
                                                     rect.size.width,
                                                     rect.size.height,
                                                     CGImageGetBitsPerComponent(targetImage),
                                                     0,
                                                     CGImageGetColorSpace(targetImage),
                                                     kCGImageAlphaPremultipliedFirst);

        CGContextRotateCTM (context, DegreesToRadians(90));
        CGContextTranslateCTM(context, 0, -rect.size.width);

        CGContextDrawImage(context, CGRectMake(0, 0, rect.size.height, rect.size.width), targetImage);
        targetImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
    }

    // Return new NSImage
    return [[[NSImage alloc] initWithCGImage:targetImage size:NSZeroSize] autorelease];
}
@end

#endif



@implementation ImageSpriteCache
@synthesize imageCache = _imageCache, imageDataCache = _imageDataCache;

+ (ImageSpriteCache *)sharedInstance
{
    static dispatch_once_t once;
    static ImageSpriteCache *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    if ((self = [super init]))
    {
        _imageCache = [[NSMutableDictionary alloc] init];
        _imageDataCache = [[NSMutableDictionary alloc] init];
        _loadedFilenames = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_loadedFilenames release];
    [_imageCache release];
    [_imageDataCache release];
    [super dealloc];
}


- (void)addSpriteFramesWithFile:(NSString *)filename
{

	if ([_loadedFilenames member:filename])
    {
        NSLog(@"Already loaded: %@", filename);
        return;
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSAssert(path, @"Filename could not be found");
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

    NSString *texturePath = nil;
    NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
    if (metadataDict)
    {
        texturePath = [metadataDict objectForKey:@"textureFileName"];
    }

    if (texturePath)
    {
        NSString *textureBase = [path stringByDeletingLastPathComponent];
        texturePath = [textureBase stringByAppendingPathComponent:texturePath];
    }
    else
    {
        texturePath = [path stringByDeletingPathExtension];
        texturePath = [texturePath stringByAppendingPathExtension:@"png"];
    }

    [self addSpriteFramesWithDictionary:dict textureReference:texturePath];
    [_loadedFilenames addObject:filename];
}



#if TARGET_OS_IPHONE
- (void)addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureReference:(NSString *)textureFileName
{
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
    UIImage *textureImage = [[UIImage alloc] initWithContentsOfFile:textureFileName];

	// add real frames
	for(NSString *frameDictKey in framesDict)
    {
		NSDictionary *frameDict = [framesDict objectForKey:frameDictKey];
		UIImage *spriteFrame = nil;

        BOOL isRotated = [[frameDict objectForKey:@"rotated"] boolValue];
        CGRect frame = CGRectFromString([frameDict objectForKey:@"frame"]);
        CGPoint frameOffset = CGPointFromString([frameDict objectForKey:@"offset"]);
        CGSize originalSize = CGSizeFromString([frameDict objectForKey:@"sourceSize"]);

        UIImage *spriteImage = [textureImage imageFromRect:frame rotated:isRotated offset:frameOffset originalSize:originalSize];

		// add sprite frame
		[_imageCache setObject:spriteImage forKey:frameDictKey];
        [_imageDataCache setObject:frameDict forKey:frameDictKey];
		[spriteFrame release];
	}
    [textureImage release];
}



- (UIImage *)imageWithName:(NSString *)imageName
{
    id image = [_imageCache objectForKey:imageName];
    if (image == nil)
    {
        NSLog(@"Image frame cannot be found: %@", imageName);
    }
    return image;
}


#else


- (void)addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureReference:(NSString *)textureFileName
{
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
    NSImage *textureImage = [[NSImage alloc] initWithContentsOfFile:textureFileName];

	// add real frames
	for(NSString *frameDictKey in framesDict)
    {
		NSDictionary *frameDict = [framesDict objectForKey:frameDictKey];
		NSImage *spriteFrame = nil;

        BOOL isRotated = [[frameDict objectForKey:@"rotated"] boolValue];
        CGRect frame = NSRectFromString([frameDict objectForKey:@"frame"]);
        CGPoint frameOffset = NSPointFromString([frameDict objectForKey:@"offset"]);
        CGSize originalSize = NSSizeFromString([frameDict objectForKey:@"sourceSize"]);

        NSImage *spriteImage = [textureImage imageFromRect:frame rotated:isRotated offset:frameOffset originalSize:originalSize];

		// add sprite frame
		[_imageCache setObject:spriteImage forKey:frameDictKey];
        [_imageDataCache setObject:frameDict forKey:frameDictKey];
		[spriteFrame release];
	}
    [textureImage release];
}


- (NSImage *)imageWithName:(NSString *)imageName
{
    id image = [_imageCache objectForKey:imageName];
    if (image == nil)
    {
        NSLog(@"Image frame cannot be found: %@", imageName);
    }
    return image;
}

#endif

@end
