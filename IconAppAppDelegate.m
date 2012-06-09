//
//  IconAppAppDelegate.m
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
//  This file has been modified by Marcel Weiher to demonstrate use of MPWDrawingContext
//


#import "IconAppAppDelegate.h"
#import "IconAppWindowController.h"
//#import <MethodServer/MethodServer.h>
#import "AccessorMacros.h"


@implementation IconAppAppDelegate

objectAccessor(MethodServer, methodServer, setMethodServer)

-(void)createMethodServer
{
    [self setMethodServer:[[[NSClassFromString(@"MethodServer") alloc] initWithMethodDictName:@"iconapp"] autorelease]];
    [[self methodServer] setup];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    [self createMethodServer];
	windowController = [[IconAppWindowController alloc] init];
	[[windowController window] makeKeyAndOrderFront:self];
    [[self methodServer] setDelegate:windowController];
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[windowController release];
	[super dealloc];
}


@end
