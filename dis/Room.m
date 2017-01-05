//
//  Room.m
//  dis
//
//  Created by Robert Smith on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 The room class defines an object which contains name,colour,points and floor instancevariables
 
 These values are all set on initialisation. This class is owned and controlled by the roomManager
 
 */


#import "Room.h"

#define kRoomName	@"roomName"
#define kRoomColour @"roomColour"
#define kPointsArr	@"pointsArr"
#define kFloor		@"floor"

@implementation Room



-(id)initWithName:(NSString *)name andColour:(UIColor *)colour andPoints:(NSMutableArray *)points andFloor:(NSNumber *)flr{
	//on init we set the variables which are passed as parameters
    pointsArr = [[NSMutableArray alloc] initWithArray:points];
    roomName = name;
    roomColour = colour;
    floor = flr;
    
    NSLog(@"roomOBJ created with name:%@, colour:%@ and points:%@ and floor:%@", roomName, roomColour, pointsArr, floor);
    
    return self;
}
            
-(void)isRoomType{
    //check to make sure that only room objects are handled
}


//the following return methods simply return the instance variables that they correspond to
//this is so that other classes can access these values
-(NSString *)returnName{
    return roomName;
}

-(UIColor *)returnColour{
    
    return roomColour;
}

-(NSMutableArray *)returnArray{
    
    return pointsArr;
}

-(NSNumber *)returnFloor{
	
	return floor;	
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	//encode the variables for writing to disk
	[encoder encodeObject:roomName forKey:kRoomName];
	[encoder encodeObject:roomColour forKey:kRoomColour];
	[encoder encodeObject:pointsArr forKey:kPointsArr];
	[encoder encodeObject:floor forKey:kFloor];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		//decode the variables for writing to disk
		roomName = [decoder decodeObjectForKey:kRoomName];
		roomColour = [decoder decodeObjectForKey:kRoomColour];
		pointsArr = [decoder decodeObjectForKey:kPointsArr];
		floor = [decoder decodeObjectForKey:kFloor];
	}
	return self;
}
@end
