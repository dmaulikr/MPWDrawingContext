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

#import "IconView.h"
#import <MPWFoundation/MPWFoundation.h>

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

@implementation IconView

- (NSRect)nativeRect
{
	return NSMakeRect(0, 0, 512, 512);
}


-(void)drawRect:(NSRect)rect onContext:(id <MPWDrawingContext>)context
{
    [self drawMPWRect:[MPWRect rectWithNSRect:rect] onContext:context];
}

-(void)drawRect1:(NSRect)rect onContext:(id <MPWDrawingContext>)context
{
	NSSize nativeSize = [self nativeRect].size;
	NSSize boundsSize = [[NSGraphicsContext currentContext] isDrawingToScreen] ? self.bounds.size : [self nativeRect].size;
	CGFloat nativeAspect = nativeSize.width / nativeSize.height;
	CGFloat boundsAspect = boundsSize.width / boundsSize.height;
	CGFloat scale = nativeAspect > boundsAspect ?
		boundsSize.width / nativeSize.width :
		boundsSize.height / nativeSize.height;

	[context gsave];
    [[context translate:0.5 * (boundsSize.width - scale * nativeSize.width) :0.5 * (boundsSize.height - scale * nativeSize.height)] 
     scale:scale :scale];
    
	
	NSRect ellipseRect = NSMakeRect(32, 38, 448, 448);
	
	[NSShadow setShadowWithOffset:NSMakeSize(0, -8 * scale) blurRadius:12 * scale color:[NSColor colorWithCalibratedWhite:0 alpha:0.75]];
    [context setFillColorGray:0.9 alpha:1.0];
    
//	[[NSColor colorWithCalibratedWhite:0.9 alpha:1.0] set];

	[[context ellipseInRect:ellipseRect] fill];

	[NSShadow clearShadow];

//	NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:ellipseRect];

    [[context ellipseInRect:ellipseRect] clip];
	NSPoint endPoint = NSMakePoint(ellipseRect.origin.x, ellipseRect.origin.y + ellipseRect.size.height);

    [context drawLinearGradientFrom:ellipseRect.origin
                                 to:endPoint
                             colors:[NSArray arrayWithObjects:
                                     [context colorGray:1.0 alpha:1.0],
                                     [context colorGray:0.82 alpha:1.0],
                                     nil]
                            offsets:[MPWRealArray arrayWithReals:(float[]){1.0,0.0} count:2]];

    
    NSGradient *borderGradient =
		[[[NSGradient alloc]
			initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
			endingColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]]
		autorelease];

//	[borderGradient drawInBezierPath:ellipse angle:-90];

	NSRect ellipseCenterRect = NSInsetRect(ellipseRect, 16, 16);

	
	[[[context setFillColorGray:0.0 alpha:1.0] ellipseInRect:ellipseCenterRect] fill];

    [[context ellipseInRect:ellipseCenterRect] clip];

    NSPoint centerPoint = NSMakePoint( NSMidX( ellipseCenterRect ), NSMidY(ellipseCenterRect) - 0.1 * ellipseCenterRect.size.height);

    // bottom glow gradient 
    [context drawRadialGradientFrom:centerPoint radius:0.0
                                 to:centerPoint radius:0.8 * ellipseCenterRect.size.height 
                             colors:[NSArray arrayWithObjects:
                                     [context colorRed:0 green:0.94 blue:0.82 alpha:1.0],
                                     [context colorRed:0 green:0.62 blue:0.56 alpha:1.0],
                                     [context colorRed:0 green:0.05 blue:0.35 alpha:1.0],
                                     [context colorRed:0 green:0.0 blue:0.0 alpha:1.0],

                                     nil]
                            offsets: [MPWRealArray arrayWithReals:(float[]){0.0,0.35,0.6,0.7} count:4]];

    centerPoint = NSMakePoint( NSMidX( ellipseCenterRect ), NSMidY(ellipseCenterRect) + 0.4 * ellipseCenterRect.size.height);
    [context drawRadialGradientFrom:centerPoint radius:0.0
                                 to:centerPoint radius:0.8 * ellipseCenterRect.size.height 
                             colors:[NSArray arrayWithObjects:
                                     [context colorRed:0 green:0.68 blue:1.0 alpha:0.75],
                                     [context colorRed:0 green:0.45 blue:0.62 alpha:0.55],
                                     [context colorRed:0 green:0.45 blue:0.62 alpha:0.0],
                                     
                                     nil]
                            offsets:[MPWRealArray arrayWithReals:(float[]){0.0,0.25,0.4} count:3]];
 
 
    centerPoint = NSMakePoint( NSMidX( ellipseCenterRect ), NSMidY(ellipseCenterRect) );
    [context drawRadialGradientFrom:centerPoint radius:0.0
                                 to:centerPoint radius:0.8 * ellipseCenterRect.size.height 
                             colors:[NSArray arrayWithObjects:
                                     [context colorRed:0 green:0.9 blue:0.9 alpha:0.9],
                                     [context colorRed:0 green:0.49 blue:1.0 alpha:0.0],                                     
                                     nil]
                            offsets:[NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0],
                                     [NSNumber numberWithFloat:0.85],
                                     nil ]];
#if 1    
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
#else
    [[context setTextPosition:NSMakePoint(0, 0)] setFillColor:[context colorGray:0.9 alpha:1.0]];
    [[[NSFontManager sharedFontManager]
     fontWithFamily:@"Arial Unicode MS"
     traits:0
     weight:5
     size:45] set];

//    [context selectMacRomanFontName:@"Arial Unicode MS" size:345];
    [context show:@"\u2766"];
//    [context show:@"&"];

#endif
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
#if 0   
    [glossPath setClip];
    NSRect glossRect =ellipseCenterRect;
    glossRect.size.height *= 0.5;
    [glossGradient drawInRect:glossRect angle:-90];
#else
	[glossGradient drawInBezierPath:glossPath angle:-90];
#endif
    [context grestore];
}

@end
