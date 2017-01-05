//
//  SharedViewController.h
//  dis
//
//  Created by Robert Smith on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedViewController : UIViewController{
	
	NSMutableArray* houseArray;
	NSMutableArray* roomArray;
	NSMutableArray* deviceArray;
	NSMutableArray* arr;
	CGContextRef offScreenBuffer;
	
	int currentFloor;
	int numberOfFloors;
}

-(void)setupBuffer;
-(void)getHousePath;
-(void)getRoomsPath;
-(void)drawHouse;
-(void)drawRooms;
-(void)deleteAllButtons;
-(bool)isPointInsideHouse:(CGPoint)point;


@end
