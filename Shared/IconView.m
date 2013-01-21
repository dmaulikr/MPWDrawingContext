//
//  IconView.m
//  IconApp
//
//  Created by Matt Gallagher on 2011/01/28.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//
//  Modified to use MPWDrawingContext

#import "IconView.h"
#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
@interface NSShadow (SingleLineShadows)

+ (void)setShadowWithOffset:(NSSize)offset blurRadius:(CGFloat)radius color:(NSColor *)shadowColor;
+ (void)clearShadow;

@end


@implementation NSShadow (SingleLineShadows)

+ (void)setShadowWithOffset:(NSSize)offset blurRadius:(CGFloat)radius color:(NSColor *)shadowColor
{
	NSShadow *aShadow = [[[self alloc] init] autorelease];
	[aShadow setShadowOffset:offset];
	[aShadow setShadowBlurRadius:radius];
	[aShadow setShadowColor:shadowColor];
	[aShadow set];
}

+ (void)clearShadow
{
	NSShadow *aShadow = [[[self alloc] init] autorelease];
	[aShadow set];
}

@end

#endif


@implementation NSString(stringWithCharacter)


+(id)stringWithCharacter:(const unichar )character
{
    return [self stringWithCharacters:&character length:1];
}

@end



@implementation IconView

- (NSRect)nativeRect
{
	return NSMakeRect(0, 0, 512, 512);
}

#if 0
-(void)drawRect:(NSRect)rect onContext:(Drawable)context
{
    NSLog(@"drawRect:onContext:");
    [self drawMPWRect:[MPWRect rectWithNSRect:rect] onContext:context];
}
#endif

#if !TARGET_OS_IPHONE

-(void)drawRect_Cocoa:(NSRect)rect onContext:(Drawable)context
{
	NSSize nativeSize = [self nativeRect].size;
	NSSize boundsSize = [[NSGraphicsContext currentContext] isDrawingToScreen] ? self.bounds.size : [self nativeRect].size;
	CGFloat nativeAspect = nativeSize.width / nativeSize.height;
	CGFloat boundsAspect = boundsSize.width / boundsSize.height;
	CGFloat scale = nativeAspect > boundsAspect ?
    boundsSize.width / nativeSize.width :
    boundsSize.height / nativeSize.height;
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
    
	NSAffineTransform *transform = [[NSAffineTransform alloc] init];
	[transform translateXBy:0.5 * (boundsSize.width - scale * nativeSize.width) yBy:0.5 * (boundsSize.height - scale * nativeSize.height)];
	[transform scaleBy:scale];
	[transform set];
	
	NSRect ellipseRect = NSMakeRect(32, 38, 448, 448);
	
	[NSShadow setShadowWithOffset:NSMakeSize(0, -8 * scale) blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:0.75]];
	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
	[[NSBezierPath bezierPathWithOvalInRect:ellipseRect] fill];
	[NSShadow clearShadow];
    
	NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:ellipseRect];
	NSGradient *borderGradient =
    [[[NSGradient alloc]
      initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
      endingColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]]
     autorelease];
	[borderGradient drawInBezierPath:ellipse angle:-90];
	
	NSRect ellipseCenterRect = NSInsetRect(ellipseRect, 16, 16);
	[[NSColor blackColor] set];
	NSBezierPath *ellipseCenter = [NSBezierPath bezierPathWithOvalInRect:ellipseCenterRect];
	[ellipseCenter fill];
	
	[ellipseCenter setClip];
    
	NSGradient *bottomGlowGradient =
    [[[NSGradient alloc]
      initWithColorsAndLocations:
      [NSColor colorWithCalibratedRed:0 green:0.94 blue:0.82 alpha:1.0], 0.0,
      [NSColor colorWithCalibratedRed:0 green:0.62 blue:0.56 alpha:1.0], 0.35,
      [NSColor colorWithCalibratedRed:0 green:0.05 blue:0.35 alpha:1.0], 0.6,
      [NSColor colorWithCalibratedRed:0 green:0.0 blue:0.0 alpha:1.0], 0.7,
      nil]
     autorelease];
	[bottomGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, -0.2)];
    
	NSGradient *topGlowGradient =
    [[[NSGradient alloc]
      initWithColorsAndLocations:
      [NSColor colorWithCalibratedRed:0 green:0.68 blue:1.0 alpha:0.75], 0.0,
      [NSColor colorWithCalibratedRed:0 green:0.45 blue:0.62 alpha:0.55], 0.25,
      [NSColor colorWithCalibratedRed:0 green:0.45 blue:0.62 alpha:0.0], 0.40,
      nil]
     autorelease];
	[topGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, 0.4)];
    
	NSGradient *centerGlowGradient =
    [[[NSGradient alloc]
      initWithColorsAndLocations:
      [NSColor colorWithCalibratedRed:0 green:0.9 blue:0.9 alpha:0.9], 0.0,
      [NSColor colorWithCalibratedRed:0 green:0.49 blue:1.0 alpha:0.0], 0.85,
      nil]
     autorelease];
	[centerGlowGradient drawInRect:ellipseCenterRect relativeCenterPosition:NSMakePoint(0, 0)];
    
	NSFont *arialUnicode =
    [[NSFontManager sharedFontManager]
     fontWithFamily:@"Arial Unicode MS"
     traits:0
     weight:5
     size:345];
    
	// Getting the glyph using AppKit's NSLayoutManager
	NSString *floralHeart = @"\u2766";
	NSRange stringRange = NSMakeRange(0, [floralHeart length]);
	NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
	NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:floralHeart] autorelease];
	[textStorage addAttribute:NSFontAttributeName value:arialUnicode range:stringRange];
	[textStorage fixAttributesInRange:stringRange];
	[textStorage addLayoutManager:layoutManager];
	NSInteger numGlyphs = [layoutManager numberOfGlyphs];
	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
	[layoutManager getGlyphs:glyphs range:NSMakeRange(0, numGlyphs)];
	[textStorage removeLayoutManager:layoutManager];
    
    //	// Get the glyph using CTFont instead
    //	NSInteger numGlyphs = 1;
    //	NSGlyph *glyphs = (NSGlyph *)malloc(sizeof(NSGlyph) * (numGlyphs + 1)); // includes space for NULL terminator
    //	CTFontGetGlyphsForCharacters((CTFontRef)arialUnicode, (const UniChar *)L"\u2766", (CGGlyph *)glyphs, numGlyphs);
	
	NSBezierPath *floralHeartPath = [[[NSBezierPath alloc] init] autorelease];
	[floralHeartPath moveToPoint:NSMakePoint(130, 140)];
	[floralHeartPath appendBezierPathWithGlyphs:glyphs count:numGlyphs inFont:arialUnicode];
	free(glyphs);
    
	[NSShadow setShadowWithOffset:NSZeroSize blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:1.0]];
	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];
	[floralHeartPath fill];
	[borderGradient drawInBezierPath:floralHeartPath angle:-90];
	[NSShadow clearShadow];
    
	const CGFloat glossInset = 8;
	CGFloat glossRadius = (ellipseCenterRect.size.width * 0.5) - glossInset;
	NSPoint center = NSMakePoint(NSMidX(ellipseRect), NSMidY(ellipseRect));
    
	double arcFraction = 0.02;
	NSPoint arcStartPoint = NSMakePoint(
                                        center.x - glossRadius * cos(arcFraction * M_PI),
                                        center.y + glossRadius * sin(arcFraction * M_PI));
	NSPoint arcEndPoint = NSMakePoint(
                                      center.x + glossRadius * cos(arcFraction * M_PI),
                                      center.y + glossRadius * sin(arcFraction * M_PI));
    
	NSBezierPath *glossPath = [[[NSBezierPath alloc] init] autorelease];
	[glossPath moveToPoint:arcStartPoint];
	[glossPath
     appendBezierPathWithArcWithCenter:center
     radius:glossRadius
     startAngle:arcFraction * 180
     endAngle:(1.0 - arcFraction) * 180];
    
	const CGFloat bottomArcBulgeDistance = 70;
	const CGFloat bottomArcRadius = 2.6;
	[glossPath moveToPoint:arcEndPoint];
	[glossPath
     appendBezierPathWithArcFromPoint:
     NSMakePoint(center.x, center.y - bottomArcBulgeDistance)
     toPoint:arcStartPoint
     radius:glossRadius * bottomArcRadius];
	[glossPath lineToPoint:arcStartPoint];
    
	NSGradient *glossGradient =
    [[[NSGradient alloc]
      initWithColorsAndLocations:
      [NSColor colorWithCalibratedWhite:1 alpha:0.85], 0.0,
      [NSColor colorWithCalibratedWhite:1 alpha:0.5], 0.5,
      [NSColor colorWithCalibratedWhite:1 alpha:0.05], 1.0,
      nil]
     autorelease];
	[glossGradient drawInBezierPath:glossPath angle:-90];
    
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

#endif

-(void)drawRect:(NSRect)rect onContext:(Drawable)context
{
	NSSize nativeSize = [self nativeRect].size;
	NSSize boundsSize = /* [context isDrawingToScreen] */ YES ? self.bounds.size : [self nativeRect].size;
	CGFloat nativeAspect = nativeSize.width / nativeSize.height;
	CGFloat boundsAspect = boundsSize.width / boundsSize.height;
	CGFloat scale = nativeAspect > boundsAspect ?
    boundsSize.width / nativeSize.width :
    boundsSize.height / nativeSize.height;
	
    [context gsave];
    [[context translate:0.5 * (boundsSize.width - scale * nativeSize.width) :0.5 * (boundsSize.height - scale * nativeSize.height)] scale:@(scale)];

	NSRect ellipseRect = NSMakeRect(32, 38, 448, 448);
    [context withShadowOffset:NSMakeSize(0, -8 * scale) blur:12 * scale  color:[context  colorGray:0 alpha: 0.75] draw:^(Drawable c ){
        [[[c setFillColorGray:0.9 alpha:1.0] ellipseInRect:ellipseRect] fill];
    }];
    [[context ellipseInRect:ellipseRect] clip];
    
    [context drawLinearGradientFrom:ellipseRect.origin
                                 to:NSMakePoint(ellipseRect.origin.x, ellipseRect.origin.y+ellipseRect.size.height)
                             colors:[context colorsGray:@[ @1 , @0.85 ] alpha:@1.0 ]
                            offsets:@[ @1.0, @0.0 ]  ];
    
	NSRect ellipseCenterRect = NSInsetRect(ellipseRect, 16, 16);
    [context setFillColorGray:0.0 alpha:1.0];
    [[context ellipseInRect:ellipseCenterRect] fill];
    [[context ellipseInRect:ellipseCenterRect] clip];
    
    NSPoint centerPoint = NSMakePoint( NSMidX(ellipseCenterRect), NSMidY(ellipseCenterRect) - ellipseCenterRect.size.height*0.2);
    float radius=0.8 * ellipseCenterRect.size.height;
    
    NSArray *colors = [context colorsRed:@0 green:@[ @0.94, @0.62, @0.05, @0.0 ] blue:@[ @0.82, @0.56, @0.35, @0.0] alpha:@1.0];
	[context drawRadialGradientFrom:centerPoint
                             radius:0.0
                                 to:centerPoint
                             radius:radius
                             colors:colors
                            offsets:@[ @0.0, @0.35, @0.6, @0.7 ]];
    centerPoint = NSMakePoint( NSMidX(ellipseCenterRect), NSMidY(ellipseCenterRect) + ellipseCenterRect.size.height*0.4);
    colors = [context colorsRed:@0 green:@[ @0.68, @0.45 ] blue:@[ @1.0, @0.62] alpha:@[ @0.75, @0.55, @0.0] ];
	[context drawRadialGradientFrom:centerPoint
                             radius:0.0
                                 to:centerPoint
                             radius:radius
                             colors:colors
                            offsets:@[ @0.0, @0.25, @0.4 ]];
    centerPoint = NSMakePoint( NSMidX(ellipseCenterRect), NSMidY(ellipseCenterRect));
    colors = [context colorsRed:@0 green:@[ @0.9, @0.49 ] blue:@[ @0.9, @1.0] alpha:@[ @0.9, @0.0] ];
    [context drawRadialGradientFrom:centerPoint
                             radius:0.0
                                 to:centerPoint
                             radius:radius
                             colors:colors
                            offsets:@[ @0.0, @0.85 ]];

    [context withShadowOffset:NSMakeSize(0, 0) blur:12 * scale  color:[context  colorGray:0 alpha: 1.0] draw:^(Drawable c ){
            [context ingsave:^(Drawable c ){
                [c translate:@[ @130 ,@140]];
                [c setFont:[context fontWithName:@"ArialMT" size:345]];
                [c setFillColorGray:0.9 alpha:1.0];
                [c setTextPosition:NSMakePoint(0, 0)];
                [c show:@"\u2766"];
    }];
    }];
    
	const CGFloat glossInset = 8;
	CGFloat glossRadius = (ellipseCenterRect.size.width * 0.5) - glossInset;
	NSPoint center = NSMakePoint(NSMidX(ellipseRect), NSMidY(ellipseRect));
    double bottomArcRadius = 2.6;
    double bottomRadius = glossRadius * bottomArcRadius;
	double arcFraction = 0.02 ;
    NSPoint arcStart = center;
    arcStart.y -= 70;
	NSPoint arcStartPoint = NSMakePoint( center.x - glossRadius * cos(arcFraction * M_PI),
                                        center.y + glossRadius * sin(arcFraction * M_PI));
	NSPoint arcEndPoint = NSMakePoint( center.x + glossRadius * cos(arcFraction * M_PI),
                                      center.y + glossRadius * sin(arcFraction * M_PI));
    float startAngle=arcFraction * 180;
    float endAngle=180-startAngle;
    
    [context moveto:arcStartPoint.x :arcStartPoint.y];

    [context arcWithCenter:center radius:glossRadius startDegrees:startAngle endDegrees:endAngle clockwise:NO];
    [context moveto:arcEndPoint.x :arcEndPoint.y];
    [context arcFromPoint:arcStart toPoint:arcStartPoint radius:bottomRadius];
    [context lineto:arcStartPoint.x :arcStartPoint.y];
    [context clip];
    colors = [context colorsGray:@1 alpha:@[ @0.55, @0.25, @0.05 ]];
    NSPoint gradientStart = NSMakePoint(center.x, center.y - glossRadius);
    NSPoint endPoint = NSMakePoint(center.x, center.y + glossRadius);
    [context drawLinearGradientFrom:gradientStart to:endPoint colors:colors offsets:@[ @0, @0.5, @1.0]];
    [context grestore];
}

@end
