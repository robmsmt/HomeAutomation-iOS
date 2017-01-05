//
//  Manager.h
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TriggerTime.h"
#import "TriggerSensor.h"

@class TriggerTime;
@class TriggerSensor;

@interface TriggerManager : NSObject {

}

@property NSMutableArray *triggerTimeObjectsArray;

@property NSMutableArray *triggerSensorObjectsArray;


+(TriggerManager *)sharedTriggerManager;

-(void)setTriggerTime:(NSString *)time andServiceName:(NSNumber *)sName andZone:(NSNumber*)zne andStatus:(NSNumber*)stat  andDesc:(NSString *)desc;


-(void)setTriggerCondition:(NSString *)condition andSensorVal:(NSNumber *)numberFromStr andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN andActionSN :(NSNumber *)actionSN andActionZone:(NSNumber *)actionZN andActionStatus:(NSNumber *)actionStatus andDesc:(NSString *)description;

-(NSMutableArray *)getTriggerTime;
-(NSMutableArray *)getTriggerSensor;

-(void)deleteTimeObjectsAtIndex:(int)index;
-(void)deleteSensorObjectsAtIndex:(int)index;
-(void)saveSettingsToDisk;
@end