//
//  MPWCGDrawingStream.m
//  MusselWind
//
//  Created by Marcel Weiher on 8.12.09.
//  Copyright 2009-2010 Marcel Weiher. All rights reserved.
//

#import "MPWCGDrawingContext.h"

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#import <Cocoa/Cocoa.h>
#endif

@protocol DrawingContextRealArray <NSObject>

-(float*)reals;
-(float)realAtIndex:(int)anIndex;

@end

@protocol DrawingContextUshortArray <NSObject>

-(unsigned short*)ushorts;
-(NSUInteger)count;

@end

@protocol ContextDrawing <NSObject>

-(void)drawOnContext:aContext;

@end


// #import <MPWFoundation/MPWFoundation.h>

@implementation MPWCGDrawingContext

scalarAccessor( CGContextRef , context ,_setContext )
idAccessor(currentFont, setCurrentFont)
floatAccessor(fontSize, _setFontSize)

-(void)setContext:(CGContextRef)newVar
{
    if ( newVar ) {
        CGContextRetain(newVar);
    }
    if ( context ) {
        CGContextRelease(context);
    }
    [self _setContext:newVar];
}

+(CGContextRef)currentCGContext
{
#if TARGET_OS_IPHONE
	return UIGraphicsGetCurrentContext();
#else
	return [[NSGraphicsContext currentContext] graphicsPort];
#endif
}

+contextWithCGContext:(CGContextRef)c
{
    return [[[self alloc] initWithCGContext:c] autorelease];
}

+currentContext
{
	return [self contextWithCGContext:[self currentCGContext]];
}


-initWithCGContext:(CGContextRef)newContext;
{
	self=[super init];
	[self setContext:newContext];
    [self resetTextMatrix]; 

	return self;
}

-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace
{
    CGContextRef c=CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorspace,   
                                         (CGColorSpaceGetNumberOfComponents(colorspace) == 4 ? kCGImageAlphaNone : kCGImageAlphaPremultipliedLast)  | kCGBitmapByteOrderDefault );
    id new = [self initWithCGContext:c];
    CGContextRelease(c);
    return new;

}

+rgbBitmapContext:(NSSize)size
{
    return [[[self alloc] initBitmapContextWithSize:size colorSpace:CGColorSpaceCreateDeviceRGB()] autorelease];
}

+cmykBitmapContext:(NSSize)size
{
    return [[[self alloc] initBitmapContextWithSize:size colorSpace:CGColorSpaceCreateDeviceCMYK()] autorelease];
}

-(CGImageRef)cgImage
{
    return CGBitmapContextCreateImage( context );
}

#if TARGET_OS_IPHONE   
#define IMAGECLASS  UIImage
#else
#define IMAGECLASS  NSBitmapImageRep
#endif



-(Class)imageClass
{
    return [IMAGECLASS class];
}

-image
{
    return [[[[self imageClass] alloc]  initWithCGImage:[self cgImage]] autorelease];
}


-(void)dealloc
{
    if ( context ) {
        CGContextRelease(context);
    }
	[super dealloc];
}

-translate:(float)x :(float)y {
	CGContextTranslateCTM(context, x, y);
	return self;
}

-scale:(float)x :(float)y {
	CGContextScaleCTM(context, x, y);
	return self;
}

-rotate:(float)degrees {
	CGContextRotateCTM(context, degrees * (M_PI/180.0));
	return self;
}

-beginPath
{
    CGContextBeginPath( context );
    return self;
}

-_gsave
{
	CGContextSaveGState(context);
	return self;
}

-(id<MPWDrawingContext>)gsave
{
    return [self _gsave];
}

-_grestore
{
	CGContextRestoreGState(context);
    return self;
}

-grestore
{
    [self _grestore];   
    [self setCurrentFont:nil];
    [self setFontSize:0];
	return self;
}

-(BOOL)object:inArray toCGFLoats:(CGFloat*)cgArray
{
    int arrayLength = [(NSArray*)inArray count];
    BOOL didConvert=YES;
    if ( [inArray respondsToSelector:@selector(reals)] ) {
        float *reals=[inArray reals];
        for (int i=0;i<arrayLength; i++) {
            cgArray[i]=reals[i];
        }
    } else if ( [inArray respondsToSelector:@selector(realAtIndex:)] ) {
        for (int i=0;i<arrayLength; i++) {
            cgArray[i]=[inArray realAtIndex:i];
        }
    } else if ( [inArray respondsToSelector:@selector(objectAtIndex:)] &&
               [[inArray objectAtIndex:0] respondsToSelector:@selector(floatValue)]) {
        for (int i=0;i<arrayLength; i++) {
            cgArray[i]=[[inArray objectAtIndex:i] floatValue];
        }
    } else {
        didConvert=NO;
    }
    return didConvert;
}

-setdashpattern:inArray phase:(float)phase
{
    if ( inArray ) {
        int arrayLength = [(NSArray*)inArray count];
        CGFloat cgArray[ arrayLength ];
        [self object:inArray toCGFLoats:cgArray];
        CGContextSetLineDash(context, phase, cgArray, arrayLength);
    } else {
        CGContextSetLineDash(context, 0.0, NULL, 0);
    }
	return self;
}

-setlinewidth:(float)width
{
	CGContextSetLineWidth(context, width);
	return self;
}

-color:(CGFloat*)components count:(int)numComponents
{
    CGColorSpaceRef colorSpace=NULL;
    switch (numComponents) {
        case 2:
            colorSpace=CGColorSpaceCreateDeviceGray();
            break;
        case 4:
            colorSpace=CGColorSpaceCreateDeviceRGB();
            break;
        case 5:
            colorSpace=CGColorSpaceCreateDeviceCMYK();
            break;
        default:
            break;
    }
    return [(id)CGColorCreate(colorSpace,components) autorelease];

}

-(id)colorRed:(float)r green:(float)g blue:(float)b alpha:(float)alpha
{
    CGFloat components[]={r,g,b,alpha};
    return [self color:components count:4];
}

-(id)colorCyan:(float)c magenta:(float)m yellow:(float)y black:(float)k alpha:(float)alpha
{
    CGFloat components[]={c,m,y,k,alpha};
    return [self color:components count:5];
}

-(id)colorGray:(float)gray alpha:(float)alpha
{
    CGFloat components[]={gray,alpha};
    return [self color:components count:2];
}

-colors:(NSArray*)arrayOfComponentArrays
{
    NSMutableArray *colorArray=[NSMutableArray array];
    int numColors=0;
    int numComponents=[arrayOfComponentArrays count];
    
    for ( id colorComponentArrayOrNumber in arrayOfComponentArrays ) {
        int thisCount = [colorComponentArrayOrNumber respondsToSelector:@selector(count)] ? [(NSArray*)colorComponentArrayOrNumber count]:1 ;
        numColors=MAX(numColors,thisCount);
    }
    for ( int i=0;i<numColors;i++){
        CGFloat components[5]={0,0,0,0,0};
        for (int componentIndex = 0;componentIndex < numComponents; componentIndex++ ) {
            id currentComponent=[arrayOfComponentArrays objectAtIndex:componentIndex];
            if ( [currentComponent respondsToSelector:@selector(count)] ) {
                int sourceIndex=MIN([(NSArray*)currentComponent count]-1,i);
                if ( [currentComponent respondsToSelector:@selector(realAtIndex:)] ) {
                    components[componentIndex]=[currentComponent realAtIndex:sourceIndex];
                } else {
                    components[componentIndex]=[[currentComponent objectAtIndex:sourceIndex] doubleValue];
                }
            } else {
                components[componentIndex]=[currentComponent doubleValue];
            }
        }
        [colorArray addObject:[self color:components count:numComponents]];
    }
    return colorArray;
}

-(NSArray*)colorsRed:red green:green blue:blue alpha:alpha
{
    return [self colors:[NSArray arrayWithObjects:red,green,blue,alpha, nil]];
}

-(NSArray*)colorsCyan:(id)c magenta:(id)m yellow:(id)y black:(id)k alpha:(id)alpha
{
    return [self colors:[NSArray arrayWithObjects:c,m,y,k,alpha, nil]];
}

-(NSArray*)colorsGray:gray alpha:alpha
{
    return [self colors:[NSArray arrayWithObjects:gray,alpha, nil]];
}

-setFillColor:aColor 
{
    CGContextSetFillColorWithColor( context, (CGColorRef)aColor );
	return self;
}

-setStrokeColor:aColor 
{
    CGContextSetStrokeColorWithColor( context, (CGColorRef)aColor );
	return self;
}

-setFillColorGray:(float)gray alpha:(float)alpha
{
    return [self setFillColor:[self colorGray:gray alpha:alpha]];
}


-setAlpha:(float)alpha
{
    CGContextSetAlpha( context, alpha );
    return self;
}


-setAntialias:(BOOL)doAntialiasing
{
    CGContextSetShouldAntialias( context, doAntialiasing );
    return self;
}

-setShadowOffset:(NSSize)offset blur:(float)blur color:aColor
{
    CGContextSetShadowWithColor( context, CGSizeMake(offset.width,offset.height),blur, (CGColorRef)aColor);
    return self;
}

-clearShadow
{
    return [self setShadowOffset:NSMakeSize(0, 0) blur:0 color:nil];
}


-nsrect:(NSRect)r
{
	CGContextAddRect( context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height) );
	return self;
}

-ellipseInRect:(NSRect)r
{
    CGContextAddEllipseInRect(context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height));
    return self;
}


-(void)fill
{
	CGContextFillPath( context );
}

-(void)fillAndStroke
{
	CGContextDrawPath( context, kCGPathFillStroke );
}


-(void)eofillAndStroke
{
	CGContextDrawPath( context, kCGPathEOFillStroke );
}


-(void)eofill
{
    CGContextEOFillPath( context );
}



-(void)fillDarken
{
    [self _gsave];
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    [self fill];
    [self _grestore];    
}

-(void)clip
{
	CGContextClip( context );
}

-(void)stroke
{
	CGContextStrokePath( context );
}

-(NSRect)cliprect
{
    CGRect r=CGContextGetClipBoundingBox(context);
    return NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height);
}

-(CGGradientRef)_gradientWithColors:(NSArray*)colors offset:(NSArray*)offsets
{
    CGColorRef firstColor = (CGColorRef)[colors objectAtIndex:0];
    CGColorSpaceRef colorSapce=CGColorGetColorSpace( firstColor);
    CGFloat locations[ [colors count] + 1 ];
    
    [self object:offsets toCGFLoats:locations];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSapce, (CFArrayRef)colors, locations );
    [(id)gradient autorelease];
    return gradient;
}

-drawLinearGradientFrom:(NSPoint)startPoint to:(NSPoint)endPoint colors:(NSArray*)colors offsets:(NSArray*)offsets
{
    CGContextDrawLinearGradient(context,
                                [self _gradientWithColors:colors offset:offsets],
                                CGPointMake(startPoint.x, startPoint.y),
                                CGPointMake(endPoint.x, endPoint.y),0);
                                
    
    return self;
}

-drawRadialGradientFrom:(NSPoint)startPoint radius:(float)startRadius to:(NSPoint)endPoint radius:(float)endRadius colors:(NSArray*)colors offsets:(NSArray*)offsets
{
    CGContextDrawRadialGradient(context,
                                [self _gradientWithColors:colors offset:offsets],
                                CGPointMake(startPoint.x, startPoint.y),
                                startRadius,
                                CGPointMake(endPoint.x, endPoint.y),
                                endRadius,0);
    
    return self;
}


-moveto:(float)x :(float)y
{
	CGContextMoveToPoint(context, x, y );	
	return self;
}

-lineto:(float)x :(float)y
{
	CGContextAddLineToPoint(context, x, y );	
	return self;
}

-curveto:(float)cp1x :(float)cp1y :(float)cp2x :(float)cp2y :(float)x :(float)y
{
    CGContextAddCurveToPoint( context, cp1x, cp1y, cp2x, cp2y, x,y );
    return self;
}


-arcWithCenter:(NSPoint)center radius:(float)radius startDegrees:(float)start endDegrees:(float)stop  clockwise:(BOOL)clockwise
{
	CGContextAddArc(context, center.x,center.y, radius , start * (M_PI/180), stop *(M_PI/180), clockwise);
	return self;
}

-arcFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 radius:(float)radius
{
    CGContextAddArcToPoint( context , p1.x, p1.y,p2.x, p2.y,  radius);
    return self;

}

-closepath;
{
	CGContextClosePath(context);
	return self;
}

-setCharaterSpacing:(float)ax
{
    //    NSLog(@"character spacing: %g",ax);
    CGContextSetCharacterSpacing( context, ax );
    return self;
}

-fontWithName:(NSString*)name size:(float)size
{
    return (id) CTFontCreateWithName ( (CFStringRef) name,(CGFloat) size, NULL );
}

-selectMacRomanFontName:(NSString*)fontname size:(float)newFontSize
{
    CGContextSelectFont( context,[fontname UTF8String], newFontSize, kCGEncodingMacRoman);
    return self;
}

-showTextString:str at:(NSPoint)position
{
    int len=[str length];
    char bytes[len+10];
    const char *byteptr=bytes;
    if ( [str respondsToSelector:@selector(bytes)] ) {
        byteptr=[(NSData*)str bytes];
    } else {
        [(NSString*)str getCString:bytes maxLength:len+1 encoding:NSMacOSRomanStringEncoding];
    }
//    NSLog(@"showTextStr: '%.*s' len=%d",len,byteptr,len);
    CGContextShowTextAtPoint( context, position.x, position.y, byteptr, len);
    return self;
}

-showGlyphBuffer:(unsigned short*)glyphs length:(int)len at:(NSPoint)position;
{
	CGContextShowGlyphsAtPoint( context, position.x,position.y, glyphs, len);
    return self;
}

-showGlyphs:(id <DrawingContextUshortArray> )glyphs at:(NSPoint)position;
{
	[self showGlyphBuffer:[glyphs ushorts] length:[glyphs count] at:position];
    return self;
}

-showGlyphBuffer:(unsigned short *)glyphs length:(int)len atPositions:(NSPoint*)positonArray
{
    CGContextShowGlyphsAtPositions(context,(CGGlyph*)glyphs , (CGPoint*)positonArray, len);
    return self;
}

-showGlyphs:(id)glyphArray atPositions:positionArray
{
    return self;
}



-setTextModeFill:(BOOL)fill stroke:(BOOL)stroke clip:(BOOL)clip
{
    CGTextDrawingMode modes[8]={
        kCGTextInvisible,
        kCGTextFill,
        kCGTextStroke,
        kCGTextFillStroke,
        kCGTextClip,
        kCGTextFillClip,
        kCGTextStrokeClip,
        kCGTextFillStrokeClip,
    };
    CGTextDrawingMode mode=modes[ (clip?4:0) + (stroke?2:0) + (fill?1:0)];
    CGContextSetTextDrawingMode(context, mode);
    return self;
}

-concat:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty
{
    CGContextConcatCTM(context, CGAffineTransformMake(m11,m12,m21,m22,tx,ty));
    return self;
}

-concat:someArray
{
    CGFloat a[6];
    NSAssert2( [someArray count] == 6, @"concat %@ expects 6-element array, got %d",someArray,(int)[someArray count] );
    [self object:someArray toCGFLoats:a];
    [self concat:a[0] :a[1] :a[2] :a[3] :a[4] :a[5]];
    return self;
}

-setTextMatrix:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty
{
    CGContextSetTextMatrix(context, CGAffineTransformMake(m11,m12,m21,m22,tx,ty));
    return self;
}

-setTextMatrix:someArray
{
    CGFloat a[6];
    NSAssert2( [someArray count] == 6, @"concat %@ expects 6-element array, got %d",someArray,(int)[someArray count] );
    [self object:someArray toCGFLoats:a];
    [self setTextMatrix:a[0] :a[1] :a[2] :a[3] :a[4] :a[5]];
    return self;
}


-setFontSize:(float)newSize;
{
	CGContextSetFontSize( context, newSize );
    return  self;
}

-(id <MPWDrawingContext>)setFont:aFont
{
    [self setCurrentFont:aFont];
    CGContextSetFont(context, (CGFontRef)aFont);
    return self;
}

#if !TARGET_OS_IPHONE
-concatNSAffineTransform:(NSAffineTransform*)transform
{
    if ( transform ) {
        NSAffineTransformStruct s=[transform transformStruct];
        [self concat:s.m11 :s.m12 :s.m21  :s.m22  :s.tX  :s.tY];
    }
    return self; 
}
#endif



-(id <MPWDrawingContext>)drawImage:(id)anImage
{
    CGImageRef cgImage=NULL;
    CGRect r;
    if ( [anImage respondsToSelector:@selector(CGImage)] ){
        IMAGECLASS *image=(IMAGECLASS*)anImage;
        NSSize s=[image size];
        CGRect sr={ CGPointZero, s.width, s.height };
        r=sr;
        cgImage=[anImage CGImage];
    }
    if ( cgImage) {
        CGContextDrawImage(context, r, [anImage CGImage]);
    } else if ( [anImage respondsToSelector:@selector(drawOnContext:) ] ) {
        [anImage drawOnContext:self];
    }
    return self;
}

-(void)resetTextMatrix
{
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
}

-(id <MPWDrawingContext>)setTextPosition:(NSPoint)p
{
    CGContextSetTextPosition(context, p.x,p.y);
    return self;
}

-(id <MPWDrawingContext>)drawTextLine:(CTLineRef)line
{
//    NSLog(@"draw text line: '%@'",(id)line);
    CTLineDraw(line, context);
    return self;
}

-(id <MPWDrawingContext>)show:(NSAttributedString*)someText 
{
    if ( [someText isKindOfClass:[NSString class]]) {
        NSMutableDictionary *attrs=[NSMutableDictionary dictionaryWithCapacity:4];
        if ( [self currentFont] ) {
            id  ctFont=[self currentFont];           // assumes current font is a CTFont/NSFont
            [attrs setObject:ctFont forKey:@"NSFont"];
            [attrs setObject:ctFont forKey:@"CTFont"];
        }
        [attrs setObject:[NSNumber numberWithBool:YES] forKey:(id)kCTForegroundColorFromContextAttributeName];
        someText=[[[NSAttributedString alloc] initWithString:(NSString*)someText attributes:attrs] autorelease];
    }
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef) someText);
    [self drawTextLine:line];
    CFRelease(line);
    return self;
}



@end


@implementation MPWCGDrawingContext(testing)

+testSelectors
{
    return [NSArray arrayWithObjects:
//            @"testColorCreation",
            nil];
}

@end
