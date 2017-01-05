//
//  SetupRoomsViewController.h
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomView.h"


@interface SetupRoomsViewController : UIViewController <RoomDelegate>
{
    
    IBOutlet RoomView *roomView;
    NSString *name;
	
	int currentFloor;
	int numberOfFloors;

}

- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender;
- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender;

- (void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish;
- (BOOL) checkForCompleteShape;
- (IBAction)deleteLastRoom:(id)sender;
- (IBAction)deleteAll:(id)sender;
- (IBAction)goToDevices:(UIBarButtonItem *)sender;
- (void)hideBackBtn;

@end
