//
//  SharedNetworking.h
//  dis
//
//  Created by Robert Smith on 13/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Import the SQLite database framework
@class GCDAsyncSocket;

@protocol SharedNetworkDelegate
@required
- (void) networkResponseDevID:(NSMutableArray *)aDevID andDevName:(NSMutableArray *)aDevName andDevImg:(NSMutableArray *)aDevImg andServiceName:(NSMutableArray	*)aServName andZone:(NSMutableArray *)aZone andDevType:(NSMutableArray *)aDevType;
@optional 
-(void) networkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int)index;
-(void) networkUpdateWithBatteryValue:(NSString *)battStr andBatteryFloat:(float)battfloat;

-(void)networkUpdateToTriggerWithVal:(NSNumber *)val andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN;

-(void)triggerNetworkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int) index;

@end
@interface SharedNetworking : NSObject{
	
	
		NSString *databaseName;
		NSString *databasePath;
			
	
	GCDAsyncSocket *asyncSocket;
	id delegate;
	NSMutableArray* receivedArray;
	NSMutableArray* deviceArray;
	int tagNum;
	
}

-(id)initWithDelegate:(id)aDelegate;
-(void)disconnect;
-(void)performType0DataSendWithSN:(NSNumber*)serviceName andZone:(NSNumber*)zone andSetStatus:(bool)status andBtnId:(int)btnid;
-(void)performType0DataUpdateWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andBtnId:(int)btnid;
-(void)performType1DataSendWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andBtnId:(int)btnid;
-(void)performType2DataSendWithSN:(NSNumber *)serviceName andZone:(NSNumber *)zone andSetStatus:(NSNumber*)value andBtnId:(int)btnid;
@end
	