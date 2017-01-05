//
//  TriggerSensor.m
//  dis
//
//  Created by Robert Smith on 10/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 This class represents the trigger sensor objects which are made up
 of many instancevariables used to store the trigger information
 
 It used as a store of information for the sensortriggers, on init it creates the obj setting the 
 appropriate values
 
 */

#import "TriggerSensor.h"

@implementation TriggerSensor


-(id)initWithTriggerCondition:(NSString *)condition andSensorVal:(NSNumber *)numberFromStr andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN andActionSN:(NSNumber *)actionSN andActionZone:(NSNumber *)actionZN andActionStatus:(NSNumber *)actionStat andDesc:(NSString *)description{
	
	conditionValue = condition;
	sensorValue = numberFromStr;
	
	sensorServiceName = sensorSN;
	sensorZone = sensorZN;
	actionServiceName = actionSN;
	actionZone = actionZN;
	actionStatus = actionStat;	

	descriptionValue = description;
	return self;
}

-(void)isTriggerSensor{
    //check to make sure that only triggersensor objects are handled
}

//the following methods simply return the value of each of the variables
-(NSString *)returnCondition{
    return conditionValue;
}
-(NSNumber *)returnSensor{
	return sensorValue;
}

-(NSString*)returnDesc{
	return descriptionValue;
}

-(NSNumber *)returnSensorSN{
	return sensorServiceName;
}

-(NSNumber *)returnSensorZN{
	return sensorZone;
}

-(NSNumber *)returnActionSN{
	return actionServiceName;
}

-(NSNumber *)returnActionZN{
	return actionZone;
}

-(NSNumber *)returnActionStatus{
	return actionStatus;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	//[encoder encodeObject:deviceName forKey:kDeviceName];
	//since we aren't saving the triggers to disk this is empty
	//but if we were to each value would be encoded here
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		//deviceName = [decoder decodeObjectForKey:kDeviceName];
		//since we aren't saving the triggers to disk this is empty
		//but if we were to each value would be DECODED here
		
	}
	return self;
}

@end
