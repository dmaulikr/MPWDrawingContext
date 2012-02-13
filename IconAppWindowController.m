//
//  IconAppWindowController.m
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

#import "IconAppWindowController.h"
#import "IconView.h"

@implementation IconAppWindowController

- (void)windowDidLoad
{
}

- (NSString *)windowNibName
{
	return @"IconAppWindow";
}

- (IBAction)exportToPDF:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];

	[NSApp
		beginSheet:savePanel
		modalForWindow:[self window]
		modalDelegate:nil
		didEndSelector:nil
		contextInfo:nil];
	int result = [savePanel runModal];
	[NSApp endSheet:savePanel];
	
	if (result == NSFileHandlingPanelOKButton)
	{
		[[iconView dataWithPDFInsideRect:[iconView nativeRect]]
			writeToURL:[savePanel URL]
			atomically:YES];
	}
}

-(void)didDefineMethods:server
{
    [iconView setNeedsDisplay:YES];
}

- (IBAction)exportToPNG:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"png"]];

	[NSApp
		beginSheet:savePanel
		modalForWindow:[self window]
		modalDelegate:nil
		didEndSelector:nil
		contextInfo:nil];
	int result = [savePanel runModal];
	[NSApp endSheet:savePanel];
	
	if (result == NSFileHandlingPanelOKButton)
	{
		NSRect iconViewFrame = iconView.frame;
		[iconView setFrame:[iconView nativeRect]];
		
		NSBitmapImageRep *bitmapImageRep =
			[iconView bitmapImageRepForCachingDisplayInRect:[iconView frame]];
		[iconView
			cacheDisplayInRect:[iconView bounds]
			toBitmapImageRep:bitmapImageRep];
		[[bitmapImageRep representationUsingType:NSPNGFileType properties:nil]
			writeToURL:[savePanel URL]
			atomically:YES];
		
		[iconView setFrame:iconViewFrame];
	}
}

@end
