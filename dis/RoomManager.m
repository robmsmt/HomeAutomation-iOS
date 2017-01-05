//
//  Manager.m
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//RoomManager is used to store the room data for the application, 
//it stores an array of room objects which means any VC can recall the room data

#import "RoomManager.h"

#define kSettingsData   @"roomData"
#define kRoomPoints		@"roomPoints"
#define kRoomObjects	@"roomObjects"

@implementation RoomManager

@synthesize roomPoints;
@synthesize roomObjects;

#pragma mark Singleton Methods


+(RoomManager *)sharedRoomManager {
	//safer singleton
	//ensures that only 1 instance of this class can exist (see sys implementation for details)
    static dispatch_once_t pred;
    static RoomManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[RoomManager alloc] init];
    });
    return shared;
}

-(void)setRoomPoints:(CGPoint)start andSetFinish:(CGPoint)finish{
    
    //the set room points method is called by setupRoomsVC
	//we add the points to the roomPoints array
	//then an notification is triggered and picked up by the VC causing the VC to update
	
    if (roomPoints == nil){ 
        roomPoints = [[NSMutableArray alloc]init];
    }
         [roomPoints addObject:[NSValue valueWithCGPoint:start]];
         [roomPoints addObject:[NSValue valueWithCGPoint:finish]];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"roomPointsChanged" object:@"CHANGED"];
    
}

-(NSMutableArray *) getRoomPoints{
    //returns the roomPoints
    return roomPoints;
}

-(void)createRoomObject:(NSString*)name andColor:(UIColor*)color andFloor:(NSNumber *)flr{
    //creates a room obj, this is sent by the setupRoomsViewController when it detects a complete shape
    if(!roomObjects){
        roomObjects = [[NSMutableArray alloc] init];
    }  
    //this new room obj is added to the roomObjects array
    Room *roomObj = [[Room alloc]initWithName:name andColour:color andPoints:roomPoints andFloor:flr];
    [roomObjects addObject:roomObj];
	//notification is sent to cause depandancies to update
    [[NSNotificationCenter defaultCenter] postNotificationName:@"roomObjectsChanged" object:@"CHANGED"];

}

-(void)deleteAllRoomObjects{
	//deletes all room objs and existing points (unfinished rooms)
	//then causes updates to be triggered with the notification
	
    [roomObjects removeAllObjects];
	[roomPoints removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"roomObjectsChanged" object:@"CHANGED"];
	  [[NSNotificationCenter defaultCenter] postNotificationName:@"roomPointsChanged" object:@"CHANGED"];
    
}

-(void)deleteLastRoom{
    
	if([roomPoints count]>0){
		//delete room points first
		[roomPoints	removeAllObjects];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"roomPointsChanged" object:@"CHANGED"];
		
		
	} else if([roomObjects count]>0){
		//delete last room
		[roomObjects removeLastObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"roomObjectsChanged" object:@"CHANGED"];
	}
	
	
}

-(void)dealloc {
    // Should never be called, present for completeness.
}

-(id)init {
	
	//on init
	//loads the data if it exists, else does nothing
	
		if (self = [super init]) {
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
			NSData *settingsData = [[NSMutableData alloc] initWithContentsOfFile:dataPath];
			
			if (settingsData) {
				NSLog(@"Existing roomData Exists");
				NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:settingsData];

				self.roomPoints = [decoder decodeObjectForKey:kRoomPoints];
				self.roomObjects = [decoder decodeObjectForKey:kRoomObjects];
				[decoder finishDecoding];

			}
			else {
				NSLog(@"No roomData Exists");

			}
		}
    
    return self;
}

-(void)saveSettingsToDisk {
	//causes the roomPoints and roomObjects to be saved to disk
	//this is envoked by the user pressing the done button in the UINAVBAR
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
	
	NSMutableData *settingsData = [NSMutableData data];
	NSKeyedArchiver *encoder =  [[NSKeyedArchiver alloc] initForWritingWithMutableData:settingsData];
	[encoder encodeObject:self.roomPoints forKey:kRoomPoints];
	[encoder encodeObject:self.roomObjects forKey:kRoomObjects];
	[encoder finishEncoding];
	[settingsData writeToFile:dataPath atomically:YES];

}

@end