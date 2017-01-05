//
//  DeviceTableViewController.h
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedNetworking.h"

@class SharedNetworking;


@protocol DeviceTablePopoverDelegate
- (void)deviceNameSelected:(NSString*)name andImageName:(NSString*)imgname andServiceName:(NSNumber*)serv andZone:(NSNumber*)zone andDevType:devType;
@end

@interface DeviceTableViewController : UITableViewController <SharedNetworkDelegate>{
	SharedNetworking *sharedNetworking;
	NSMutableArray *listOfDevID;
    NSMutableArray *listOfDevices;
    NSMutableArray *listOfImages;
	NSMutableArray *listOfServiceNames;
	NSMutableArray *listOfZones;
	NSMutableArray *listOfDevType;
    id<DeviceTablePopoverDelegate> _delegate;
    

}
@property (nonatomic, retain) id<DeviceTablePopoverDelegate> delegate;

- (void) networkResponseDevID:(NSMutableArray *)aDevID andDevName:(NSMutableArray *)aDevName andDevImg:(NSMutableArray *)aDevImg andServiceName:(NSMutableArray *)aServName andZone:(NSMutableArray *)aZone andDevType:(NSMutableArray *)aDevType;
@end
