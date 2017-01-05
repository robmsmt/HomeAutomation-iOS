//
//  SharedViewController.m
//  dis
//
//  Created by Robert Smith on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 This shared VC is responsible for common components between ControlViewController
 and SetupDevicesViewController
 
 This reduces the amount of code and errors that can exist and makes it much more managable
 
 common instance variables:
 houseArray, roomArray, deviceArray, arr, offScreenBuffer, currentFloor, numberOfFloors.
 
 common methods:
 1- setupBuffer
 2- getHousePath
 3- getRoomsPath
 4- drawHouse
 5- drawRooms
 6- isPointInsideHouse
 7- deleteAllButtons

 
 */


#import "SharedViewController.h"
#import "RoomManager.h"
#import "HouseManager.h"
#import "DevicesManager.h"

@interface SharedViewController ()

@end

@implementation SharedViewController

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

-(void)getHousePath{
	//gets the path of the house and stores in the array houseArray
    HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    houseArray = [sharedHouseManager getHousePoints];
	
}

-(void)getRoomsPath{
    //gets the rooms objects (not path) and stores in roomArray
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    roomArray = [sharedRoomManager roomObjects];
    
}

-(void)drawHouse{
    //this method is responsible for drawing the house
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
    
    CGContextRestoreGState(offScreenBuffer);
    CGPathRelease(path);
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
				
				
				//draw room layout path
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

-(bool)isPointInsideHouse:(CGPoint)point{
	//this function checks to see if a point provided
	//is inside the house path (houseArray)
	//if it is returns YES, else NO
	
	
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

-(void)deleteAllButtons{
	//removes all buttons inside the house
	for (UIView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
			if([self isPointInsideHouse:subview.center]){
				[subview removeFromSuperview];
			}
		}
	}
}



@end
