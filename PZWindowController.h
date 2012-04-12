//
//  PZWindowController.h
//  PzzApp
//
//  Created by Ana Ca–izares on 27.03.12.
//  Copyright 2012 Pil Pel Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PZModel.h"


extern NSString* PZWindowPreferencesUpdated;

typedef enum {
	none, restartSheet, shuffleSheet,
	changeLevelSheet, changeSizeSheet,
	chooseEmptyBlockSheet, chooseImageSheet
} SheetModes;


// This is a block (an Obj-C closure)
// We use them for the sheet dialogs;ü
typedef void (^AlertBlock)(void);


@interface PZButtonCell : NSButtonCell {
  CGFloat imageAlpha;   // 1.0 = no transparency
}

@property CGFloat imageAlpha;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end


/*!
 */
@interface PZWindowController : NSWindowController <NSAnimationDelegate> {
	PZModel*                    puzz;
	NSMutableDictionary* puzzlePrefs;	
	IBOutlet NSMatrix*        matrix;
  NSColor*           matrixBgColor;
  
	IBOutlet NSPanel*       alertSheet;
	IBOutlet NSButton* alertSheetCheck;
	SheetModes           currSheetMode;
}

 //- (IBAction) changeImage: (id) sender;
- (BOOL) changeImage: (NSImage*) newImage;  // still necessary?

 //// UI actions fired through the responder chain

- (void) doShuffle: (id) sender;
- (void) doRestart: (id) sender;
- (void) doChangeSize: (id) sender;
- (void) doChangeLevel: (id) sender;
    //// These two together implement "empty cell editing mode"
- (void) doChangeEmptyCell: (id) sender;
- (void) doTakePieceOff: (id) sender;

- (void) doChangeBackgroundColor: (id) sender;

  //// The matrix has this as an action (WARNING! don't set the action of the
  // cells or the matrix' action won't get called after a click.)
- (void) doMovePiece: (id) sender;

- (IBAction) showOrNotAgain: (id) sender;
- (IBAction) alertSheetOK: (id) sender;
- (IBAction) alertSheetCancel: (id) sender;
- (void) openAlertSheet: (AlertBlock) code;
- (void) alertSheetDidEnd: (NSWindow *) sheet 
               returnCode: (int) returnCode contextInfo: (void *) contextInfo;

@end
