//
//  ControlDevicePopupViewController.h
//  dis
//
//  Created by Robert Smith on 05/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/* This viewcontroller doesn't know much, 
 first it is sent the device type to work out which type of display to load
 second it receives any relavent notifications and puts them in the table
 third is optional if the device simply returns information such as temperature
 it will receive those values and display them.
 
 */

@protocol ControlDevicePopoverDelegate
- (void)performNetworkingWithDevice:(int)index turn:(BOOL)status;
- (void)performNetworkUpdateWithDevice:(int)tag;
- (void)triggerButtonPressed:(int)tagIndex;
@end

@interface ControlDevicePopupViewController : UIViewController {
	
	
	id<ControlDevicePopoverDelegate> _delegate;
	
	__weak IBOutlet UILabel *currentLabel;
	NSString* name;
	int tag;
	
	NSNumber *deviceType;
	NSString *deviceImg;
	
	__weak IBOutlet UIButton *deviceImage;
	__weak IBOutlet UISwitch *deviceSwitch;
	__weak IBOutlet UILabel *deviceBattery;
	__weak IBOutlet UIProgressView *batteryBar;
	__weak IBOutlet UILabel *deviceValue;
	__weak IBOutlet UIButton *deviceTriggerBtn;
	__weak IBOutlet UITableView *tableView2;
	__weak IBOutlet UIPickerView *rangePicker;

	NSMutableArray *notificationsArr;
	NSMutableArray *timestampArr;
}

@property (nonatomic, retain) id<ControlDevicePopoverDelegate> delegate;


- (IBAction)imageButtonPressed:(UIButton *)sender;
- (IBAction)switchChanged:(UISwitch *)sender;
-(void)setName:(NSString *)devname;
-(void)setDeviceType:(NSNumber *)devnum withTag:(int)devTag withNotifications:(NSMutableArray *)arr andTimeStamp:(NSMutableArray *)timeArr withImg:(NSString *)imgName;
- (IBAction)triggerBtnPressed:(UIButton*)sender;
-(void)updateTableWithNotifications:(NSArray *)notifArray andTimeStamp:(NSArray *)timeArray;

-(void)updateValue:(NSString *)stringVal;
-(void)updateBattery:(NSString *)batt andBatteryFloat:(float)battFloat;
-(void)updateImg:(NSString *)img andState:(bool)state;


@end
