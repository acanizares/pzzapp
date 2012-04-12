//
//  PZPreferencesWindowController.m
//  PzzApp
//
//  Created by Ana Cañizares on 01.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import "PZPreferencesWindowController.h"
#import "NSUserDefaultsWithExtras.h"


static PZPreferencesWindowController *_sharedPZPreferencesWindowController = nil;

@interface PZPreferencesWindowController()

- (void) updateGeneralView;
- (void) updateCurrentPuzzleView;

@end



@implementation PZPreferencesWindowController

- (id) init
{
	self = [super initWithWindowNibName:@"Preferences"];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver: self 
																						 selector: @selector(updateGeneralView)
																								 name: NSUserDefaultsDidChangeNotification
																							 object: nil];
		// TODO: apuntarse a PZWindowPreferencesUpdated
	} else {
		[self release];
		return nil;
	}
	
	return self;
}

+ (PZPreferencesWindowController *) sharedPZPreferencesWindowController
{
	if (!_sharedPZPreferencesWindowController) {
		_sharedPZPreferencesWindowController = [[self alloc] init];
	}
	return _sharedPZPreferencesWindowController;
}

- (void) dealloc {
	[super dealloc];
}

/*
-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [[toolbar items] valueForKey:@"itemIdentifier"];
}
*/

-(void)awakeFromNib {
	[self.window setContentSize:[generalPreferenceView frame].size];
	[[self.window contentView] addSubview:generalPreferenceView];
	[bar setSelectedItemIdentifier:@"General"];
	[self.window center];
	[self updateGeneralView];
}

-(NSView *)viewForTag:(int)tag {
	NSView *view = nil;
	switch(tag) {
		case 0: default: view = generalPreferenceView; break;
		case 1: view = currentPuzzlePreferenceView; break;
	}
	return view;
}
-(NSRect)newFrameForNewContentView:(NSView *)view {
	
	NSRect newFrameRect = [self.window frameRectForContentRect:[view frame]];
	NSRect oldFrameRect = [self.window frame];
	NSSize newSize = newFrameRect.size;
	NSSize oldSize = oldFrameRect.size;    
	NSRect frame = [self.window frame];
	frame.size = newSize;
	frame.origin.y -= (newSize.height - oldSize.height);
	
	return frame;
}

-(IBAction)switchView:(id)sender {
	
	int tag = [sender tag];
	
	NSView *view = [self viewForTag:tag];
	NSView *previousView = [self viewForTag: currentViewTag];
	currentViewTag = tag;
	NSRect newFrame = [self newFrameForNewContentView:view];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.1];
	
	if ([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)
		[[NSAnimationContext currentContext] setDuration:1.0];
	
	[[[self.window contentView] animator] replaceSubview:previousView with:view];
	[[self.window animator] setFrame:newFrame display:YES];
	
	[NSAnimationContext endGrouping];
	
}

- (void) updateGeneralView {
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] 
															defaults];
	NSString *defImageURL = [[defaults persistentDomainForName:@"com.pilpelsoft.PzzApp"] 
													 objectForKey:@"ImageURL"];
	if (defImageURL) {
		//show image in viewer if there is one in our persistent domain
		NSImage *defImage = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:defImageURL]];
		[generalImageView setImage:defImage];
		[generalImageViewLabel setAlphaValue:0.0];
		[defImage release];
	}
	else {
		[generalImageView setImage:nil];
		[generalImageViewLabel setAlphaValue:1.0];
	}
	[generalLevelPopUp selectItemWithTag:[defaults integerForKey:@"Level"]];
	if ([defaults integerForKey:@"Rows"] == [defaults integerForKey:@"Columns"])
		[generalSizePopUp selectItemWithTag:[defaults integerForKey:@"Rows"]];
	else
		NSLog(@"Error: different values for keys Rows and Columns.");
	[generalColorWell setColor:[defaults colorForKey:@"BackgroundColor"]];
	if ([defaults boolForKey:@"ShowRestartSheet"] && 
			[defaults boolForKey:@"ShowShuffleSheet"] &&
			[defaults boolForKey:@"ShowChangeLevelSheet"] && 
			[defaults boolForKey:@"ShowChangeSizeSheet"] &&
			[defaults boolForKey:@"ShowChooseEmptyBlockSheet"] && 
			[defaults boolForKey:@"ShowChooseImageSheet"])
		[showAlertCheckBox setState:NSOnState];
	else
		[showAlertCheckBox setState:NSOffState];
}

- (void) updateCurrentPuzzleView {
 // TODO: responder a PZWindowPreferencesUpdated
}

-(IBAction) chooseImage: (id) sender {
	NSOpenPanel* oPanel = [NSOpenPanel openPanel];
	
	[oPanel setCanChooseDirectories:NO];
	[oPanel setCanChooseFiles:YES];
	[oPanel setCanCreateDirectories:YES];
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setAlphaValue:0.95];
	[oPanel setTitle:@"Select an image to open"];
	// Allow only supported image files (this also displays the media folder
	// in the sidebar)
	[oPanel setAllowedFileTypes:(NSArray*)CGImageSourceCopyTypeIdentifiers()];
	
	// Display the dialog. If the OK button was pressed, process the file
	if ( [oPanel runModal] == NSOKButton ) {
		NSURL *imageURL = [[oPanel URLs] lastObject];
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
		[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
		 setObject: [imageURL absoluteString] forKey:@"ImageURL"];
		[generalImageView setImage:image];
		[generalImageViewLabel setAlphaValue:0.0];
		[image release];
	}
}

- (IBAction) changeLevel: (id) sender {
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setObject: [NSNumber numberWithInt:[sender tag]] forKey:@"Level"];
}
- (IBAction) changeSize: (id) sender {
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setObject: [NSNumber numberWithInt:[sender tag]] forKey:@"Rows"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setObject: [NSNumber numberWithInt:[sender tag]] forKey:@"Columns"];
}

- (IBAction) changeBackgroundColor: (id) sender {
  [[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
   setColor: [sender color] forKey:@"BackgroundColor"];
}

- (IBAction) configureAlertDialogs: (id) sender {
	BOOL newValue = ([sender state] != 0);
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowRestartSheet"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowShuffleSheet"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowChangeLevelSheet"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowChangeSizeSheet"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowChooseEmptyBlockSheet"];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	 setBool: newValue forKey:@"ShowChooseImageSheet"];
}

- (IBAction) restorePreferences: (id) sender {
	NSDictionary *inVal = [[NSUserDefaultsController sharedUserDefaultsController] 
												 initialValues];
	[[NSUserDefaultsController sharedUserDefaultsController] 
	 revertToInitialValues: inVal];
}

- (void) imageDropped: (NSURL *) url {
	[generalImageViewLabel setAlphaValue:0.0];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults] 
	setObject: [url absoluteString] forKey:@"ImageURL"];
}
- (void) imageRemoved {
	[generalImageViewLabel setAlphaValue:1.0];
	[[[NSUserDefaultsController sharedUserDefaultsController] defaults]
	 removeObjectForKey:@"ImageURL"];
}

@end

/******************************************************************************
 PZDropImageView
 ******************************************************************************/
//
//  Created by Vladimir Boychentsov on 2/26/10.
//  Copyright 2010 www.injoit.com. All rights 

@implementation PZDropImageView

- (void) keyDown:(NSEvent *)theEvent
{
	if ([theEvent keyCode] == 0x33) {
		id <NSWindowDelegate> del = [[self window] delegate];
		if ([(PZPreferencesWindowController*)del 
				 respondsToSelector:@selector(imageRemoved)])
			[(PZPreferencesWindowController*)del imageRemoved];
	}
	[super keyDown:theEvent];
} 

 //Handling mouse-dragging in a mouse-tracking loop (con nubecita)
- (void) mouseDown:(NSEvent *)theEvent {
	if (![self image]) return;
	BOOL keepOn = YES;
	BOOL isInside = YES;
	
	NSPoint mouseLoc;
	NSCursor *cursor;
	
	while (keepOn) {
		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
                NSLeftMouseDraggedMask];
		mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		isInside = [self mouse:mouseLoc inRect:[self bounds]];
		
		switch ([theEvent type]) {
			case NSLeftMouseDragged:
				if (!isInside) {
					cursor = [NSCursor disappearingItemCursor];
					[cursor set];
				}
				else {
					cursor = [NSCursor arrowCursor];
					[cursor set];
				}
				break;
			case NSLeftMouseUp:
				if (!isInside) {
					NSShowAnimationEffect(
																NSAnimationEffectPoof, 
																[NSEvent mouseLocation], 
																NSZeroSize, 
																nil, 
																nil, 
																nil);
					id <NSWindowDelegate> del = [[self window] delegate];
					if ([(PZPreferencesWindowController*)del 
									 respondsToSelector:@selector(imageRemoved)])
					[(PZPreferencesWindowController*)del imageRemoved];
				}
				keepOn = NO;
				break;
			default:
				/* Ignore any other kind of event. */
				break;
		}
		
	};
	cursor = [NSCursor arrowCursor];
	[cursor set];
	return;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
			== NSDragOperationGeneric)
	{
		//this means that the sender is offering the type of operation we want
		//return that we want the NSDragOperationGeneric operation that they 
		//are offering
		return NSDragOperationGeneric;
	}
	else
	{
		//since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
		return NSDragOperationNone;
	}
}



- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	//we aren't particularily interested in this so we will do nothing
	//this is one of the methods that we do not have to implement
	//NSLog(@"%@", sender);
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		//  NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		//NSLog(@"%@", files);
		// Perform operation using the list of files
	}
	
	
	NSPasteboard *paste = [sender draggingPasteboard];
	
	//gets the dragging-specific pasteboard from the sender
	NSArray *types = [NSArray arrayWithObjects:NSPasteboardTypeTIFF, 
										NSFilenamesPboardType, nil];
	//a list of types that we can accept
	NSString *desiredType = [paste availableTypeFromArray:types];
	NSData *carriedData = [paste dataForType:desiredType];
	
	if (nil == carriedData)
	{
		//the operation failed for some reason
		NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed", 
										nil, nil, nil);
		return NO;
	}
	else
	{ NSLog(@"desiredType = %@",desiredType);
		//the pasteboard was able to give us some meaningful data
		if ([desiredType isEqualToString:NSPasteboardTypeTIFF])
		{
			//we have TIFF bitmap data in the NSData object
			NSImage *newImage = [[NSImage alloc] initWithData:carriedData];
			[self setImage:newImage];
			[newImage release];    
			//we are no longer interested in this so we need to release it
		}
		else if ([desiredType isEqualToString:NSFilenamesPboardType])
		{
			//we have a list of file names in an NSData object
			NSArray *fileArray = 
			[paste propertyListForType:@"NSFilenamesPboardType"];
			//be caseful since this method returns id.  
			//We just happen to know that it will be an array.
			NSString *path = [fileArray objectAtIndex:0];
			
			id <NSWindowDelegate> del = [[self window] delegate];
			if ([(PZPreferencesWindowController*)del 
					 respondsToSelector:@selector(imageDropped:)]) {
				NSURL *imageURL = [NSURL fileURLWithPath:path];
				[(PZPreferencesWindowController*)del imageDropped:imageURL];
			}
			
			//assume that we can ignore all but the first path in the list
			NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:path];
			
			if (nil == newImage) {
				//we failed for some reason
				NSRunAlertPanel(@"File Reading Error", 
												[NSString stringWithFormat:
												 @"Sorry, but I failed to open the file at \"%@\"",
												 path], nil, nil, nil);
				return NO;
			}	else {
				//newImage is now a new valid image
				[self setImage:newImage];
			}
			[newImage release];
		}
		else
		{
			//this can't happen
			NSAssert(NO, @"This can't happen");
			return NO;
		}
	}
	[self setNeedsDisplay:YES];    //redraw us with the new image
	return YES;
}



@end