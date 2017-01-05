//
//  device.h
//  dis
//
//  Created by Robert Smith on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject<NSCoding>{
    
    NSString *deviceName;
    NSString *deviceLocation;
	NSString *deviceImg;
    NSValue *devicePoint;
    NSNumber *floor;
    NSNumber *deviceServiceName;
    NSNumber *deviceZone;
    NSNumber *deviceType; //i/o
	
	NSMutableArray *notifications;
	NSMutableArray *timeStamps;
    
}



-(id)initWithDeviceName:(NSString *)name andImg:(NSString*)img atPoint:(CGPoint)point withServiceName:(NSNumber*)devServ andDeviceZone:(NSNumber*)devZone andDeviceType:(NSNumber*)devType andFloor:(NSNumber *)flr;

-(void)isDevice;

-(NSString *)returnName;

-(NSString *)returnImg;

-(NSValue *)returnPoint;

-(NSNumber*)returnServiceName;

-(NSNumber*)returnZone;

-(NSNumber*)returnDeviceType;

-(NSNumber*)returnFloor;

-(NSMutableArray *)returnNotifications;

-(NSMutableArray *)returnTimestamps;

-(void)addNotification:(NSString*)notif;

-(void)addTimeStamp:(NSString *)time;

@end
