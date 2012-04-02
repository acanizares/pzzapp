//
//  PZModel.m
//  PzzApp
//
//  Copyright 2012 PilPelSoft. All rights reserved.
//

#import "PZModel.h"


/******************************************************************************
 * Extern constants
 ******************************************************************************/

int const MAX_ROWS = 100;
int const MAX_COLS = 100;
NSString* PZModelUpdatedNotification = @"PZModelUpdatedNotification";
NSString* PZModelPreferencesUpdated  = @"PZModelPreferencesUpdated"; 


/******************************************************************************
 * Rather pointless position and size objects
 ******************************************************************************/

@implementation PZPos

@synthesize x;
@synthesize y;

- (PZPos*) initWithX: (NSInteger) _x Y: (NSInteger) _y {
	if (self = [super init]) {
		x = _x;
		y = _y;
    return self;
	} else {
    [self release];
    return nil;
  }
}

+ (PZPos*) posWithX: (NSInteger) _x Y: (NSInteger) _y // Autoreleased
{
	PZPos *aux = [PZPos alloc];
  [aux initWithX:_x Y:_y];
	[aux autorelease];
	return aux;
	
	// _x = 32 !?!??!?!?!?!
	//return [[[PZPos alloc] initWithX:_x Y:_y] autorelease];
}

+ (PZPos*) posWithPos: (PZPos*) pos   // Autoreleased
{
  PZPos* ret = [[PZPos alloc] init];
  [ret valuesFrom:pos];
  [ret autorelease];
  return ret;
}


- (BOOL) isEqual: (PZPos*) other {
  return (x == other->x && y == other->y);
}

- (void) valuesFrom: (PZPos*) other {
	x = other->x;
	y = other->y;
}

@end

@implementation PZSize

@synthesize rows;
@synthesize columns;

- (PZSize*) init {
	if (self = [super init]) {
		rows = columns = 1;
    return self;
  } else {
    [self release];
    return nil;
	}
}

- (PZSize*) initWithRows: (NSInteger) r columns: (NSInteger) c {
	if (self = [super init]) {
		rows    = r;
		columns = c;
   	return self;
	} else {
    [self release];
    return nil;
  }
}

// Autoreleased
+ (PZSize*) sizeWithRows: (NSInteger) r columns: (NSInteger) c
{
	PZSize *aux = [PZSize alloc];
  [aux initWithRows:r columns:c];
	[aux autorelease];
	return aux;
}

+ (PZSize*) sizeWithSize: (PZSize*) size   // Autoreleased
{
  PZSize* ret = [[PZSize alloc] init];
  [ret valuesFrom:size];
  [ret autorelease];
  return ret;
}


- (BOOL) isEqual: (PZSize*) other {
  return (rows == other->rows && columns == other->columns);
}

- (void) valuesFrom: (PZSize*) other {
	rows = other->rows;
	columns = other->columns;
}

@end


/******************************************************************************
 * Private interface using a "class extension"                                *
 ******************************************************************************/

@interface PZModel()

@property BOOL shuffling;

- (int)  offset:(PZPos*) p;
- (int)  offsetX: (int) _x Y: (int) _y;

- (void) resize;
- (BOOL) isValidMove: (PZPos*) _from to: (PZPos*) _to;
- (BOOL) isValidPos: (PZPos*) pos;
- (BOOL) isValidLevel: (int)l;

- (void) splitImage;
@end


@implementation PZModel

@synthesize level;
@synthesize size;
@synthesize emptyPos;
@synthesize shuffling;

/// Calculate offsets in the internal arrays board and pieces.
- (int) offset:(PZPos*) p { return (p.y * size.columns) + p.x; }
- (int) offsetX:(int) _x Y: (int) _y { return (_y * size.columns) + _x; }

- (void) resize {
  if (board) free (board);
  board = (int*)malloc((size_t)(size.rows*size.columns*sizeof(int)));
  [self reset];
  [self splitImage];
}

- (BOOL) isValidPos: (PZPos*) pos {
  return (pos.x >= 0 && pos.y >=0 && pos.x < size.rows && pos.y < size.columns);
}

// Use the Manhattan metric to ensure that pieces have one common side.
- (BOOL) isValidMove: (PZPos*) _from to: (PZPos*) _to {
  return ([self isValidPos:_from] && 
          [self isValidPos:_to] && 
          (abs(_from.x-_to.x) + abs(_from.y-_to.y) == 1));
}

// Necessary? Stupid?
- (BOOL) isValidLevel: (int) l {
  return (l>=1 && l < size.rows*size.columns*100);
}

- (void) splitImage {
  
  [pieces release];
	pieces = [[NSMutableArray alloc] initWithCapacity: size.rows * size.columns];
  
	CGFloat deltaH = [image size].height/size.rows;
	CGFloat deltaW = [image size].width/size.columns;
	
	for (int i = 0; i < size.rows; i++) {
		for (int j = 0; j < size.columns; j++) {
			NSImage* img = [[NSImage alloc] initWithSize:NSMakeSize(deltaW, deltaH)];
			[img lockFocus];
			//coordinate origins of array and image are not the same

			[image drawAtPoint: NSMakePoint(0.0, 0.0)
								fromRect: NSMakeRect(j*deltaW, (size.rows-i-1)*deltaH,
                                     (j+1)*deltaW, (size.rows-i)*deltaH)
							 operation: NSCompositeCopy
								fraction: 1.0];
        //NSString* number = [NSString stringWithFormat:@"%d",[self offsetX:j Y:i]];
        //[number drawAtPoint: NSMakePoint(10, 10) withAttributes: nil];
			[img unlockFocus];
			[pieces insertObject:img atIndex:[self offsetX:j Y:i]];
			[img release];
		}
	}
}


/******************************************************************************
 * Public interface                                                           *
 ******************************************************************************/

// Force use of initWithPrefs
- (id) init {
  [NSException raise:@"No default init for PZModel." 
              format:@"Cannot initialize without default preferences"];
  return nil;
}

- (id) initWithPrefs: (NSDictionary*) prefs {
	if (! (self = [super init]))
		return nil;

	level    = 1;
  board    = nil;
  pieces   = nil;
  image    = [[NSURL      alloc] init];
	size     = [[PZSize alloc] init];
	emptyPos = [[PZPos  alloc] init];

  if (! [self setPrefs: prefs]) return nil;

  return self;
}

- (void)dealloc {

	if (board)
		free(board);
	
	[pieces   release];
	[image    release];
	[size     release];
	[emptyPos release];

  [super dealloc];
}

- (void) reset {
  for (int i=0; i<size.rows; i++)
		for (int j=0; j<size.columns; j++)
      board[[self offsetX:j Y:i]] = [self offsetX:j Y:i];
}

- (void) shuffle {
 	[self reset];

	PZPos* aux = [PZPos posWithX:emptyPos.x Y:emptyPos.y];
	srandom((unsigned)clock());
	for (int i=0; i<=level; i++) {
		int ran = (int)(random() % 4);
    [aux valuesFrom:emptyPos];
    if      (ran == 0) aux.x--;
		else if (ran == 1) aux.y--;
		else if (ran == 2) aux.y++;
		else               aux.x++;
    
		[self move:aux]; // try to move
	} 
}

/*! Moves the given piece into the empty position if it can be done.
 The resulting position (i.e. the old emptyPos is returned inside the parameter
 piece. NO is returned if the movement is invalid.
 */
- (BOOL) move: (PZPos*) piece {
  if (! [self isValidMove: piece to: emptyPos])
    return NO;

  PZPos* oldEmpty = [PZPos posWithPos:emptyPos];
  
	//NSLog(@"From %d,%d to %d,%d.", from.x, from.y, emptyPos.x, emptyPos.y);
  int aux                       = board[[self offset:emptyPos]];
  board[[self offset:emptyPos]] = board[[self offset:piece]];
  board[[self offset:piece]]    = aux;
  
    // Set the new empty piece and return the old in the argument
	[emptyPos valuesFrom: piece];
  [piece valuesFrom:oldEmpty];

  	// Using asynchronous posting seems overkill?
	[[NSNotificationCenter defaultCenter] 
          postNotificationName:PZModelUpdatedNotification
                        object:self];
  return YES;
}

- (BOOL) isSolved {
	for (int i=0; i<size.rows; i++)
		for (int j=0; j<size.columns; j++)
      if (board[[self offsetX:j Y:i]] != [self offsetX:j Y:i])
				return NO;
	return YES;
}

- (NSImage*) imageAt: (PZPos*) pos {
  return [pieces objectAtIndex:board[[self offset:pos]]];
}

/*!
 Applies a given dictionary of settings and updates the model accordingly.
 This is the only way in which the parameters of the model can be modified.
 */
- (BOOL) setPrefs: (NSDictionary*) dict {

  BOOL changes = NO;

  NSImage* newImage = (NSImage*)[dict objectForKey:@"Image"];
  if (! [newImage isValid])
    return NO;

	PZSize* ts = [PZSize sizeWithRows:[(NSNumber*)[dict objectForKey:@"Rows"] intValue] 
                            columns:[(NSNumber*)[dict objectForKey:@"Columns"] intValue]];
  if (ts.rows < 1 || ts.columns < 1 || ts.rows > MAX_ROWS || ts.columns > MAX_COLS)
    return NO;

	PZPos* tp = [PZPos posWithX:[(NSNumber*)[dict objectForKey:@"EmptyX"] intValue]
                            Y:[(NSNumber*)[dict objectForKey:@"EmptyY"] intValue]];
	if (! [self isValidPos:tp])
    return NO;

  int tl = [(NSNumber*)[dict objectForKey:@"Level"] intValue];
  if (! [self isValidLevel: tl])
    return NO;
  
  if (! [newImage isEqual:image]) {
		[image autorelease];
		image = [newImage retain];
		[self splitImage];
    changes = YES;
  }
  
  if (! [size isEqual:ts]) {
		[size valuesFrom:ts];
		[self resize];  // WARNING! This needs a loaded image!
    changes = YES;
	}
	
  if (! [self isValidPos: tp]) {
    return NO;
  } else if (! [emptyPos isEqual:tp]) {
    [emptyPos valuesFrom: tp];
    changes = YES;
  }
	
  if (level != tl) {
    level   = tl;
    changes = YES;
  }
  
  if (changes) {
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:PZModelPreferencesUpdated
     object:self
     userInfo:dict];    
  }
	return YES; 
}

- (NSDictionary*) getPrefs
{
  NSDictionary* dict = [[NSDictionary alloc] init];
  [dict autorelease];
  /*
  NSValue* val = [NSValue valueWithBytes:size objCType:@encode(PZSize)];
  [dict setValue:val forKey:@"Size"];
  [val release];  // OK?
  */
  
  // blah blah.. termina
  
  return dict;
}
@end
