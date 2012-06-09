//
//  MPWView.m
//  MusselWind
//
//  Created by Marcel Weiher on 11/19/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//


#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import "MPWView_iOS.h"
#else
#import "MPWView.h"
#endif
//#import <EGOS_Cocoa/MPWCGDrawingContext.h>
#import "MPWCGDrawingContext.h"

@implementation MPWView


-(void)drawOnContext:(id <MPWDrawingContext>)context
{
	// do nothing
}


-(void)drawRect:(NSRect)rect onContext:(id <MPWDrawingContext>)context
{
	[self drawOnContext:context];
}

-(void)drawLayer:(CALayer*)layer inDrawingContext:(id <MPWDrawingContext>)context
{
	// do nothing
}

-(BOOL)logDrawRect
{
    return NO;
}

-(void)drawRect:(NSRect)rect
{
    if ([self logDrawRect] ) {
        NSLog(@"-[%@ drawRect:%@]",[self class],NSStringFromRect(rect));
    }
	MPWCGDrawingContext* context = [MPWCGDrawingContext currentContext];
#if TARGET_OS_IPHONE
	[context translate:0  :[self bounds].size.height];
	[[context scale:1  :-1] setlinewidth:1];
#endif
	[self drawRect:rect onContext:context];
}



-(void)drawLayer1:(CALayer*)layer inContext:(CGContextRef)cgContext
{
	MPWCGDrawingContext *context = [MPWCGDrawingContext contextWithCGContext:cgContext];
#if TARGET_OS_IPHONE
	[context translate:0  :[self bounds].size.height];
	[[context scale:1  :-1] setlinewidth:1];
#endif
    [self drawLayer:layer inDrawingContext:context];
}

@end
