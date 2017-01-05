//
//  TriggerViewController.h
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol toTableDelegate
- (void) savedButtonPressed;
@end


@interface TimeTriggerViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{

	NSMutableArray *actionArray;
	__weak IBOutlet UIPickerView *actionPicker;
	__weak IBOutlet UIDatePicker *timePicker;
}

@property id  <toTableDelegate> delegate;
- (IBAction)saveTriggerBtnPressed:(id)sender;

- (IBAction)closeBtnPressed:(UIButton *)sender;
@end
