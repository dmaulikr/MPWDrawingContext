//
//  MPWAbstractCGContext.h
//  EGOS
//
//  Created by Marcel Weiher on 1/2/13.
//
//

#import <Foundation/Foundation.h>
#import "MPWDrawingContext.h"

@interface MPWAbstractCGContext : NSObject 

-(int)object:inArray toFloats:(float *)floatArray maxCount:(int)maxCount;

@end


@protocol ContextDrawing <NSObject>

-(void)drawOnContext:aContext;

@end



#if NS_BLOCKS_AVAILABLE

@interface MPWDrawingCommands : NSObject <ContextDrawing>
{
    DrawingBlock block;
    NSSize size;
}

-initWithBlock:(DrawingBlock)aBlock;
-(void)setSize:(NSSize)newSize;


@end
#endif
