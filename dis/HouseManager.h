//
//  Manager.h
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HouseManager : NSObject {
    NSMutableArray *housePoints;
	NSNumber *numberOfFloors;
}


+(HouseManager *)sharedHouseManager;
-(void)setHousePoints:(CGPoint)start andSetFinish:(CGPoint)finish;
-(void)setNumberOfFloors:(NSNumber*)num;
-(NSMutableArray *)getHousePoints;
-(NSNumber *)getNumberOfFloors;
-(void)clearAllPoints;
-(void)saveSettingsToDisk;
@end