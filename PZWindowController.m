//
//  PZWindowController.m
//  PzzApp
//
//  Created by Ana Ca–izares on 27.03.12.
//  Copyright 2012 Pil Pel Soft. All rights reserved.
//

#import "PZWindowController.h"

@implementation PZButtonCell

@synthesize imageAlpha;
  // FIXME!! This constructor never gets called!!
- (id) init
{
  if (! (self = [super init])) {
    [self release];
    return nil;
  }
  imageAlpha = 1.0;
  return self;
}
  // FIXME!! This constructor never gets called!!
- (id) initImageCell: (NSImage*) anImage {
  if (self = [super initImageCell:anImage])
    imageAlpha = 1.0;
  else
    [self release];
  
  return self;
}

  // FIXME!! Since the constructors don't get called, we cannot use this!
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  [super drawWithFrame:cellFrame inView:controlView];
/*
  if ([controlView isFlipped]) {   // Careful: the view IS flipped
      // TO-DO
    [self.image drawInRect:cellFrame
                  fromRect:NSZeroRect 
                 operation:NSCompositeSourceOver //Use alpha mask
                  fraction:imageAlpha];
  } else {
    [self.image drawInRect:cellFrame 
                  fromRect:NSZeroRect 
                 operation:NSCompositeSourceOver //Use alpha mask
                  fraction:imageAlpha];
  }
 */
}

@end


/******************************************************************************
 PZWindowController: private interface using a "class extension"
 ******************************************************************************/

@interface PZWindowController()

- (void) changeSizeWithRows: (int) r columns: (int) c;
- (void) shuffle;
- (void) restart;
- (void) redrawAll;
- (void) animateSolvedPuzzle;

- (void) takeEmptyPieceOff;

- (void) refreshViewHack;

@end


/******************************************************************************
 PZWindowController implementation
 ******************************************************************************/

@implementation PZWindowController

- (id) initWithPrefs: (NSMutableDictionary*) prefs
{
  currSheetMode = none;	
	puzzlePrefs = [[NSMutableDictionary alloc] initWithDictionary: prefs];
	puzz = [[PZModel alloc] initWithPrefs:puzzlePrefs];

  if (puzz == nil || ! (self = [super initWithWindowNibName:@"PZWindow"])) {
    [self release];
    [puzzlePrefs release];
    [puzz release];
    NSLog(@"PZWindowController initWithPrefs:");
    return nil;
  }
  return self;
}

- (void) dealloc
{
  [puzz release];
  [puzzlePrefs release];
  
  [super dealloc];
}

- (void) awakeFromNib
{
  // For some reason, the prototype set using IB, although apparently the
  // same as the default cell, has different properties, so we must set it here.
  PZButtonCell *prototype = (PZButtonCell*)[matrix cellAtRow:0 column:0];
	[matrix setPrototype:prototype];
}


/******************************************************************************
 Undo management:
 "When the first responder of an application receives an undo or redo message,
 NSResponder goes up the responder chain looking for a next responder that 
 returns an NSUndoManager object from undoManager. Any returned undo manager is
 used for the undo or redo operation.
 
 If the undoManager message wends its way up the responder chain to the window,
 the NSWindow object queries its delegates with windowWillReturnUndoManager: to
 see if the delegate has an undo manager. If the delegate does not implement
 this method, the window creates an NSUndoManager object for the window and all
 its views.
 
 Document-based applications often make their NSDocument objects the delegates
 of their windows and have them respond to the windowWillReturnUndoManager: 
 message by returning the undo manager used for the document. These applications
 can also make each NSWindowController object the delegate of its window - the 
 window controller implements windowWillReturnUndoManager: to get the undo
 manager from its document and return it."
 ******************************************************************************/

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
  return [[self document] undoManager];
}


/******************************************************************************
 Modifications of the model:
 These four methods perform the basic operations on the model.
 ******************************************************************************/

- (void) changeSizeWithRows: (int) r columns: (int) c 
{
	if (r == puzz.size.rows && c == puzz.size.columns) return;

	NSSize  s = [[[super window] contentView] frame].size;
	s.width  /= c;
	s.height /= r;
	
	[matrix setCellSize:s];
	[matrix renewRows:r columns:c];

	[puzzlePrefs setObject:[NSNumber numberWithInt:r] forKey:@"Rows"];
  [puzzlePrefs setObject:[NSNumber numberWithInt:c] forKey:@"Columns"];
	
	[self restart];
}

- (void) shuffle
{
	[puzz setPrefs:puzzlePrefs];
  [puzz shuffle];
	[self redrawAll];
	[self takeEmptyPieceOff];
}

- (void) restart
{
	[puzz setPrefs:puzzlePrefs];
	[puzz reset];
	[self redrawAll];
	[self takeEmptyPieceOff];
	[self refreshViewHack];
  [matrix setIntercellSpacing: NSMakeSize(1.0, 1.0)];
	[[matrix superview] setNeedsDisplay: YES];
}
			 
- (BOOL) movePieceAtRow: (int) r column: (int) c 
{
	PZPos* piece  = [PZPos posWithX:c Y:r];
	if (! [puzz move: piece])
		return FALSE;

    //// "from" was modified by [puzz move] and now contains the position 
    //// of the shifted piece

  [[[[self document]undoManager] 
    prepareWithInvocationTarget:self] movePieceAtRow: piece.y column: piece.x];
  [[[self document]undoManager] setActionName:@"move"];
  
	[[matrix cellAtRow:piece.y column:piece.x] setImage: [puzz imageAt:piece]];
  [self takeEmptyPieceOff];
  
  if ([puzz isSolved])
    [self animateSolvedPuzzle];

	return TRUE;
}

- (BOOL) changeImage: (NSImage*) newImage {
  [puzzlePrefs setObject:[newImage retain] forKey:@"Image"];
  [self restart];
  return YES;
}


/******************************************************************************
 Redrawing and animating:
 When the puzzle is solved, we display an animation and then draw the original
 image. We need to set ourselves as a NSAnimationDelegate for that. See below.
 ******************************************************************************/

- (void) redrawAll
{
	for (int i=0; i<puzz.size.rows; i++)
		for (int j=0; j<puzz.size.columns; j++)
			[[matrix cellAtRow:i column:j] setImage: [puzz imageAt:[PZPos posWithX:j Y:i]]];
}

- (void) takeEmptyPieceOff
{
  PZButtonCell* piece = [matrix cellAtRow:puzz.emptyPos.y column:puzz.emptyPos.x];
    // setting the image's alpha to nil (using a special PZButtonCell) would
    // be preferable to setting it to nil if we wanted to fade the piece in
    // after the puzzle is completed. Since this doesn't work, we fade out
    // the whole puzzle instead and leave this as is. (FIXME)
    //piece.imageAlpha = 0.0;
  [piece setImage:nil];
}

  // Part of the NSAnimationDelegate Protocol
  // We use this for the animation started by animateSolvedPuzzle
  // FIXME: this doesn't get called.
- (void) animationDidEnd: (NSAnimation*) animation
{
  [matrix setIntercellSpacing: NSMakeSize(0.0, 0.0)];  
  [matrix setAlphaValue: 1.0];
}

- (void) animateSolvedPuzzle
{

  [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5];
	
    //PZButtonCell* cell = [matrix cellAtRow:puzz.emptyPos.y column:puzz.emptyPos.x];
    [[matrix animator] setDelegate:self];
    [[matrix animator] setAlphaValue: 0.0];
	[NSAnimationContext endGrouping];

    // WARNING. Any code here will get executed before the animation even 
    // starts because it runs concurrently. We need to set ourselves as
    // delegate to the started NSAnimation.
}

  // For some misterious reason, we must resize the window in order to get the
  // matrix to display it cells.
- (void) refreshViewHack
{
	NSRect rect = [[super window] frame];
	rect.size.width += 1.0;
	[[super window] setFrame: rect display: YES];
	rect.size.width -= 1.0;
	[[super window] setFrame: rect display: YES];
}


/******************************************************************************
 Actions available from the user interface.
 Menu items and possibly some other UI items have their actions sent to the
 responder chain. We implement those methods and decide whether checkmarks
 must be updated, etc., using validateUserInterfaceItem: and validateMenuItem:
 ******************************************************************************/

- (void) doChangeSize: (id) sender
{
  // The tag for the menu item calling us is n for an entry "n x n"
  if ([sender tag] == puzz.size.rows) return;
  
  AlertBlock codeAfterOKButton = ^(void) {
    [self changeSizeWithRows:[sender tag] columns:[sender tag]];
  };
    
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowChangeSizeSheet"]) {
    currSheetMode = changeSizeSheet;
    [self openAlertSheet: codeAfterOKButton];
  } else {
    codeAfterOKButton();
  }
}

- (void) doChangeLevel: (id) sender
{
  if (puzz.level == [sender tag]) return;
  
  AlertBlock codeAfterOKButton = ^(void) {
    [puzzlePrefs setObject:[NSNumber numberWithInt:[sender tag]] forKey:@"Level"];
    [self shuffle];
  };
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowChangeLevelSheet"]) {
    currSheetMode = changeLevelSheet;
    [self openAlertSheet: codeAfterOKButton];                        
  } else {
    codeAfterOKButton();
  }
}

- (IBAction) doChangeEmptyCell: (id) sender
{
  AlertBlock codeAfterOKButton = ^(void) {
    [self restart];
    //Comienza el modo de edici—n de la pieza en blanco.
    [matrix setAction:@selector(takeSelectedPieceOff:)];
  };

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowChooseEmptyBlockSheet"]) {
		currSheetMode = chooseEmptyBlockSheet;
		[self openAlertSheet: codeAfterOKButton];
	} else {
    codeAfterOKButton();
  }
}

- (void) takeSelectedPieceOff: (id) sender
{
	NSInteger r;
	NSInteger c;
	[matrix getRow:&r column:&c ofCell:[matrix selectedCell]];
	[puzzlePrefs setObject:[NSNumber numberWithInt:c] forKey:@"EmptyX"];
  [puzzlePrefs setObject:[NSNumber numberWithInt:r] forKey:@"EmptyY"];
	[puzz setPrefs:puzzlePrefs];
	[self takeEmptyPieceOff];
		//Termina el modo de edici—n de la pieza en blanco.
	[matrix setAction:@selector(movePieceView:)];
}

- (void) doShuffle: (id) sender
{
  AlertBlock codeAfterOKButton = ^(void) {	[self shuffle]; };
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowShuffleSheet"]) {
		currSheetMode = shuffleSheet;
		[self openAlertSheet: codeAfterOKButton];
	}	else {
    codeAfterOKButton();
  }
}


- (void) doRestart: (id) sender
{
  AlertBlock codeAfterOKButton = ^(void) { [self restart]; [self takeEmptyPieceOff];};
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowRestartSheet"]) {
		currSheetMode = restartSheet;
		[self openAlertSheet: codeAfterOKButton ];
	} else
    codeAfterOKButton();
}

- (IBAction) movePieceView: (id) sender
{
	NSInteger r, c;
	[matrix getRow:&r column:&c ofCell:[matrix selectedCell]];
	[self movePieceAtRow:r column:c];
}

- (IBAction) showOrNotAgain: (id) sender
{
	NSString *changedKey = [NSString string];
	NSString *newValue = [NSString string];
	if ([sender state]) newValue = @"NO";
	else newValue = @"YES";
	if (currSheetMode == restartSheet)
		changedKey = @"ShowRestartSheet";
	else if (currSheetMode == shuffleSheet)
		changedKey = @"ShowShuffleSheet";
	else if (currSheetMode == changeLevelSheet)
		changedKey = @"ShowChangeLevelSheet";
	else if (currSheetMode == changeSizeSheet)
		changedKey = @"ShowChangeSizeSheet";
	else if (currSheetMode == chooseEmptyBlockSheet)
		changedKey = @"ShowChooseEmptyBlockSheet";
	else if (currSheetMode == chooseImageSheet)
		changedKey = @"ShowChooseImageSheet";
	[[NSUserDefaults standardUserDefaults] setObject:newValue forKey:changedKey];
}


//- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)item

- (BOOL) validateMenuItem:(NSMenuItem *)item
{
  if ([item action] == @selector(doRestart:)) {
    if ([puzz isSolved])
      return NO;
  } else if ([item action] == @selector(doChangeSize:)) {
    if ([item tag] == puzz.size.rows)  // FIXME: this sucks
      [item setState: NSOnState];
    else
      [item setState: NSOffState];
  } else if ([item action] == @selector(doChangeLevel:)) {
    if ([item tag] == puzz.level)
      [item setState: NSOnState];
    else
      [item setState: NSOffState];
  } 
  return YES;
}

/******************************************************************************
 Sheet management
 ******************************************************************************/

- (IBAction) alertSheetOK: (id) sender
{
	[NSApp endSheet: alertSheet returnCode: NSOKButton];
	[alertSheet orderOut:nil];
}

- (IBAction) alertSheetCancel: (id) sender
{
	[NSApp endSheet:alertSheet returnCode: NSCancelButton];
	[alertSheet orderOut:nil];
}

- (void) openAlertSheet: (AlertBlock) block
{
	[NSApp beginSheet: alertSheet
		 modalForWindow: [super window]
			modalDelegate: self
		 didEndSelector: @selector(alertSheetDidEnd: returnCode: contextInfo:)
				contextInfo: [block copy]];
}

- (void) alertSheetDidEnd: (NSWindow *) sheet 
				 returnCode: (int) returnCode contextInfo: (void *) block 
{
	if (returnCode == NSOKButton)
    ((AlertBlock)block)();
  
  [(AlertBlock)block release];
  
  [alertSheetCheck setState:NSOffState];
}
@end
