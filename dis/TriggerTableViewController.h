//
//  TriggerTableViewController.h
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTriggerViewController.h"

@interface TriggerTableViewController : UITableViewController<toTableDelegate>
{
	
	TimeTriggerViewController *triggerModalPopover;
	NSMutableArray *timeTriggerArray;
	NSMutableArray *timeDescArray;
	NSMutableArray *sensorTriggerArray;
	NSMutableArray *sensorDescArray;
	
}
- (IBAction)addTriggerBtnPressed:(UIBarButtonItem *)sender;
-(void)savedButtonPressed;
@end
