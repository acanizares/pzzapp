//
//  PZDocument.m
//  PzzApp
//
//  Copyright 2012 PilPel Soft. All rights reserved.
//

/* From the docs:
 For document-based applications, the default responder chain for the main 
 window consists of the following responders and delegates:
 
 - The main window’s first responder and the successive responder objects up
   the view hierarchy
 - The main window itself
 - The window's NSWindowController object (which inherits from NSResponder)
 - The main window’s delegate.
 - The NSDocument object (if different from the main window’s delegate)
 - The application object, NSApp
 - The application object's delegate
 - The application's document controller (an NSDocumentController object, which
   does not inherit from NSResponder)
 */


#import "PZDocument.h"
#import "PZWindowController.h"
#import "NSUserDefaultsWithExtras.h"

@interface PZDocument()

- (BOOL) loadImageFromURL:(NSURL *)url;

@end


@implementation PZDocument

- (id) init
{
    self = [super init];
    if (self && image) {
      NSUserDefaults *defaults = [[NSUserDefaultsController 
                                   sharedUserDefaultsController] defaults];

      puzzDefaults = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
          [defaults objectForKey:@"Level"],          @"Level", 
          [defaults objectForKey:@"Rows"],           @"Rows",
          [defaults objectForKey:@"Columns"],        @"Columns",
          [defaults objectForKey:@"EmptyX"],         @"EmptyX",
          [defaults objectForKey:@"EmptyY"],         @"EmptyY",
          [defaults colorForKey:@"BackgroundColor"], @"BackgroundColor",
          image,                                     @"Image",
          nil] retain];
    } else {
      [self release];
      return nil;
    }

    return self;
}

  // FIXME: Handle errors
- (id) initWithContentsOfURL:(NSURL *)absoluteURL
                      ofType:(NSString *)typeName
                       error:(NSError **)outError
{
  imageURL = [absoluteURL retain];    // necessary?
  [self loadImageFromURL:absoluteURL];
  return [self init];
}

  // FIXME: Handle errors
- (id) initWithType:(NSString *)typeName error:(NSError **)outError
{
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	imageURL = [[NSURL URLWithString:[defaults valueForKey:@"ImageURL"]] retain];
  [self loadImageFromURL:imageURL];
  return [self init];  // TODO? special behaviour for created docs?
}

- (void) dealloc
{
  [puzzDefaults release];
  [imageURL release];
  [controller release];
  [super dealloc];
}

- (void) makeWindowControllers
{
  controller = [[PZWindowController alloc] initWithPrefs: puzzDefaults];
  [self addWindowController:controller];
  [controller showWindow:self];
    // FIXME! HACK: Resize model and matrix to display the first time.
  NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
  [controller changeSizeWithRows:[defaults integerForKey:@"Rows"]
                         columns:[defaults integerForKey:@"Columns"]];
}

- (BOOL) loadImageFromURL: (NSURL*) url {
  [image release];
  image = [[NSImage alloc] initByReferencingURL:url];
	return [image isValid];
}

  // Insert code here to write your document to data of the specified type.
  // If the given outError != NULL, ensure that you set *outError when returning nil.
- (BOOL) writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
  if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return NO;
}

  // Insert code here to read your document from the given URL of the
  // specified type. If the given outError != NULL, ensure that you set
  // *outError when returning NO.
- (BOOL) readFromURL:(NSURL *)url ofType:(NSString *)type error:(NSError **)outError
{
    // FIXME: Handle errors.
  
  [self loadImageFromURL:url];
  [controller changeImage: image];
        
  if ( outError != NULL ) {
    *outError = [NSError errorWithDomain:NSOSStatusErrorDomain 
                                    code:unimpErr 
                                userInfo:NULL];
  }
  return YES;
}

@end
