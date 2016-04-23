//
//  PZApplicationDelegate.h
//  PzzApp
//
//  Created by Ana Cañizares on 01.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PZApplicationDelegate : NSObject <NSApplicationDelegate> {
    
}

- (IBAction) openAboutWindow: (id) sender;
- (IBAction) openPreferencesWindow: (id) sender;

@end
