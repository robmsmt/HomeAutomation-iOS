//
//  ControlViewController.h
//  dis
//
//  Created by Robert Smith on 28/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlDevicePopupViewController.h"
#import "SettingsTableViewController.h"
#import "TriggerViewController.h"
#import "SharedNetworking.h"
#import "SharedViewController.h"

@class SharedNetworking;

//this VC has many delegates due to its central position in the app
@interface ControlViewController : SharedViewController  <UIGestureRecognizerDelegate, NSStreamDelegate, UIPopoverControllerDelegate, ControlDevicePopoverDelegate, SettingsTablePopoverDelegate>
{	
	SharedNetworking *sharedNetworking;
	ControlDevicePopupViewController *devicePopover;
	TriggerViewController *triggerModalPopover;
    
    __weak IBOutlet UIImageView *imageView1;
	__weak IBOutlet UIBarButtonItem *lastDeviceButton;
	__weak IBOutlet UIBarButtonItem *settingsButton;
	
	NSTimer *timer;
	
	int tagNum;
	int deleteIndex;
    bool moveableMode;
	
	UIPanGestureRecognizer* panGesture;
	UILongPressGestureRecognizer* longHoldGesture;
	
	//triggers
	NSMutableArray *timeTriggerArray;
	NSMutableArray *timeArray;
	NSMutableArray *sensorTriggerArray;
	//sensor triggers
	NSMutableArray *triggerConditionValue;
	NSMutableArray *triggerSensorValue;
	NSMutableArray *triggerSensorServiceName;
	NSMutableArray *triggerSensorZone;
	NSMutableArray *actionServiceName;
	NSMutableArray *actionZone;
	NSMutableArray *actionStatus;
}


@property (retain, nonatomic) UIPopoverController *devicePopoverController;
@property (retain, nonatomic) UIPopoverController *settingsPopoverController;
@property (retain, nonatomic) UIStoryboardPopoverSegue* popSegue;

- (IBAction)LastDeviceBtnPressed:(UIBarButtonItem *)sender;
- (IBAction)settingsButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender;

- (void)performNetworkingWithDevice:(int)index turn:(BOOL)status;
- (void)performNetworkUpdateWithDevice:(int)tag;
- (void)triggerButtonPressed:(int)tagIndex;
- (void)resetAll;
- (void)resetRooms;
- (void)resetDevices;
- (void)trigger:(NSTimer *)aTimer;
- (void)networkUpdateWithBatteryValue:(NSString *)battStr andBatteryFloat:(float)battfloat;
- (void)networkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int)index;
-(void)triggerNetworkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int) index;
- (void)networkUpdateToTriggerWithVal:(NSNumber *)val andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN;

@end
