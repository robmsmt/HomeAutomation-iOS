//
//  TriggerTime.m
//  dis
//
//  Created by Robert Smith on 10/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 This class represents the trigger TIME objects which are made up
 of many instancevariables used to store the trigger information
 
 It used as a store of information for the time triggers, on init it creates the obj setting the 
 appropriate values
 
 */



#import "TriggerTime.h"

@implementation TriggerTime



-(id)initWithTime:(NSString *)time andServiceName:(NSNumber *)sName andZone:(NSNumber *)zne andStatus:(NSNumber*)stat andDesc:(NSString *)desc{
	
	timeValue = time;
	serviceName = sName;
	zone = zne;
	status = stat;
	descriptionValue = desc;
	
	return self;
}

-(void)isTriggerTime{
    //check to make sure that only triggertime objects are handled
}

//the following methods simply return the value of each of the variables
-(NSString *)returnTime{
    return timeValue;
}
-(NSNumber *)returnServiceName{
	return serviceName;
}
-(NSNumber *)returnZone{
	return zone;	
}
-(NSNumber *)returnStatus{
	return status;
}

-(NSString *)returnDesc{
	return descriptionValue;
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
