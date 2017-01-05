//
//  device.m
//  dis
//
//  Created by Robert Smith on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 The device class is needed to store the needed information 
 about any of the devices, this includes name,location,img,point,floor,SN,ZN,type
 
 */

#import "Device.h"


#define kDeviceName			@"deviceName"
#define kDeviceLocation		@"deviceLocation"
#define kDeviceImg			@"deviceImg"
#define kDevicePoint		@"devicePoint"
#define kFloor				@"floor"
#define kDeviceServiceName	@"deviceServiceName"
#define kDeviceZone			@"deviceZone"
#define kDeviceType			@"deviceType"
#define kNotifications		@"notifications"
#define kTimeStamps			@"timeStamps"

@implementation Device


-(id)initWithDeviceName:(NSString *)name andImg:(NSString*)img atPoint:(CGPoint)point withServiceName:(NSNumber*)devServ andDeviceZone:(NSNumber*)devZone andDeviceType:(NSNumber*)devType andFloor:(NSNumber *)flr{
    //when the object is created 
    //set all relavent points for the object
    
    deviceName = name;
	deviceImg = img;
    devicePoint = [NSValue valueWithCGPoint:point];
	floor = flr; 
    deviceServiceName = devServ;
    deviceZone = devZone;
    deviceType = devType;
	
	notifications = [[NSMutableArray alloc]initWithCapacity:3];
	timeStamps = [[NSMutableArray alloc]initWithCapacity:3];
    
    return self;
}

-(void)updateObjectLocation:(NSValue*)withPoint{
	//update object with location, can be called from SetupDevicesVC or ControlVC
    devicePoint = withPoint;
    NSLog(@"updated with point:%@", withPoint);
}
            
-(void)isDevice{
    //check to make sure that only device objects are handled
}

//the returns below are used to get object values inside the SetupDevicesVC or ControlVC classes

-(NSString *)returnName{
    return deviceName;
}

-(NSString *)returnImg{
	return deviceImg;
}

-(NSValue *)returnPoint{
    return devicePoint;
}

-(NSNumber*)returnServiceName{
    return deviceServiceName;
}

-(NSNumber*)returnZone{
    return deviceZone;
}

-(NSNumber*)returnDeviceType{
    return deviceType;
}

-(NSNumber*)returnFloor{
	return floor;
}

-(NSMutableArray *)returnNotifications{
	return notifications;
}

-(NSMutableArray *)returnTimestamps{
	
	return timeStamps;
}

-(void)addNotification:(NSString *)notif{
	//adds notification to the notification array
	//if there are 3 or more objs in the array it will
	//remove the oldest one first
	if([notifications count] >= 3){
		NSLog(@"Not enough room destroying oldest obj");
		[notifications removeObjectAtIndex:0];
		[notifications addObject:notif];
	} else{
		[notifications addObject:notif];
	}
}

-(void)addTimeStamp:(NSString *)time{
	//adds timestamp to the array
	//if there are 3 or more objs in the array it will
	//remove the oldest one first
	if([timeStamps count] >= 3){
		//same as method above
		[timeStamps removeObjectAtIndex:0];
		[timeStamps addObject:time];
	} else{
		[timeStamps addObject:time];
	}
	
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	//encodes the obj for writting to disk
	[encoder encodeObject:deviceName forKey:kDeviceName];
	[encoder encodeObject:deviceLocation forKey:kDeviceLocation];
	[encoder encodeObject:deviceImg forKey:kDeviceImg];
	[encoder encodeObject:devicePoint forKey:kDevicePoint];
	[encoder encodeObject:floor	forKey:kFloor];
	[encoder encodeObject:deviceServiceName forKey:kDeviceServiceName];
	[encoder encodeObject:deviceZone forKey:kDeviceZone];
	[encoder encodeObject:deviceType forKey:kDeviceType];
	[encoder encodeObject:notifications forKey:kNotifications];
	[encoder encodeObject:timeStamps forKey:kTimeStamps];
}

- (id)initWithCoder:(NSCoder *)decoder {
	//decodes the obj when reading from disk
	if (self = [super init]) {
		deviceName = [decoder decodeObjectForKey:kDeviceName];
		deviceLocation = [decoder decodeObjectForKey:kDeviceLocation];
		deviceImg = [decoder decodeObjectForKey:kDeviceImg];
		devicePoint = [decoder decodeObjectForKey:kDevicePoint];
		floor = [decoder decodeObjectForKey:kFloor];
		deviceServiceName = [decoder decodeObjectForKey:kDeviceServiceName];
		deviceZone = [decoder decodeObjectForKey:kDeviceZone];
		deviceType = [decoder decodeObjectForKey:kDeviceType];
		notifications = [decoder decodeObjectForKey:kNotifications];
		timeStamps = [decoder decodeObjectForKey:kTimeStamps];
	}
	return self;
}


@end
