//
//  DeviceManager.h
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"

@class Device;

@interface DevicesManager : NSObject {

}

@property NSMutableArray *deviceObjectsArray;

+(DevicesManager *)sharedDevicesManager;
-(NSNumber *)createWithDeviceName:(NSString *)name andImg:(NSString*)img atPoint:(CGPoint)point withServiceName:(NSNumber*)devServ andDeviceZone:(NSNumber*)devZone andDeviceType:(NSNumber*)devType andFloor:(NSNumber *)flr;
-(void)updateObjectAtIndex:(int)sender withLocation:(CGPoint)point;
-(void)saveSettingsToDisk;
-(void)deleteAllDeviceObjects;
-(void)undoLastDevice;
@end