//
//  RoomView.m
//  dis
//
//  Created by Robert Smith on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This view is responsible for handling the user input when drawing the room shapes only
// it connects only to the SetupRoomViewController which can communicate with the view
// through the public methods, the view can communicate to the VC via the protocol defined
// delegate. The view only has 1 peice of information to tell the VC and that is when a user has 
// finished drawing thus providing the VC with a fromPoint and toPoint.

#import "RoomView.h"
#import "RoomManager.h"
#import "HouseManager.h"

@implementation RoomView


@synthesize delegate = _delegate;

//load variables defined in HouseView
extern int step; // Grid step size- def in HouseView.
extern int dash;
extern int startx;
extern int starty;


-(id)initWithCoder:(NSCoder *)aDecoder {
    //init on load
    if ((self = [super initWithCoder:aDecoder])) {
        
        [self setupVariables];
		
		[self setupBuffer];
		[self getHousePath];
		[self drawHouse];
    }
    return self;
}

//SETUP VARIABLES

-(void)setupVariables {
    //setup the important variables on called when the view loads
	
    beginRoom = 1;
    beginTouch = 0;
    beginTouchPoint.x = startx;
    beginTouchPoint.y = starty;
    toPoint.x = 0;
    toPoint.y = 0;
    fromPoint.x = 0;
    fromPoint.y = 0;
	
	//floors
	currentFloor = 0;

}

-(void)setupBuffer {
	/* this method sets up the offScreenBuffer which is a context defined as an instance variable
	 this method is vital as it allows us to draw very fast offscreen then
	 output this to the screen in drawRect */
	
	CGSize size = {1024, 704}; //sets the size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); //defines the colourspace
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast); //creates the context
    CGColorSpaceRelease(colorSpace); //releases colourspace
    CGContextTranslateCTM(context, 0, size.height); 
    CGContextScaleCTM(context, 1.0, -1.0); //these two lines ensure the translation is correct
										   //without these the mapping would be back to front
	offScreenBuffer = context; //we finally assign the newly created context to our instance variable
	

}

//GET VARS

-(void)getHousePath{
    //gets housePoints and number of floors
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    houseArray = [sharedHouseManager getHousePoints];
	numberOfFloors = [[sharedHouseManager getNumberOfFloors] intValue];
}

-(void)getRoomsPath{
    //gets complete rooms (roomArray) and incomplete (wallArray)
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    roomArray = [sharedRoomManager roomObjects];
	wallArray = [sharedRoomManager roomPoints];
	
}

-(void)updateRooms{
	//called by VC when it detects changes in the model data
    [self getRoomsPath];
    [self rebuildContextImg];
    [self setNeedsDisplay];
}

-(void)rebuildContextImg {
    // allows us to rebuild the entire view
	//first we release the old context then recreate it
    CGContextRelease(offScreenBuffer);
    [self setupBuffer];
    [self drawHouse];
    [self drawRooms];
    [self drawPlottedPoints];

}

//DRAWING

-(void)drawHouse{
    
    CGPoint points[[houseArray count]];
    CGColorRef col;
    
    for(int i=0; i<[houseArray count]; i++){
        NSValue *val1 = [houseArray objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
    
	//draw house layout
    CGContextSaveGState(offScreenBuffer);
    col = [UIColor whiteColor].CGColor;
    CGContextSetFillColorWithColor(offScreenBuffer, col);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [houseArray count]);
    CGContextAddPath(offScreenBuffer, path);
    CGContextFillPath(offScreenBuffer);
    //edge
    CGContextSetLineWidth(offScreenBuffer,5);
    col = [UIColor blackColor].CGColor;
    CGContextSetStrokeColorWithColor(offScreenBuffer,col);
    CGContextAddPath(offScreenBuffer, path);
    CGContextStrokePath(offScreenBuffer);
    

    //grid within house
    CGContextSetLineWidth(offScreenBuffer,2);
    col = [UIColor blackColor].CGColor;
    CGContextSetStrokeColorWithColor(offScreenBuffer, col);
    int p = step-dash;
    CGFloat dashArray[] = {dash,p};
    CGContextSetLineDash(offScreenBuffer, 0, dashArray, 2);
    CGContextMoveToPoint(offScreenBuffer,0 , 0);
    
    CGContextAddPath(offScreenBuffer, path);
    CGContextClip(offScreenBuffer);
    
    for(int y=step;y<self.bounds.size.height;y=y+step){
        CGContextMoveToPoint(offScreenBuffer, step, y);
        CGContextAddLineToPoint(offScreenBuffer, self.bounds.size.width, y);
    }
    
    CGContextStrokePath(offScreenBuffer);
	CGContextRestoreGState(offScreenBuffer);
    CGPathRelease(path);
    [self setNeedsDisplay];
    
}

-(void)drawRooms{
    //this large method is responsible for drawing the rooms
	//it uses the objects in roomArray, loops through them
	//gets each ones path coordinates and name and colour
	//and builds them one by one
	
    CGRect roomRect;
    CGFloat midx;
    CGFloat midy;
    
    NSString *name;
    UIColor *colRec;
    CGColorRef col;
    
    
    for(int j=0; j<[roomArray count]; j++){
        if ([[roomArray objectAtIndex:j] respondsToSelector:@selector(isRoomType)]) {
			
			//get floor value of room
			NSNumber *flr = [[roomArray objectAtIndex:j] performSelector: @selector(returnFloor)];
            
			if([flr intValue] == currentFloor){ //only draw if it exists on current floor
				
				//get the values from object
				name = [[roomArray objectAtIndex:j] performSelector: @selector(returnName)];
				colRec = [[roomArray objectAtIndex:j] performSelector: @selector(returnColour)];
				arr = [[roomArray objectAtIndex:j] performSelector: @selector(returnArray)];
				
				//start of copy
				CGPoint points[[arr count]];
				
				for(int i=0; i<[arr count]; i++){
					NSValue *val1 = [arr objectAtIndex:i];
					CGPoint recFromPoint = [val1 CGPointValue];
					points[i]=recFromPoint;  
				}
				
				//draw room layout
				col = [colRec CGColor];
				CGContextSaveGState(offScreenBuffer);
				CGContextSetFillColorWithColor(offScreenBuffer, col);
				CGMutablePathRef path = CGPathCreateMutable();
				CGPathAddLines (path, NULL, points, [arr count]);
				CGContextAddPath(offScreenBuffer, path);
				CGContextFillPath(offScreenBuffer);
				
				
				//edge
				CGContextSetLineWidth(offScreenBuffer,2);
				col = [UIColor blackColor].CGColor;
				CGContextSetStrokeColorWithColor(offScreenBuffer,col);
				CGContextAddPath(offScreenBuffer, path);
				CGContextStrokePath(offScreenBuffer);
				
				
				//text
				CGContextAddPath(offScreenBuffer, path);
				roomRect = CGContextGetPathBoundingBox(offScreenBuffer);
				midx = CGRectGetMidX(roomRect);
				midy = CGRectGetMidY(roomRect);
				int namelen = (int)[name length];
				midx = midx - (4*namelen); //correct length of name text offset
				CGContextSelectFont(offScreenBuffer, "Courier", 15,  kCGEncodingMacRoman);
				CGContextSetTextMatrix(offScreenBuffer, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
				CGContextSetFillColorWithColor(offScreenBuffer, col);
				CGContextShowTextAtPoint (offScreenBuffer,midx,midy,[name UTF8String],[name length]);
				
				CGPathRelease(path);
				CGContextRestoreGState(offScreenBuffer);
			}
		}
    }
}

-(void)drawPlottedPoints{
	
    //draw shapes which are not complete

    CGColorRef col;
    CGContextSaveGState(offScreenBuffer);
	NSLog(@"WALLARRAY=%@", wallArray);
    //load points from array
    for(int i=0; i<[wallArray count]; i=i+2){
        NSValue *val1 = [wallArray objectAtIndex:i];
        NSValue *val2 = [wallArray objectAtIndex:i+1];
        CGPoint recFromPoint = [val1 CGPointValue];
        CGPoint recToPoint = [val2 CGPointValue];
        CGContextSetLineWidth(offScreenBuffer,10);
        col = [UIColor redColor].CGColor;
        CGContextSetStrokeColorWithColor(offScreenBuffer, col);
        CGFloat dashArray[] = {2,1};
        CGContextSetLineDash(offScreenBuffer, 0, dashArray, 2);
        CGContextMoveToPoint(offScreenBuffer,recFromPoint.x , recFromPoint.y);
        CGContextAddLineToPoint(offScreenBuffer, recToPoint.x, recToPoint.y);
        CGContextStrokePath(offScreenBuffer);
    }
    CGContextRestoreGState(offScreenBuffer);

}

-(void)drawRect:(CGRect)rect{
	
	//create an image based on the offscreen buffer
    CGImageRef cgImage = CGBitmapContextCreateImage(offScreenBuffer);
    uiImage1 = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    [uiImage1 drawInRect:self.bounds];
    
	
	//responsible for drawing current moving line only
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
    CGContextSetLineWidth(context,10);
    CGColorRef col = [UIColor greenColor].CGColor;
    CGContextSetStrokeColorWithColor(context, col);
    CGFloat dashArray[] = {2,1};
    CGContextSetLineDash(context, 0, dashArray, 2);
    CGContextMoveToPoint(context,fromPoint.x , fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    CGContextStrokePath(context);
	
	if(beginRoom == 0){ //only draw if not at starting position
		//draw black eol dot
		CGContextSetLineWidth(context,6);
		col = [UIColor blackColor].CGColor;
		CGContextSetStrokeColorWithColor(context, col);
		CGRect rectangle = CGRectMake(toPoint.x-6,toPoint.y-6,12,12);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextFillPath(context);
		//green eol dot
		CGContextRestoreGState(context);
		CGContextSetLineWidth(context,10);
		col = [UIColor greenColor].CGColor;
		CGContextSetStrokeColorWithColor(context, col);
		CGRect rectangle2 = CGRectMake(toPoint.x-7,toPoint.y-7,15,15);
		CGContextAddEllipseInRect(context, rectangle2);
		CGContextStrokePath(context);
	}


}

-(bool)isPointInsideHouse:(CGPoint)point{
    //returns yes if point is inside house, else no
    
	//create new context for this path
	CGSize size = {1024, 704};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	
    CGPoint points[[houseArray count]];
    for(int i=0; i<[houseArray count]; i++){
        NSValue *val1 = [houseArray objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [houseArray count]);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    
    if(CGContextPathContainsPoint(context,point,kCGPathFillStroke)){
		CGContextRelease(context);
        return true;
    }
    CGContextRelease(context);
    return false;

}

-(bool)isPoint:(CGPoint)point insideArray:(NSMutableArray *)array{
	
		
	//create new context for this path
	CGSize size = {1024, 704};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	
	point.x = point.x - 5; //offset fix- ensures we can get to lhs.
	point.y = point.y - 5; //top
	
	//we can now test to see if the point is inside array
	CGPoint points[[array count]];
	
    for(int i=0; i<[array count]; i++){
        NSValue *val1 = [array objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
	
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [array count]);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    
    if(CGContextPathContainsPoint(context,point,kCGPathFillStroke)){
		CGContextRelease(context);
        return true;
    }
	CGContextRelease(context);
	return false;
}

-(bool)isPointInsideExistingRoom:(CGPoint)point{
	
	//this method will allow us to detect if drawing on top of already
	//existing room it gets each room array that exists on the floor and
	//tests them one by one in the array isPoint:p insideArray:a method
	
	NSMutableArray* tempArr;
	
    for(int j=0; j<[roomArray count]; j++){
        if ([[roomArray objectAtIndex:j] respondsToSelector:@selector(isRoomType)]) {
			
			NSNumber *flr = [[roomArray objectAtIndex:j] performSelector: @selector(returnFloor)];
            
			if([flr intValue] == currentFloor){ //get floors on same lvl
				
				tempArr = [[roomArray objectAtIndex:j] performSelector: @selector(returnArray)];
					
				if([self isPoint:point insideArray:tempArr]){
					//YES point is inside
					return true;
				}
	
			} //if flr
		} //if
	} //for
	
    return false;
	
}

-(void)setFloorLevel:(int)flr{
	//the VC can set the floor level based on receiving swipe triggers
	currentFloor = flr;
	[self resetForFloorChange];
	
}

-(void)resetForFloorChange{
	//changing floors we want to reset everything
	beginRoom = 1;
    beginTouch = 0;
    beginTouchPoint.x = startx;
    beginTouchPoint.y = starty;
    toPoint.x = 0;
    toPoint.y = 0;
    fromPoint.x = 0;
    fromPoint.y = 0;

	[wallArray removeAllObjects]; //remove unfinished walls

	
}


//TOUCHES

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	/* touchesBegan is called when the user touches the screen 
	 there are 2 types of touch:
	 1) starting new room- we test if its first point in a room and point is inside house and 
	 and ensure point isn't inside an existing room 
	 2) if NOT starting a room- we test to ensure that point is near the last toPoint */
    CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint p = point;
	
    point.x = step * floor((point.x / step) );
    point.y = step * floor((point.y / step) );
    
    if(beginRoom && [self isPointInsideHouse: point] && (![self isPointInsideExistingRoom:p])){
        //start drawing new room
        //allow touch
        beginTouch = 1;
        beginRoom = false;
        beginTouchPoint = point;
        toPoint = point;
        fromPoint = point;

		[self setNeedsDisplay];
    }
    
    else if([self isPointWithinRange:p]){
		//for past 1st begin touch
        beginTouch = 1;
        toPoint = beginTouchPoint;
        fromPoint = beginTouchPoint;

		[self setNeedsDisplay];
    }   
    
    
}

-(bool)isPointWithinRange:(CGPoint)point{
	/* isPointWithinRange tests a point to see if it is 
	 within 49 points of the dot, if it is it will return yes
	 */
	int maxX = beginTouchPoint.x+(step-1);
	int minX = beginTouchPoint.x-(step-1);
	int maxY = beginTouchPoint.y+(step-1);
	int minY = beginTouchPoint.y-(step-1);
	
	if(point.x > minX && point.x < maxX){
		if(point.y > minY && point.y < maxY){
			return 1;
		}
	}
	return 0;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	//if started properly (in beginTouch) this will allow us to track
	//the movements of the finger and update the display accordingly
	
	//it ensures that beginTouch is 1, and will only update points that are
	//within the house shape and not inside another roomshape
	
   if (beginTouch){
        CGPoint point = [[touches anyObject] locationInView:self];
		CGPoint p = point;
        point.x = step * floor((point.x / step) );
        point.y = step * floor((point.y / step) );   
		toPoint = point;
        
       if(![self isPointInsideHouse:toPoint] || [self isPointInsideExistingRoom:p]){
		   //isn't inside house or IS inside existing room
           toPoint = beginTouchPoint;
       }else{
           beginTouchPoint=point;
       }
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	//this is called when a touch event ends, we are only interested in the ones
	//which have been started properly by beginTouch
	//we take the end point so long as it is inside the house shape and not
	//inside a current room shape
	
    if(beginTouch){
        CGPoint point = [[touches anyObject] locationInView:self];
		CGPoint p = point;
        point.x = step * floor((point.x / step) );
        point.y = step * floor((point.y / step) );   
        toPoint = point;
        
        if(![self isPointInsideHouse:toPoint] || [self isPointInsideExistingRoom:p]){
            //isn't inside house or IS inside existing room
            toPoint = beginTouchPoint;
        }
        
        [_delegate wallSetStart:fromPoint andSetFinish:toPoint];
        beginTouch = 0;
    
    }
}

-(void)completeRoomShapeCreated{
	//called from VC when it detects that a full shape is made
	
	 beginRoom = true;
	[self rebuildContextImg];
}

-(void)dealloc{
	//called when the view is destroyed
    beginRoom = nil;
    beginTouch = nil;
    wallArray = nil;
    houseArray = nil;
    roomArray = nil;
    arr = nil;
    uiImage1 = nil;
    
    CGContextRelease(offScreenBuffer);
}

@end