//
//  Manager.h
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"

@class Room;

@interface RoomManager : NSObject {

}

@property NSMutableArray *roomPoints;
@property NSMutableArray *roomObjects;


+(RoomManager *)sharedRoomManager;
-(void)setRoomPoints:(CGPoint)start andSetFinish:(CGPoint)finish;
-(NSMutableArray *)getRoomPoints;

-(void)createRoomObject:(NSString*)name andColor:(UIColor*)color andFloor:(NSNumber*)flr;
-(void)deleteAllRoomObjects;
-(void)deleteLastRoom;
-(void)saveSettingsToDisk;
@end