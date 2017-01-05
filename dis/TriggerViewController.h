//
//  TriggerViewController.h
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriggerViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
	NSMutableArray *conditionArray;
	NSMutableArray *valueArray;
	NSMutableArray *actionArray;
	NSString* sensorName;
	NSNumber* sensorSN;
	NSNumber* sensorZN;
	
	
	__weak IBOutlet UIPickerView *conditionPicker;
	__weak IBOutlet UILabel *sensorNameLabel;

}

- (IBAction)closeBtnPressed:(UIButton *)sender;
- (IBAction)saveTriggerBtnPressed:(UIButton *)sender;
-(void)setSensorName:(NSString *)sensorN;
@end
