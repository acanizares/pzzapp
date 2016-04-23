//
//  PZModel.h
//  PzzApp
//
//  Copyright 2012 PilPelSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int const MAX_ROWS;
extern int const MAX_COLS;
extern NSString* PZModelUpdatedNotification;
extern NSString* PZModelPreferencesUpdated;

    // Why is this an object and not a struct??!?!?!
@interface PZPos : NSObject
{
    NSInteger x;
    NSInteger y;
}

@property NSInteger x;
@property NSInteger y;

- (PZPos*) initWithX:  (NSInteger) _x Y: (NSInteger) _y;
+ (PZPos*) posWithX:   (NSInteger) _x Y: (NSInteger) _y;  // Autoreleased
+ (PZPos*) posWithPos: (PZPos*) pos;                      // Autoreleased

- (BOOL) isEqual: (PZPos*) other;
- (void) valuesFrom: (PZPos*) other;

@end

    // Why is this an object and not a struct??!?!?!
@interface PZSize : NSObject
{
    NSInteger rows;
    NSInteger columns;
}

@property NSInteger rows;
@property NSInteger columns;

- (PZSize*) init;
- (PZSize*) initWithRows: (NSInteger) r columns: (NSInteger) c;
+ (PZSize*) sizeWithRows: (NSInteger) r columns: (NSInteger) c;  // Autoreleased
+ (PZSize*) sizeWithSize: (PZSize*) size;                        // Autoreleased
- (BOOL) isEqual: (PZSize*) other;
- (void) valuesFrom: (PZSize*) other;

@end


/*! A PZModel manages the board, preferences, and images for a given puzzle.
 
 A class extension in PZModel.m defines the internals.
 */
@interface PZModel : NSObject {
    int*                 board;
    NSMutableArray*     pieces;
    NSImage*             image;
    int                  level;
    PZSize*               size;
    PZPos*            emptyPos;
    BOOL             shuffling;
}

    // Allow only read access to model properties to ensure internal consistency.
    // Modifications to the model must be done using setPrefs
@property(readonly) int       level;
@property(readonly) PZSize*    size;
@property(readonly) PZPos* emptyPos;

- (id) init; // Raises an exception
- (id) initWithPrefs: (NSDictionary*) prefs;
- (void)dealloc;

- (void) reset;
- (void) shuffle;

- (BOOL) move: (PZPos*) piece;
- (BOOL) isSolved;

- (NSImage*) imageAt: (PZPos*) pos;

- (NSDictionary*) getPrefs;
- (BOOL) setPrefs: (NSDictionary*) dict;

@end
