//
//  PZApplicationDelegate.m
//  PzzApp
//
//  Created by Ana Cañizares on 01.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import "PZApplicationDelegate.h"
#import "PZAboutWindowController.h"
#import "PZPreferencesWindowController.h"


@implementation PZApplicationDelegate

+ (void)initialize {
	NSString *imagePath = [[[NSBundle mainBundle] URLForResource:@"Frog" 
																								 withExtension:@"jpeg"] absoluteString];
	[NSColor setIgnoresAlpha:NO];
	NSColor *transpColor= [NSColor colorWithCalibratedWhite:0.0 alpha:0.0];
	NSData *transpColorData=[NSArchiver archivedDataWithRootObject:transpColor];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary 
															 dictionaryWithObjectsAndKeys: 
															 @"YES", @"ShowRestartSheet",
															 @"YES", @"ShowShuffleSheet", 
															 @"YES", @"ShowChangeLevelSheet",
															 @"YES", @"ShowChangeSizeSheet", 
															 @"YES", @"ShowChooseEmptyBlockSheet",
															 @"YES", @"ShowChooseImageSheet", 
															 [NSNumber numberWithInt:20], @"Level", 
															 [NSNumber numberWithInt:4], @"Rows",
															 [NSNumber numberWithInt:4], @"Columns",
															 [NSNumber numberWithInt:0], @"EmptyX",
															 [NSNumber numberWithInt:0], @"EmptyY",
															 imagePath, @"ImageURL",
															 transpColorData, @"BackgroundColor",
															 nil];
	[defaults registerDefaults:appDefaults];
	[[NSUserDefaultsController sharedUserDefaultsController] 
	 setInitialValues:appDefaults];
}

- (IBAction) openAboutWindow: (id) sender {
	[[PZAboutWindowController sharedPZAboutWindowController] showWindow:nil];
	(void)sender;
}

- (IBAction) openPreferencesWindow: (id) sender {
	[[PZPreferencesWindowController sharedPZPreferencesWindowController] showWindow:nil];
	(void)sender;
}

@end
