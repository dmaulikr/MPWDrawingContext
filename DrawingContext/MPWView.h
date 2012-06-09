//
//  MPWView.h
//  MusselWind
//
//  Created by Marcel Weiher on 11/19/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

//#import <EGOS/MPWDrawingContext.h>
#import "MPWDrawingContext.h"



@interface MPWView : NSView {
//	id <MPWDrawingContext> context;
}

-(void)drawRect:(NSRect)rect onContext:(id <MPWDrawingContext>)context;



@end
