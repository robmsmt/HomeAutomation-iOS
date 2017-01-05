//
//  SettingsTableViewController.h
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SettingsTablePopoverDelegate
- (void)resetAll;
- (void)resetRooms;
- (void)resetDevices;
@end

@interface SettingsTableViewController : UITableViewController{
    NSMutableArray *textList;

    id<SettingsTablePopoverDelegate> _delegate;


}
@property (nonatomic, retain) id<SettingsTablePopoverDelegate> delegate;
@end
