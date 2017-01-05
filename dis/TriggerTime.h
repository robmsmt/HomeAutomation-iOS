//
//  TriggerTime.h
//  dis
//
//  Created by Robert Smith on 10/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TriggerTime : NSObject{
	
	NSString *timeValue;
	NSNumber *serviceName;
	NSNumber *zone;
	NSNumber *status;//0/1
	NSString *descriptionValue;
}

-(id)initWithTime:(NSString *)time andServiceName:(NSNumber *)sName andZone:(NSNumber*)zne andStatus:(NSNumber*)stat andDesc:(NSString*)desc;
-(void)isTriggerTime;
-(NSString *)returnTime;
-(NSNumber *)returnServiceName;
-(NSNumber *)returnZone;
-(NSNumber *)returnStatus;
-(NSString *)returnDesc;

@end
