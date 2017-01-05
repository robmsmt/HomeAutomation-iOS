//
//  SetupHouseViewController.h
//  dis
//
//  Created by Robert Smith on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HouseView.h"


@interface SetupHouseViewController : UIViewController <HouseDelegate>{
    
    IBOutlet HouseView *houseView;
    IBOutlet UIButton *btn_undo;
    IBOutlet UIButton *btn_clear;
	__weak IBOutlet UIBarButtonItem *barbtn_done;

}


-(IBAction)pressedClear:(id)sender;
-(void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish;
-(BOOL) checkForCompleteShape;
-(IBAction)goToRoomsBtn:(UIBarButtonItem *)sender;



@end
