//
//  TriggerSensor.h
//  dis
//
//  Created by Robert Smith on 10/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TriggerSensor : NSObject{
	
	NSString *conditionValue;
	NSNumber *sensorValue;
	NSString *descriptionValue;
	NSNumber *sensorServiceName;
	NSNumber *sensorZone;
	NSNumber *actionServiceName;
	NSNumber *actionZone;
	NSNumber *actionStatus;
	
}

-(id)initWithTriggerCondition:(NSString *)condition andSensorVal:(NSNumber *)numberFromStr andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN andActionSN :(NSNumber *)actionSN andActionZone:(NSNumber *)actionZN andActionStatus:(NSNumber *)actionStat andDesc:(NSString *)description;
-(void)isTriggerSensor;
-(NSString *)returnCondition;
-(NSNumber *)returnSensor;
-(NSString *)returnDesc;
-(NSNumber *)returnSensorSN;
-(NSNumber *)returnSensorZN;
-(NSNumber *)returnActionSN;
-(NSNumber *)returnActionZN;
-(NSNumber *)returnActionStatus;

@end
