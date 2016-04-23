//
//  PZDocument.h
//  PzzApp
//
//  Copyright 2012 PilPel Soft. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "PZWindowController.h"

/*!
 */
@interface PZDocument : NSDocument {
    NSMutableDictionary*   puzzDefaults;
    NSURL*                 imageURL;
    NSImage*                  image;
    PZWindowController*  controller;
}

@end
