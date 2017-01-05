//
//  RoomView.h
//  dis
//
//  Created by Robert Smith on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@protocol RoomDelegate
- (void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish;
@end

@interface RoomView :UIView{
    CGPoint fromPoint;
    CGPoint toPoint;
    CGPoint startRoomPoint;
    bool beginRoom;
    bool beginTouch;
    CGPoint beginTouchPoint;
    CGContextRef offScreenBuffer;
    NSMutableArray* wallArray; //used to draw non complete shapes
    NSMutableArray* houseArray; //draw house
	int numberOfFloors;
	int currentFloor;
    NSMutableArray* roomArray;
    NSMutableArray* arr;
    UIImage *uiImage1;
}

@property (assign) id  <RoomDelegate> delegate; 
-(void)rebuildContextImg;
-(void)setFloorLevel:(int)flr;
-(void)setupVariables;
-(void)completeRoomShapeCreated;
-(void)updateRooms;

@end
