//
//  MPWCGDrawingStream.h
//  MusselWind
//
//  Created by Marcel Weiher on 8.12.09.
//  Copyright 2009-2010 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzGeometry.h"
#import "MPWDrawingContext.h"

//#import <MPWFoundation/AccessorMacros.h>
#import "AccessorMacros.h"



@interface MPWCGDrawingContext: NSObject <MPWDrawingContext> {
	CGContextRef context;
    id currentFont;
    float fontSize;
}

scalarAccessor_h( CGContextRef, context, setContext )
-initWithCGContext:(CGContextRef)newContext;
-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace;

+rgbBitmapContext:(NSSize)size;
+cmykBitmapContext:(NSSize)size;
+contextWithCGContext:(CGContextRef)c;
+currentContext;

-(void)resetTextMatrix;

-image;

#if !TARGET_OS_IPHONE
-concatNSAffineTransform:(NSAffineTransform*)transform;
#endif

@end
