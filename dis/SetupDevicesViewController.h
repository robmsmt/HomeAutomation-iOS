//
//  SetupDevicesViewController.h
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceTableViewController.h"
#import "SharedViewController.h"

@interface SetupDevicesViewController : SharedViewController <UIGestureRecognizerDelegate, UIPopoverControllerDelegate, DeviceTablePopoverDelegate>{

    __weak IBOutlet UIImageView *imageView1;
	UIPanGestureRecognizer* panGesture;
	
}

@property (retain, nonatomic) UIPopoverController *devicePopoverController;
@property (retain, nonatomic) UIStoryboardPopoverSegue* popSegue;
- (IBAction)btnUndo:(UIButton *)sender;
- (IBAction)btnAddDevice:(id)sender;
- (IBAction)btnClearAllDevices:(UIButton *)sender;
- (IBAction)handlePan:(UIPanGestureRecognizer *)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender;

- (void)deviceNameSelected:(NSString*)name andImageName:(NSString*)imgname andServiceName:(NSNumber*)serv andZone:(NSNumber*)zone andDevType:(NSNumber*)devType;
-(void)hideBackBtn;
@end
