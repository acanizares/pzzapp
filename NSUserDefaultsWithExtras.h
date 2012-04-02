//
//  NSUserDefaultsWithExtras.h
//  PzzApp
//
//  Created by Ana Cañizares on 02.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSUserDefaults(Extras)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;

@end
