//
//  Manager.m
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HouseManager.h"

//HouseManager is used to store the house data for the application, 
//it stores an array of points which are the coordinates for the house
//and it stores the number of floors as an NSNumber


//the defines are used for storing data, they can be modified if 
//you want to change the name of the data when stored for example
//however they must also be changed in firstViewController too
#define kSettingsData   @"houseData"
#define kHousePoints   @"housePoints"
#define kNumberOfFloors	@"numberOfFloors"

@implementation HouseManager



#pragma mark Singleton Methods

//safer singleton than above see roommanager comment
//ensures that only one can run at any time
+(HouseManager *)sharedHouseManager {
    static dispatch_once_t pred;
    static HouseManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[HouseManager alloc] init];
    });
    return shared;
}

//set house points is called by SetupHouseViewController when invoked by the view
//the process looks like this HouseView-->SetupHouseViewController-->HouseManager
//the reason for this is that to keep with the MVC pattern it's unwise to have the 
//view and model communicating directly.

-(void)setHousePoints:(CGPoint)start andSetFinish:(CGPoint)finish{
	//if array isn't initalised it will alloc init it.
    if (housePoints == nil){ 
        housePoints = [[NSMutableArray alloc]init];
    }
	//we add these points to the array
         [housePoints addObject:[NSValue valueWithCGPoint:start]];
         [housePoints addObject:[NSValue valueWithCGPoint:finish]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"housePointsChanged" object:@"CHANGED"]; //this notifies the VC that the array has changed and causes the view to update.
}

-(void)setNumberOfFloors:(NSNumber*)num{
	//simple setter for the number of floors
	numberOfFloors = num;
}

-(NSMutableArray *) getHousePoints{
    //simple getter for housePoints array
    return housePoints;
}

-(NSNumber *) getNumberOfFloors{
	//simple getter for number of floors
	return numberOfFloors;
}


-(void)clearAllPoints{
	//clears all the points in the array by removing them and posts notification
    [housePoints removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"housePointsChangedClear" object:@"CHANGED"];
}

- (id)init {
	//called on init
	//detects if data exists- if so load it up
	//else do nothing
		if (self = [super init]) {
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
			
			NSData *settingsData = [[NSMutableData alloc] initWithContentsOfFile:dataPath];
			
			if (settingsData) {
				NSLog(@"Existing houseData Exists");
				NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:settingsData];
				housePoints = [decoder decodeObjectForKey:kHousePoints];
				numberOfFloors = [decoder decodeObjectForKey:kNumberOfFloors];
				[decoder finishDecoding];
			}
			else {
				NSLog(@"No houseData Exists");

			}
		}
    
    return self;
}

- (void)dealloc {
    // Should never be called
}

-(void)saveSettingsToDisk {
	//allows us to save the data to disk
	//uses the NSCODING to encode the data to a file
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kSettingsData];
	
	NSMutableData *settingsData = [NSMutableData data];
	NSKeyedArchiver *encoder =  [[NSKeyedArchiver alloc] initForWritingWithMutableData:settingsData];

	[encoder encodeObject:housePoints forKey:kHousePoints];
	[encoder encodeObject:numberOfFloors forKey:kNumberOfFloors];
	[encoder finishEncoding];
	[settingsData writeToFile:dataPath atomically:YES];
}



@end