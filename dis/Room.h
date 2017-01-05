//
//  Room.h
//  dis
//
//  Created by Robert Smith on 24/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject <NSCoding>{
    
    NSString *roomName;
    UIColor *roomColour;
    NSMutableArray *pointsArr;
	NSNumber *floor;
    
}


-(id)initWithName:(NSString *)name andColour:(UIColor*)colour andPoints:(NSMutableArray *)points andFloor:(NSNumber *)flr;

-(void)isRoomType;
-(NSString *)returnName;
-(UIColor*)returnColour;
-(NSMutableArray *)returnArray;
-(NSNumber *)returnFloor;
@end
