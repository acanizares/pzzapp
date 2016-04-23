//
//  PZAboutWindowController.m
//
//  Created by Ana Cañizares on 01.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import "PZAboutWindowController.h"

static PZAboutWindowController* _sharedPZAboutWindowController = nil;

@implementation PZAboutWindowController

+ (PZAboutWindowController *) sharedPZAboutWindowController {
    if (!_sharedPZAboutWindowController) {
        _sharedPZAboutWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
    }
    return _sharedPZAboutWindowController;
}

+ (NSString *)nibName {
    return @"About";
}

- (void) dealloc {
    [super dealloc];
}

-(void)awakeFromNib {
    [self.window center];
}

@end
