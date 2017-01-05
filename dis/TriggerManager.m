//
//  Manager.m
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriggerManager.h"

/* TriggerManager is responsible for holding arrays of time and sensor triggers
 
	it has the ability to store these to disk but currently isn't activated
	as there is no need for this functionality */ 

#define kSettingsData   @"triggerData"
#define kTriggerTime   @"triggerTimeObjectsArray"
#define kTriggerSensor @"triggerSensorObjectsArray"

@implementation TriggerManager

@synthesize triggerTimeObjectsArray;
@synthesize	triggerSensorObjectsArray;

#pragma mark Singleton Methods

//safer singleton than above see roommanager comment
+(TriggerManager *)sharedTriggerManager {
    static dispatch_once_t pred;
    static TriggerManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[TriggerManager alloc] init];
    });
    return shared;
}


-(void)setTriggerTime:(NSString *)time andServiceName:(NSNumber *)sName andZone:(NSNumber *)zne andStatus:(NSNumber *)stat andDesc:(NSString *)desc{
	//creates the trigger time obj with the provided values
	//adds this obj to Trigger time array
	if (triggerTimeObjectsArray == nil){ 
		triggerTimeObjectsArray = [[NSMutableArray alloc]init];
	}
	
	TriggerTime *triggerObj = [[TriggerTime alloc]initWithTime:time andServiceName:sName andZone:zne andStatus:stat andDesc:(NSString *)desc];
	[triggerTimeObjectsArray addObject:triggerObj];
	NSLog(@"TimeTrigger added, timeTrigger array now looks like:%@", triggerTimeObjectsArray);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"timeTriggerObjectsChanged" object:@"CHANGED"]; //notifies ControlViewController of the update
	
}


-(void)setTriggerCondition:(NSString *)condition andSensorVal:(NSNumber *)numberFromStr andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN andActionSN:(NSNumber *)actionSN andActionZone:(NSNumber *)actionZN andActionStatus:(NSNumber *)actionStatus andDesc:(NSString *)description{
	//creates the trigger sensor obj with the provided values
	//adds this obj to Trigger time array
	if (triggerSensorObjectsArray == nil){ 
		triggerSensorObjectsArray = [[NSMutableArray alloc]init];
	}
	
	TriggerSensor *triggerObj = [[TriggerSensor alloc]initWithTriggerCondition:condition andSensorVal:numberFromStr andSensorSN:sensorSN andSensorZone:sensorZN andActionSN:actionSN andActionZone:actionZN andActionStatus:actionStatus andDesc:description];	
	[triggerSensorObjectsArray addObject:triggerObj];
	NSLog(@"SensorTrigger added, sensorTrigger array now looks like:%@", triggerSensorObjectsArray);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"timeTriggerObjectsChanged" object:@"CHANGED"]; //notifies controlviewcontroller of the change

	
	
}

-(NSMutableArray *) getTriggerTime{
    
    return triggerTimeObjectsArray;
}
-(NSMutableArray *) getTriggerSensor{
	
	return triggerSensorObjectsArray;
}

-(void)deleteTimeObjectsAtIndex:(int)index{
	//deletes the time trigger at the provided index
	[triggerTimeObjectsArray removeObjectAtIndex:index];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"timeTriggerObjectsChanged" object:@"CHANGED"];//notifies controlviewcontroller of the change
}
-(void)deleteSensorObjectsAtIndex:(int)index{
	//deletes the sensor trigger at the provided index
	[triggerSensorObjectsArray removeObjectAtIndex:index];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"sensorTriggerObjectsChanged" object:@"CHANGED"]; //notifies controlviewcontroller of the change
}


- (id)init {
	
		if (self = [super init]) {
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
			
			NSData *settingsData = [[NSMutableData alloc] initWithContentsOfFile:dataPath];
			
			if (settingsData) {
				NSLog(@"Existing Triggers Exists");
				NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:settingsData];
				self.triggerTimeObjectsArray = [decoder decodeObjectForKey:kTriggerTime];
				self.triggerSensorObjectsArray = [decoder decodeObjectForKey:kTriggerSensor];
				[decoder finishDecoding];

			}
			else {
				NSLog(@"No Triggers Exists");

			}
		}
    
    return self;
}

- (void)dealloc {
    // Should never be called, present for completeness
}

-(void)saveSettingsToDisk {
	//gives ability to store trigger to disk
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
	
	NSMutableData *settingsData = [NSMutableData data];
	NSKeyedArchiver *encoder =  [[NSKeyedArchiver alloc] initForWritingWithMutableData:settingsData];

	[encoder encodeObject:self.triggerTimeObjectsArray forKey:kTriggerTime];
	[encoder encodeObject:self.triggerSensorObjectsArray forKey:kTriggerSensor];
	[encoder finishEncoding];
	[settingsData writeToFile:dataPath atomically:YES];

}



@end