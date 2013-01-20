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

#if TARGET_OS_IPHONE   
#define IMAGECLASS  UIImage
#else
#define IMAGECLASS  NSBitmapImageRep
#endif

@protocol DrawingContextRealArray <NSObject>

-(void)getReals:(float*)reals length:(int)arrayLength;
-(float)realAtIndex:(int)anIndex;

@end



@protocol DrawingContextUshortArray <NSObject>

-(unsigned short*)ushorts;
-(NSUInteger)count;

@end
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

-beginTransparencyLayer
{
    CGContextBeginTransparencyLayer( context, (CFDictionaryRef)[NSDictionary dictionary]);
    return self;
}


-endTransparencyLayer
{
    CGContextEndTransparencyLayer( context );
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


-(BOOL)object:inArray toCGFLoats:(CGFloat*)cgArray maxCount:(int)maxCount
{
    int arrayLength = [(NSArray*)inArray count];
    arrayLength=MIN(arrayLength,maxCount);
    float floatArray[arrayLength];
    BOOL didConvert = [self object:inArray toFloats:(float *)floatArray maxCount:arrayLength];
    if ( didConvert ) {
        for (int i=0;i<arrayLength;i++) {
            cgArray[i]=floatArray[i];
        }
    }
    return didConvert;
}



-setdashpattern:inArray phase:(float)phase
{
    if ( inArray ) {
        int arrayLength = [(NSArray*)inArray count];
        CGFloat cgArray[ arrayLength ];
        [self object:inArray toCGFLoats:cgArray maxCount:arrayLength];
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


-setlinecapRound
{
    CGContextSetLineCap(context, kCGLineCapRound);
    return self;
}

-setlinecapSquare
{
    CGContextSetLineCap(context, kCGLineCapSquare);
    return self;
}

-setlinecapButt
{
    CGContextSetLineCap(context, kCGLineCapButt );
    return self;
}

static inline CGColorRef asCGColorRef( id aColor ) {
    CGColorRef cgColor=(CGColorRef)aColor;
    if ( [aColor respondsToSelector:@selector(CGColor)])  {
        cgColor=[aColor CGColor];
    }
    return cgColor;
}

-setFillColor:aColor 
{
    CGContextSetFillColorWithColor( context, asCGColorRef(aColor) );
	return self;
}

-setStrokeColor:aColor 
{
    CGContextSetStrokeColorWithColor( context,  asCGColorRef(aColor) );
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

-(void)fillRect:(NSRect)r;
{
	CGContextFillRect(context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height) );
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
    
    [self object:offsets toCGFLoats:locations maxCount:[colors count]];
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
    CGContextSetCharacterSpacing( context, ax );
    return self;
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

-layerWithSize:(NSSize)size
{
    return [[[MPWCGLayerContext alloc] initWithCGContext:[self context] size:size] autorelease];
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

-setTextMatrix:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty
{
    CGContextSetTextMatrix(context, CGAffineTransformMake(m11,m12,m21,m22,tx,ty));
    return self;
}

-setTextMatrix:someArray
{
    CGFloat a[6];
    NSAssert2( [someArray count] == 6, @"concat %@ expects 6-element array, got %d",someArray,(int)[someArray count] );
    [self object:someArray toCGFLoats:a maxCount:6];
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

-(void)drawBitmapImage:anImage
{
    IMAGECLASS *image=(IMAGECLASS*)anImage;
    NSSize s=[image size];
    CGRect r={ CGPointZero, s.width, s.height };
    CGContextDrawImage(context, r, [anImage CGImage]);
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

#if NS_BLOCKS_AVAILABLE

-layerWithSize:(NSSize)size content:(DrawingBlock)block
{
    MPWCGLayerContext *layerContext=[self layerWithSize:size];
    block( layerContext);
    return layerContext;
}

-bitmapWithSize:(NSSize)size content:(DrawingBlock)block
{
    MPWCGBitmapContext *bitmapContext=[MPWCGBitmapContext rgbBitmapContext:size];
    block( bitmapContext);
    return [bitmapContext image];
}
#endif

@end

@implementation MPWCGLayerContext

-(id)initWithCGContext:(CGContextRef)baseContext size:(NSSize)s
{
    CGSize cgsize={s.width,s.height};
    CGLayerRef newlayer=CGLayerCreateWithContext(baseContext, cgsize,  NULL);
    CGContextRef layerContext=CGLayerGetContext(newlayer);
    if ( (self=[super initWithCGContext:layerContext])) {
        layer=newlayer;
    }
    return self;
}

-(void)drawOnContext:(MPWCGDrawingContext*)aContext
{
    CGContextDrawLayerAtPoint([aContext context],  CGPointMake(0, 0),layer);
}

-(void)dealloc
{
    if ( layer) {
        CGLayerRelease(layer);
    }
    [super dealloc];    
}

@end

@implementation MPWCGPDFContext


+pdfContextWithTarget:target mediaBox:(NSRect)bbox
{
    CGRect mediaBox={bbox.origin.x,bbox.origin.y,bbox.size.width,bbox.size.height};
    CGContextRef newContext = CGPDFContextCreate(CGDataConsumerCreateWithCFData((CFMutableDataRef)target), &mediaBox, NULL );
    return [self contextWithCGContext:newContext];
}

+pdfContextWithTarget:target size:(NSSize)pageSize
{
    return [self pdfContextWithTarget:target mediaBox:NSMakeRect(0, 0, pageSize.width, pageSize.height)];
}

+pdfContextWithTarget:target
{
    return [self pdfContextWithTarget:target size:NSMakeSize( 595, 842)];
}


-(void)beginPage:(NSDictionary*)parameters
{
    CGPDFContextBeginPage( context , (CFDictionaryRef)parameters);
}

-(void)endPage
{
    CGPDFContextEndPage( context );
}

-(void)close
{
    CGPDFContextClose( context );
}


-page:(NSDictionary*)parameters content:(DrawingBlock)drawingCommands
{
    @try {
        [self beginPage:parameters];
        drawingCommands(self);
    } @finally {
        [self endPage];
    }
    return self;
}


-laterWithSize:(NSSize)size content:(DrawingBlock)drawingCommands
{
    return [self layerWithSize:size content:drawingCommands];
}


@end


#if NS_BLOCKS_AVAILABLE

@implementation MPWDrawingCommands(patterns)


void ColoredPatternCallback(void *info, CGContextRef context)
{
    MPWDrawingCommands *command=(MPWDrawingCommands*)info;
    [command drawOnContext:[MPWCGDrawingContext contextWithCGContext:context]];
}

-(CGColorRef)CGColor
{
    CGPatternCallbacks coloredPatternCallbacks = {0, ColoredPatternCallback, NULL};
    CGPatternRef pattern=CGPatternCreate(self, CGRectMake(0, 0, size.width, size.height), CGAffineTransformIdentity, size.width, size.height, kCGPatternTilingNoDistortion, true , &coloredPatternCallbacks) ;
    CGColorSpaceRef coloredPatternColorSpace = CGColorSpaceCreatePattern(NULL);
    CGFloat alpha = 1.0;
    
    CGColorRef coloredPatternColor = CGColorCreateWithPattern(coloredPatternColorSpace, pattern, &alpha);
    CGPatternRelease(pattern);
    CGColorSpaceRelease(coloredPatternColorSpace);
    [(id)coloredPatternColor autorelease];
    return coloredPatternColor;
}

@end

#endif



@implementation MPWCGBitmapContext

-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace
{
    CGContextRef c=CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorspace,   
                                         (CGColorSpaceGetNumberOfComponents(colorspace) == 4 ? kCGImageAlphaNone : kCGImageAlphaPremultipliedLast)  | kCGBitmapByteOrderDefault );
    if ( !c ) {
        [self dealloc];
        return nil;
    }
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



-(Class)imageClass
{
    return [IMAGECLASS class];
}

-image
{
    CGImageRef cgImage=[self cgImage];
    id image= [[[[self imageClass] alloc]  initWithCGImage:cgImage] autorelease];
    CGImageRelease(cgImage);
    return image;
}



@end

#if TARGET_OS_IPHONE
@implementation UIImage(CGColor)

-(CGColorRef)CGColor
{
    return [[UIColor colorWithPatternImage:self] CGColor];
}
@end

#elif TARGET_OS_MAC

@implementation NSImage(CGColor)

-(CGColorRef)CGColor {   return [[NSColor colorWithPatternImage:self] CGColor]; };
@end

@implementation NSBitmapImageRep(CGColor)

-(CGColorRef)CGColor
{
    return [[[[NSImage alloc] initWithCGImage:[self CGImage] size:[self size]] autorelease] CGColor];
}
@end
#endif

#if 0
#if !TARGET_OS_IPHONE

#import "EGOSTesting.h"


@implementation MPWCGBitmapContext(testing)



+(NSBitmapImageRep*)bitmapForImageNamed:(NSString*)name
{
    NSString *path=[[NSBundle bundleForClass:self] pathForImageResource:name];
    return [NSBitmapImageRep imageRepWithContentsOfFile:path];
}

+(void)testBasicShapesGetRendered
{
    MPWCGBitmapContext *c=[self rgbBitmapContext:NSMakeSize(400, 400)];
    SEL ops[3]={ @selector(fill),@selector(stroke),@selector(fillAndStroke)};
    
    [c setFillColor:[c colorRed:0 green:1 blue:0 alpha:1]];
    [c setStrokeColor:[c colorRed:1 green:0 blue:0 alpha:1]];
    [c setlinewidth:4];
    NSRect r=NSMakeRect(5, 5, 30, 20);

    for (int i=0;i<3;i++) {
        [c gsave];
        [c nsrect:r];
        [c performSelector:ops[i]];
        [c translate:35 :0];
        [c ellipseInRect:r];
        [c performSelector:ops[i]];
        [c grestore];
        [c translate:0 :40];
    }    
    IMAGEEXPECT( [c image], BUNDLEIMAGE(@"context-render-test1"), @"basic-shape-rendering");    
}


+(void)testSimpleColorCreation
{
    MPWCGDrawingContext *c=[self rgbBitmapContext:NSMakeSize(500,500)];
    struct color  {
        float r,g,b;
    } colors[] = {
        {1,0,0},
        {0,1,0},
        {0,0,1},
        {1,1,0},
        {1,0,1},
        {0,1,1},
        {1,1,1}
    };
    for (int i=0;i<7;i++) {
        id c1=[c colorRed:colors[i].r green:colors[i].g blue:colors[i].b alpha:1];
        [[[c setFillColor:c1] nsrect:NSMakeRect(0, 0, 10, 100)] fill ];
        [c translate:10 :0];
    }
    IMAGEEXPECT( [c image], BUNDLEIMAGE(@"simple-color-creation"), @"simple-color-creation");
}

+testSelectors
{
    return @[
        @"testBasicShapesGetRendered",
        @"testSimpleColorCreation"
    ];
}

@end

#endif

@implementation MPWCGPDFContext(testing)

+testSelectors {  return @[]; }

@end
#endif