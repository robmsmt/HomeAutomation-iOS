//
//  DeviceManager.m
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//This simple manager holds an array of device objects
//note that it had to be called DevicesManager rather than DeviceManager as the latter was already taken by apple

#import "DevicesManager.h"

#define kSettingsData   @"deviceData"
#define kDeviceArray	@"deviceObjectsArray"

@implementation DevicesManager


@synthesize deviceObjectsArray;

#pragma mark Singleton Methods

+(DevicesManager *)sharedDevicesManager {
	//safer singleton
	//ensures that only one is running at any one time
    static dispatch_once_t pred;
    static DevicesManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[DevicesManager alloc] init];
	});

    return shared;
}

-(NSNumber *)createWithDeviceName:(NSString *)name  andImg:(NSString*)img atPoint:(CGPoint)point withServiceName:(NSNumber*)devServ andDeviceZone:(NSNumber*)devZone andDeviceType:(NSNumber*)devType andFloor:(NSNumber *)flr{    

	//add device to device manager, we create a device obj by supplying the needed parameters
	//we then add this obj id to the deviceObjectsArray
	//finally we return the index number that the newest device is at
	
    if(!deviceObjectsArray){ //ensure array exists before adding to it
        deviceObjectsArray = [[NSMutableArray alloc] init];
    }  
    
    Device *deviceObj = [[Device alloc]initWithDeviceName:(NSString *)name  andImg:img atPoint:(CGPoint)point withServiceName:(NSNumber*)devServ andDeviceZone:(NSNumber*)devZone andDeviceType:(NSNumber*)devType andFloor:flr];
    [deviceObjectsArray addObject:deviceObj];

    //NSLog(@"Device added, device array now looks like:%@", deviceObjectsArray );
	return [NSNumber numberWithInt:[deviceObjectsArray indexOfObject:deviceObj]] ;
	
}

-(void)updateObjectAtIndex:(int)ind withLocation:(CGPoint)point{
   //update objects location when it has stopped moving
    
        
		if ([[deviceObjectsArray objectAtIndex:ind] respondsToSelector:@selector(isDevice)]) {
                
				[[deviceObjectsArray objectAtIndex:ind] 
                                    performSelector: @selector(updateObjectLocation:) 
                                         withObject:[NSValue valueWithCGPoint:point]];
                
		}    
    
}

-(void)dealloc {
    // Should never be called, but just here completeness.
}

-(id)init {
	//called on init
	//detects if data exists- if so load it up
	//else do nothing

		if (self = [super init]) {
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
			
			NSData *settingsData = [[NSMutableData alloc] initWithContentsOfFile:dataPath];
			
			if (settingsData) {
				NSLog(@"Existing deviceData Exists");
				NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:settingsData];				
				self.deviceObjectsArray = [decoder decodeObjectForKey:kDeviceArray];
				[decoder finishDecoding];
			}
			else {
				NSLog(@"No deviceData Exists");
			}
		}
    return self;
}

-(void)saveSettingsToDisk {
	//allows us to save the data to disk
	//uses the NSCODING to encode the data to a file

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
	
	NSMutableData *settingsData = [NSMutableData data];
	NSKeyedArchiver *encoder =  [[NSKeyedArchiver alloc] initForWritingWithMutableData:settingsData];
	[encoder encodeObject:self.deviceObjectsArray forKey:kDeviceArray];
	[encoder finishEncoding];
	[settingsData writeToFile:dataPath atomically:YES];
}

-(void)deleteAllDeviceObjects{
	//removes all device objects
	[deviceObjectsArray removeAllObjects];
}

-(void)undoLastDevice{
	//removes last device
	if([deviceObjectsArray count] > 0){
		[deviceObjectsArray removeLastObject];
	}

}


@end