//
//  HouseView.h
//  dis
//
//  Created by Robert Smith on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HouseDelegate

- (void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish;

@end

@interface HouseView : UIView {
	//the instance vars
    CGPoint fromPoint;
    CGPoint toPoint;
    CGPoint beginTouchPoint;
	
	bool beginTouch;
	
    CGContextRef offScreenBuffer; //store offscreen context
    UIImage *uiImage1; //store image used to draw
    NSMutableArray* wallArray; //store points of wall
    
}
 

//set VC as delegate
@property (assign) id  <HouseDelegate> delegate;

//methods VC has access to
-(void)reloadHousePoints;
-(void)resetAllClearButtonPressed;
-(void)completeHouseShape;

@end
