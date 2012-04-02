//
//  PZPreferencesWindowController.h
//  PzzApp
//
//  Created by Ana Cañizares on 01.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PZDropImageView : NSImageView 

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

@end

@interface PZPreferencesWindowController : NSWindowController <NSToolbarDelegate> {
	
	IBOutlet NSToolbar *bar;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *currentPuzzlePreferenceView;
	IBOutlet PZDropImageView *generalImageView;
	IBOutlet NSTextField *generalImageViewLabel;
	IBOutlet NSPopUpButton *generalLevelPopUp;
	IBOutlet NSPopUpButton *generalSizePopUp;
	IBOutlet NSColorWell *generalColorWell;
	IBOutlet NSButton *showAlertCheckBox;
	int currentViewTag;	
}

+ (PZPreferencesWindowController *) sharedPZPreferencesWindowController;

-(NSView *) viewForTag:(int)tag;
-(IBAction) switchView:(id)sender;
-(NSRect) newFrameForNewContentView:(NSView *)view;

- (IBAction) changeLevel: (id) sender;
- (IBAction) changeSize: (id) sender;
- (IBAction) chooseImage: (id) sender;
- (IBAction) changeBackgroundColor: (id) sender;
- (IBAction) configureAlertDialogs: (id) sender;
- (void) imageDropped: (NSURL *) url;
- (void) imageRemoved;
- (IBAction) restorePreferences: (id) sender;
@end
