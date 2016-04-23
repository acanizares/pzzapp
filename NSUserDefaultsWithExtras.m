//
//  NSUserDefaultsWithExtras.m
//  PzzApp
//
//  Created by Ana Cañizares on 02.04.12.
//  Copyright 2012 PilPel Soft. All rights reserved.
//

#import "NSUserDefaultsWithExtras.h"


@implementation NSUserDefaults(Extras)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end
