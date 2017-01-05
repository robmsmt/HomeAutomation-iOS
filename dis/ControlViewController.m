//
//  ControlViewController.m
//  dis
//
//  Created by Robert Smith on 28/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

/*
This VC is the main VC used in the app, it is where the user will spend most of their time, and is one of the largest
 with regards to LOC.
Some of the code for this VC is present in the SharedViewController too. This was done to make the VC more manageable 
 and to increase the efficiency.


 What ControlViewController does:
 
 1)It builds the details in an imageview which includes:
 the house shape (inside SharedViewController) 
 the rooms only on current floor Level (inside SharedViewController)
 the devices only on current floor level
 
 2)Connects to the ZigBee adapter using the SharedNetworking file
 
 3)It will respond to users pressing on the device and creates the popup to allow the control of the device
 
 4)Responds to the user changing the levels inside the house with 2 finger swipe, causing a reload of point 1
 
 5)Handles responses (updates) from the sharedNetworking file sending them to the appropriate popup
 
 6)Handles the timed trigger events (every minute it will evaluate) and checks for trigger updates on the sensors.
 
 
 
*/ 
 
 
#import "ControlViewController.h"
#import "RoomManager.h"
#import "HouseManager.h"
#import "DevicesManager.h"
#import "TriggerManager.h"
#import <QuartzCore/QuartzCore.h>

#define kHouseData   @"houseData"
#define kRoomData   @"roomData"
#define kDeviceData   @"deviceData"



@implementation ControlViewController

//synthesize the popups
@synthesize devicePopoverController;
@synthesize settingsPopoverController;
@synthesize popSegue;


//VIEW METHODS

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Override point for customization after application launch.
	if(!sharedNetworking){
		sharedNetworking = [[SharedNetworking alloc]initWithDelegate:self] ;
	}
	
	
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];    
    [self setupVariables];
	moveableMode = 0;
	[self registerObserver];
	[self getLastestTriggers:NULL];	
	NSTimeInterval launchTime = (double)[self getSecondsToNextMinute];
	timer = [NSTimer scheduledTimerWithTimeInterval:launchTime target:self selector:@selector(firstTrigger:) userInfo:nil repeats:NO];
	
	
	currentFloor = 0;
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    numberOfFloors = [[sharedHouseManager getNumberOfFloors]intValue];
	self.title = @"Control - Floor 0";
		
}

- (void)viewDidUnload {
	NSLog(@"ControlViewController -> viewDidUnload");
    imageView1 = nil;
    houseArray =nil;
	roomArray=nil;
	arr=nil;
	offScreenBuffer=nil;
	lastDeviceButton = nil;
	lastDeviceButton = nil;
	settingsButton = nil;
	[timer invalidate];
	timer = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc{
    
    NSLog(@"dealloc called");
	imageView1 = nil;
    houseArray =nil;
	roomArray=nil;
	arr=nil;
	offScreenBuffer=nil;
	lastDeviceButton = nil;
	lastDeviceButton = nil;
	settingsButton = nil;
	[timer invalidate];
	timer = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (BOOL)canBecomeFirstResponder {
	//this is required to detect the shake movements
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover dismissed");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
//	UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle: @"Announcement"
//                          message: @"Memory warning!"
//                          delegate: nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil];
//	[alert show];
//Warning used in debug only
}


//TIME METHODS

-(NSString*) getTimeStamp{
	//gets timestamp in form: dayofweek house:minutes
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"E HH:mm"];	
	return [format stringFromDate:[NSDate date]];
}

-(NSString*) getTime{
	//returns current time
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"HH:mm"];
	return [format stringFromDate:[NSDate date]];
}

-(int) getSecondsToNextMinute{
	//gets the number of seconds to the next minute
	//this is required for setting a timer to trigger on 
	//the start of every minute
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"ss"];
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *num = [f numberFromString:[format stringFromDate:[NSDate date]]];
	return (60-[num intValue]);
}


//SETUP

-(void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLastestTriggers:) name:@"timeTriggerObjectsChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLastestTriggers:) name:@"sensorTriggerObjectsChanged" object:nil];
}

-(void)setupVariables {
		
    [self setupBuffer];
    [self getHousePath];
    [self getRoomsPath];
    [self rebuildContextImg];
	
}


//REDRAWING

-(void)rebuildContextImg {
    
	//rebuild context image forces the whole house screen to be redrawn
    [self drawHouse];
    [self drawRooms];
	[self drawDevices];
    [self drawRect];
    
}

-(void)drawRect{
	//draw rect is a simplified version of the rooms&house uiview version
	//it forces the view to create an image from the offscreen buffer
    CGImageRef cgImage = CGBitmapContextCreateImage(offScreenBuffer);
    UIImage *uiImage1 = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    //this image is then set inside the imageview
    [imageView1 setFrame:self.view.bounds];
    [imageView1 setImage:uiImage1];
    
}


//DEVICES

-(void)drawDevices{
	//this method is responsible for drawing the devices on a given floor
	
	//get data from shared
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	deviceArray = [sharedDevicesManager deviceObjectsArray];
		
	for (int i=0;i<[deviceArray count]; i++){
		
		if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
			
			//get floor number of device from DeviceManager
			NSNumber *flr = [[deviceArray objectAtIndex:i] performSelector: @selector(returnFloor)];
            
			if([flr intValue] == currentFloor){ //only draw if it exists on current floor
				
				//get devices values from DeviceManager
				NSString* imgname = [[deviceArray objectAtIndex:i] performSelector: @selector(returnImg)];
				NSValue* pointVal = [[deviceArray objectAtIndex:i] performSelector: @selector(returnPoint)];
				CGPoint point = [pointVal CGPointValue];
					
				//create a button
				UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				imageButton.frame = CGRectMake(point.x-33.5, point.y-33.5, 75, 75);
				
				//add pan gesture to button
				panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] ;
				[panGesture setDelegate:self];
				[imageButton addGestureRecognizer:panGesture];
				
				//add long hold gesture
				longHoldGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
				[longHoldGesture setDelegate:self];
				[imageButton addGestureRecognizer:longHoldGesture];
				
				//set button image
				[imageButton setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
				[imageButton setUserInteractionEnabled:YES];
				[imageButton addTarget: self action: @selector(devicePressed:) forControlEvents: UIControlEventTouchUpInside];
				imageButton.tag = i;


				[self.view addSubview:imageButton];
			}
		}
	}
}

-(IBAction)handlePan:(UIPanGestureRecognizer *)sender {
	//allows us to move the buttons if they are in moveable mode
	//aka wiggle mode, in keeping with iOS
	if(moveableMode){
		CGPoint translation = [sender translationInView:self.view];
		CGPoint p = CGPointMake(sender.view.center.x + translation.x, 
								sender.view.center.y + translation.y);
		if([self isPointInsideHouse:p]){
			sender.view.center = p;
			[sender setTranslation:CGPointMake(0, 0) inView:self.view];
			int indexTag = sender.view.tag;
			DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
			switch (sender.state) {
				case UIGestureRecognizerStateEnded:
					[sharedDevicesManager updateObjectAtIndex:indexTag withLocation:p];
					[sharedDevicesManager saveSettingsToDisk];
					break;
				default:
					break;
					
			}
		}
	}
}

-(void)longPressGesture:(UILongPressGestureRecognizer *)sender {
	//when a button is held for a long period begin wiggle mode
	//unless already in wiggle mode then return to normal
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			NSLog(@"LongPress!");  
			if(moveableMode){
				[self stopWiggleMode];
			} else {
				[self wiggleMode];}
			break;
		default:
			break;
	}
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		//detect device shaking to make buttons moveable (ie. wigglemode)
			//It has shaked
		if(moveableMode){
			[self stopWiggleMode];
		}else{
			[self wiggleMode];	
		}
        
	}
}

-(void)wiggleMode{
	//animates the buttons with a wiggle when they are movable
	moveableMode = 1;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.08];
	[UIView setAnimationRepeatAutoreverses:YES];
	[UIView setAnimationRepeatCount:10000];

	for (UIView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
			
			if([self isPointInsideHouse:subview.center]){
				subview.transform = CGAffineTransformMakeRotation(69);
				subview.transform = CGAffineTransformMakeRotation(-69);
			}
		}
	}
	
	[UIView commitAnimations];
	self.title = @"Quick Move Mode";
	

}

-(void)stopWiggleMode{
	//stops the wiggle and ensures that the buttons are not movable
	moveableMode = 0;
	
	for (UIView *subview in self.view.subviews) {
		if ([subview isKindOfClass:[UIButton class]]) {
			if([self isPointInsideHouse:subview.center]){
				subview.transform = CGAffineTransformMakeRotation(0); 
				[subview.layer removeAllAnimations]; 
	
			}
		}
	}
	NSString *title = [NSString stringWithFormat:@"Control - Floor %i", currentFloor];	
	self.title = title; 

}

-(void)devicePressed:(UIButton *)sender{
	//when the device is pressed this method is ran, it checks to ensure that it's not being moved first
	if(!moveableMode){
		
		//if popovers are visible close them
		if([settingsPopoverController isPopoverVisible]){
			[settingsPopoverController dismissPopoverAnimated:YES];
		}
		
		if(![devicePopoverController isPopoverVisible]){
			
			//get data from devices data based on button tag
			DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
			deviceArray = [sharedDevicesManager deviceObjectsArray];
			
			int i = sender.tag;
			
			if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
				
				//this block gets the relavent details needed from DeviceManager
				NSString* name = [[deviceArray objectAtIndex:i] performSelector: @selector(returnName)];
				NSString* img = [[deviceArray objectAtIndex:i] performSelector: @selector(returnImg)];
				NSNumber* devType = [[deviceArray objectAtIndex:i] performSelector: @selector(returnDeviceType)];
				NSMutableArray *notifArray = [[deviceArray objectAtIndex:i]performSelector:@selector(returnNotifications)];
				NSMutableArray *timeArray2 = [[deviceArray objectAtIndex:i]performSelector:@selector(returnTimestamps)];
				NSNumber *serviceName = [[deviceArray objectAtIndex:i]performSelector:@selector(returnServiceName)];
				NSNumber *zone = [[deviceArray objectAtIndex:i]performSelector:@selector(returnZone)];
				
				lastDeviceButton.title = name;
				lastDeviceButton.tag = i;
				
				//creates the device popover
				UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
				devicePopover=[mainStoryboard instantiateViewControllerWithIdentifier:@"ControlDevicePopover"];
				devicePopover.delegate = self;
				self.devicePopoverController=[[UIPopoverController alloc] initWithContentViewController:devicePopover];
				self.devicePopoverController.popoverContentSize=CGSizeMake(300,600);
				self.devicePopoverController.delegate=self;
				[self.devicePopoverController presentPopoverFromBarButtonItem:lastDeviceButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				
				
				//sends the information to the device popover
				[devicePopover setDeviceType:devType withTag:i withNotifications:notifArray andTimeStamp:timeArray2 withImg:img];
				[devicePopover setName:name];
				
				//request update for device
				if([devType intValue] == 0){
					//req personalised update
					[sharedNetworking performType0DataUpdateWithSN:serviceName andZone:zone andBtnId:i];
					
				} else if([devType intValue] == 1){
					//req normal update
					[sharedNetworking performType1DataSendWithSN:serviceName andZone:zone andBtnId:i];
					
				} else if([devType intValue] == 2){
					//req ranged update
					[sharedNetworking performType0DataUpdateWithSN:serviceName andZone:zone andBtnId:i];
				}
			
		}else{
			[devicePopoverController dismissPopoverAnimated:YES];
		}
					
			

		}
		
				
	}
}


//NETWORKING

-(void)networkResponseDevID:(NSMutableArray *)aDevID andDevName:(NSMutableArray *)aDevName andDevImg:(NSMutableArray *)aDevImg andServiceName:(NSMutableArray *)aServName andZone:(NSMutableArray *)aZone andDevType:(NSMutableArray *)aDevType{
	//here we handle the response from the network
	
	//the array is filled with UID's from the database.
	//in the future we could use these to see if the recieved array matches those that exist as buttons
	
	NSLog(@"responseDevicesOnNetworkCalled");
}

-(void)performNetworkingWithDevice:(int)index turn:(BOOL)status{
	//we have been requested from the ControlDevicePopupViewController to perform an update
	//first we get the device details (SN&ZN) based on the button index 
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	deviceArray = [sharedDevicesManager deviceObjectsArray];
	
	int i = index;
	
	if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
		
		NSNumber* serviceName = [[deviceArray objectAtIndex:i] performSelector: @selector(returnServiceName)];
		NSNumber* zone = [[deviceArray objectAtIndex:i] performSelector: @selector(returnZone)];
		
		//now we have the service name and zone we are able to call the wanted value which is either 1/0 --> on/off
		//this is sent to shared networking
		[sharedNetworking performType0DataSendWithSN:serviceName andZone:zone andSetStatus:status andBtnId:i];
		
	}
}

-(void)performNetworkUpdateWithDevice:(int)tag{
	
	//this method is similar to performNetworkingWithDevice but is for sensors and
	//the main difference is that there is no status to provide
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	deviceArray = [sharedDevicesManager deviceObjectsArray];
	
	int i = tag;
	
	if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
		
		NSNumber* serviceName = [[deviceArray objectAtIndex:i] performSelector: @selector(returnServiceName)];
		NSNumber* zone = [[deviceArray objectAtIndex:i] performSelector: @selector(returnZone)];
		
		//now we have the service name and zone we are able to call sharednetworking method
		
		[sharedNetworking performType1DataSendWithSN:serviceName andZone:zone andBtnId:i];
		
		
	}

}

-(void)triggerNetworkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int) index{
	
	if ([[deviceArray objectAtIndex:index] respondsToSelector:@selector(isDevice)]) {
		NSString* deviceImg = [[deviceArray objectAtIndex:index] performSelector: @selector(returnImg)];
		NSNumber* devType = [[deviceArray objectAtIndex:index] performSelector:@selector(returnDeviceType)];
		NSString* newStr = deviceImg;
		//bool state = 0;
		//we should update the images here from the network response
		//on the map
		if([devType intValue] == 0){
			
			if([newVal isEqualToString:@"On"]){
				//state = 1;
				if ( [newStr length] > 0){
					newStr = [newStr substringToIndex:[newStr length] - 4]; //removes .png
					newStr = [NSString stringWithFormat:@"%@_on.png", newStr]; //add _on.png
				}
			} else if([newVal isEqualToString:@"Off"]){
				//state = 0;
				newStr = deviceImg;
			}
			
			for (UIView *subview in self.view.subviews) {
				if ([subview isKindOfClass:[UIButton class]]) {
					if([self isPointInsideHouse:subview.center]){
						if(subview.tag == index){
							//cant seem to get hold of button to set image
							//[subview setImage:[UIImage imageNamed:newStr] forState:UIControlStateNormal];			
							[(UIButton *)subview setImage:[UIImage imageNamed:newStr] forState:UIControlStateNormal];
						}
					}
				}
			}
			
		}
	}
	
	
}


-(void)networkUpdateWithDataValue:(NSString *)newVal forDeviceIndex:(int)index{	
	//this is where the network has replied with a value for an button at index
	BOOL trig = 1;
	
	if ([[deviceArray objectAtIndex:index] respondsToSelector:@selector(isDevice)]) {
		NSString* deviceImg = [[deviceArray objectAtIndex:index] performSelector: @selector(returnImg)];
		NSNumber* devType = [[deviceArray objectAtIndex:index] performSelector:@selector(returnDeviceType)];
		NSString* newStr = deviceImg;
		bool state = 0;
	//we should update the images here from the network response
	//on the map
		if([devType intValue] == 0){
		
			if([newVal isEqualToString:@"On"]){
				state = 1;
				if ( [newStr length] > 0){
					newStr = [newStr substringToIndex:[newStr length] - 4]; //removes .png
					newStr = [NSString stringWithFormat:@"%@_on.png", newStr]; //add _on.png
				}
			} else if([newVal isEqualToString:@"Off"]){
				state = 0;
				newStr = deviceImg;
			}
			
			
			
			
			
			if(devicePopover != nil){
				//update image on popover
				[devicePopover updateImg:newStr andState:state];
			}
				
			for (UIView *subview in self.view.subviews) {
				if ([subview isKindOfClass:[UIButton class]]) {
					if([self isPointInsideHouse:subview.center]){
						if(subview.tag == index){
						//cant seem to get hold of button to set image
						//[subview setImage:[UIImage imageNamed:newStr] forState:UIControlStateNormal];			
						[(UIButton *)subview setImage:[UIImage imageNamed:newStr] forState:UIControlStateNormal];
						}
					}
				}
			}
		} else if ([devType intValue] == 1){
			/*ensure trigger reply doesn't go to sensors
			//because we pass the device index as a parameter when we send network messages
			//the trigger response doesn't carry the correct index but instead the last opened popup which is usually the sensor that triggered it- we can detect this because sensors should't be
			receiving ON/OFF messages */
			if([newVal isEqualToString:@"On"] || [newVal isEqualToString:@"Off"]){
				trig = 0;
			}
			
		}
	}
	//we've set the map image now we can set the current popover img;
	//and update the values and notifications
		
	if(devicePopover != nil && trig){
		DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
		deviceArray = [sharedDevicesManager deviceObjectsArray];
		NSMutableArray* tempNotifArray = [[deviceArray objectAtIndex:index] performSelector: @selector(returnNotifications)];
		NSMutableArray* tempTimeArray = [[deviceArray objectAtIndex:index] performSelector: @selector(returnTimestamps)];
		
		[devicePopover updateValue:newVal];
		[devicePopover updateTableWithNotifications:tempNotifArray andTimeStamp:tempTimeArray];
		 
	}	
	
	
	
		
}

-(void)networkUpdateWithBatteryValue:(NSString *)battStr andBatteryFloat:(float)battfloat{
	
	//send message to popover with new batt value
	if(devicePopover != nil){

		[devicePopover updateBattery:battStr andBatteryFloat:battfloat];
		
	}	
	
	
}

-(void)triggerButtonPressed:(int)tagIndex{
	//this method is called from within ControlDevicePopupViewController when a sensor trigger
	//has been pressed it creates the trigger menu
	
	[devicePopoverController dismissPopoverAnimated:YES];
	UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
	triggerModalPopover=[mainStoryboard instantiateViewControllerWithIdentifier:@"ModalTriggerPopover"];
	triggerModalPopover.modalPresentationStyle = UIModalPresentationFormSheet;
	triggerModalPopover.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:triggerModalPopover animated:YES];
	triggerModalPopover.view.superview.frame = CGRectMake(0, 0, 660, 520);
	triggerModalPopover.view.superview.center = self.view.center;
	[triggerModalPopover setSensorName:lastDeviceButton.title];

}

-(IBAction)LastDeviceBtnPressed:(UIBarButtonItem*)sender {
	//we check that last device button isn't "Last Device" else act as if actual device btn is being pressed
	//when it is pressed
		UIButton *btn = [[UIButton alloc]init];
		btn.tag = sender.tag;
		  if(![sender.title isEqualToString:@"Last Device"]){
		[self devicePressed:btn];
	}
	
}


//Settings, Resets and AlertViews

-(IBAction)settingsButtonPressed:(UIBarButtonItem *)sender {
	//when the settings button is pressed we must load up the settings popover
	
	if([devicePopoverController isPopoverVisible]){
		[devicePopoverController dismissPopoverAnimated:YES];
	}
	
	UIStoryboard *mainStoryboard=[UIStoryboard
                                  storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
	SettingsTableViewController *settingsTable=[mainStoryboard
												instantiateViewControllerWithIdentifier:@"settingsPopover"];
	settingsTable.delegate = self;
	
    if(![settingsPopoverController isPopoverVisible]){
		
		self.settingsPopoverController=[[UIPopoverController alloc]
										initWithContentViewController:settingsTable];
		self.settingsPopoverController.popoverContentSize=CGSizeMake(300,400);
		self.settingsPopoverController.delegate=self;
		[self.settingsPopoverController presentPopoverFromBarButtonItem:settingsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
    }else{
		//close if already open
		[settingsPopoverController dismissPopoverAnimated:YES];
	}
    
}

-(void)resetAll{
	//reset all is called by settingsTableViewController when the user wants to reset all
	//it creates an alert to confirm whether the user wants to delete.
	
	NSLog(@"resetAll called");
	[settingsPopoverController dismissPopoverAnimated:YES];
	deleteIndex = 0;
	UIAlertView *resetAll = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all saved data?"
													   message:nil
													  delegate:self
											 cancelButtonTitle:@"No"
											 otherButtonTitles:@"Yes", nil];
	[resetAll setAlertViewStyle:UIAlertViewStyleDefault];
	[resetAll show];

	
}

-(void)resetRooms{
	//reset rooms is called by settingsTableViewController when the user wants to reset rooms&devices
	//it creates an alert to confirm whether the user wants to delete.
	
	NSLog(@"resetRooms called");
	
	[settingsPopoverController dismissPopoverAnimated:YES];
	
	deleteIndex = 1;
	
	UIAlertView *resetAll = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all rooms and devices data?"
													   message:nil
													  delegate:self
											 cancelButtonTitle:@"No"
											 otherButtonTitles:@"Yes", nil];
	
	[resetAll setAlertViewStyle:UIAlertViewStyleDefault];
	[resetAll show];

}

-(void)resetDevices{
	//reset devices is called by settingsTableViewController when the user wants to reset devices
	//it creates an alert to confirm whether the user wants to reset devices.
	NSLog(@"resetDevices called");
	[settingsPopoverController dismissPopoverAnimated:YES];
	deleteIndex = 2;
	
	UIAlertView *resetAll = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all devices data?"
													   message:nil
													  delegate:self
											 cancelButtonTitle:@"No"
											 otherButtonTitles:@"Yes", nil];
	
	[resetAll setAlertViewStyle:UIAlertViewStyleDefault];
	[resetAll show];
}

-(void)disconnect{
	//when we disconnect we wish to release many variables
	houseArray = nil;
	roomArray = nil;
	deviceArray = nil;
	arr = nil;
	CGContextRelease(offScreenBuffer);
	[timer invalidate];
	timer = nil;
	[sharedNetworking disconnect];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	//this is responsible for contolling all 3 possible alerts
	//the ones for ALL, Rooms and Device resets
	
	if(buttonIndex == 0){
		//No was pressed therefore
		//Do Nothing
		
	}else if(buttonIndex == 1){
		//Yes
		//depending on the deleteIndex we know what is being reset (all,rooms&devices,just devices)
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *dataPathHouse = [[paths objectAtIndex:0] stringByAppendingPathComponent:kHouseData];
		NSString *dataPathRoom = [[paths objectAtIndex:0] stringByAppendingPathComponent:kRoomData];
		NSString *dataPathDevice = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDeviceData];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if(deleteIndex == 0){
			//delete all
			[fileManager removeItemAtPath:dataPathHouse error:NULL];
			[fileManager removeItemAtPath:dataPathRoom error:NULL];
			[fileManager removeItemAtPath:dataPathDevice error:NULL];
			HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
			[sharedHouseManager clearAllPoints];
			RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
			[sharedRoomManager deleteAllRoomObjects];
			DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
			[sharedDevicesManager deleteAllDeviceObjects];
			
		} else if(deleteIndex == 1){
			//delete rooms&devices
			[fileManager removeItemAtPath:dataPathRoom error:NULL];
			[fileManager removeItemAtPath:dataPathDevice error:NULL];
			RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
			[sharedRoomManager deleteAllRoomObjects];
			DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
			[sharedDevicesManager deleteAllDeviceObjects];
			
		} else if(deleteIndex == 2){
			//delete devices
			[fileManager removeItemAtPath:dataPathDevice error:NULL];
			DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
			[sharedDevicesManager deleteAllDeviceObjects];
		}
		//return to start
		[self disconnect];
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
}


//Triggers section

-(void)firstTrigger:(NSTimer *)aTimer{
	//this trigger performs a trigger ensures that the next triggers are performed on the minute
	timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(trigger:) userInfo:nil repeats:NO]; //first exec
	timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(trigger:) userInfo:nil repeats:YES];
}

-(void)trigger:(NSTimer *)aTimer{

	//this method is run every 60 seconds on the minute
	NSLog(@"::TRIGGER::");
	
	//lets get the current time
	NSString *currentTime = [self getTime];
	
	//now we must loop through each element of timeArray and see if match
	int i=0;
	for(NSString *time in timeArray){
		if([time isEqualToString:currentTime]){
			[self execTimeTrigger:i]; //if match exec
		}
		i++;
	}
	
	//handling the sensorTriggers is a little more complicated
	//they are based on the incoming network values
	
}

-(void)networkUpdateToTriggerWithVal:(NSNumber *)val andSensorSN:(NSNumber *)sensorSN andSensorZone:(NSNumber *)sensorZN{
	//we have recieved an update from a sensor this would have been invoked by user
	//check to see if this is relavent to any of our triggers (if there are any)
	
	//is this sensor on our watchlist? if so compare values 
	//if it's on our watchlist then we will get a triggerSensorServiceName and triggerSensorZone match at the same index lets loop through and see if we can find it.

	for(int i=0; i<[triggerSensorServiceName count];i++){
		
		if([[triggerSensorServiceName objectAtIndex:i] isEqualToNumber:sensorSN]){
			
			if([[triggerSensorZone objectAtIndex:i] isEqualToNumber:sensorZN]){
				NSLog(@"match on index:%i",i);
				//we have a match i.e. we've got an update for a device we are watching
				int trigVal = [[triggerSensorValue objectAtIndex:i] intValue];
				NSString* con = [triggerConditionValue objectAtIndex:i];
				int status = [[actionStatus objectAtIndex:i] intValue];
				int detectedIndex=0;
				bool statusBool;
				if(status >= 1) statusBool = 1;
				else if(status <= 0) statusBool = 0;
				
				
				//get values
				NSNumber *actionSN = [actionServiceName objectAtIndex:i];
				NSNumber *actionZN = [actionZone objectAtIndex:i];
				
				for(int j = 0; j<[deviceArray count]; j++){
					if ([[deviceArray objectAtIndex:j] respondsToSelector:@selector(isDevice)]) {
						NSNumber *serviceName = [[deviceArray objectAtIndex:j]performSelector:@selector(returnServiceName)];
						NSNumber *zone = [[deviceArray objectAtIndex:j]performSelector:@selector(returnZone)];
					
						if([sensorSN isEqualToNumber:serviceName] && [sensorZN isEqualToNumber:zone]) detectedIndex=j;
								
					
					}
				}
				
				//here we test to see if the condition matches
				//if it does then we can send the data as the trigger has been met
				//NSLog(@"CONNTYPE:%@",con);
				
				if([con isEqualToString:@"is equal to"] && [val intValue] == trigVal){
						[sharedNetworking performType0DataSendWithSN:actionSN andZone:actionZN andSetStatus:statusBool andBtnId:detectedIndex];
				} else if ([con isEqualToString:@"is not equal to"] && [val intValue] != trigVal) {
						[sharedNetworking performType0DataSendWithSN:actionSN andZone:actionZN andSetStatus:statusBool andBtnId:detectedIndex];
				} else if ([con isEqualToString:@"is less than"] && [val intValue] < trigVal){
						[sharedNetworking performType0DataSendWithSN:actionSN andZone:actionZN andSetStatus:statusBool andBtnId:detectedIndex];
				} else if ([con isEqualToString:@"is more than"] && [val intValue] > trigVal){
						[sharedNetworking performType0DataSendWithSN:actionSN andZone:actionZN andSetStatus:statusBool andBtnId:detectedIndex];
				}
				
			}			
		}		
	}
	
	
}

-(void)execTimeTrigger:(int)index{
	//time trigger executing, we must first get the values needed to execute
	//we can then send the needed values to the sharedNetworking file
	
	NSLog(@"TIME TRIGGER DETECTED IN INDEX:%i, executing",index);

	if ([[timeTriggerArray objectAtIndex:index] respondsToSelector:@selector(isTriggerTime)]) {
		NSNumber* sn = [[timeTriggerArray objectAtIndex:index] performSelector: @selector(returnServiceName)];
		NSNumber* zn = [[timeTriggerArray objectAtIndex:index] performSelector: @selector(returnZone)];
		NSNumber* st = [[timeTriggerArray objectAtIndex:index] performSelector: @selector(returnStatus)];				
		
		bool stat = 1;
		if([st intValue] == 0) stat = 0;
		
		DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
		deviceArray = [sharedDevicesManager deviceObjectsArray];
	
		//we must loop through the objects and get the correct index for the button
		for(int i = 0; i<[deviceArray count];i++){
			if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
				
				NSNumber* serviceName = [[deviceArray objectAtIndex:i] performSelector: @selector(returnServiceName)];
				NSNumber* zone = [[deviceArray objectAtIndex:i] performSelector: @selector(returnZone)];
				
				if([serviceName intValue] == [sn intValue] && [zone intValue] == [zn intValue]){
					//found match on type 0 device
					[sharedNetworking performType0DataSendWithSN:serviceName andZone:zone andSetStatus:stat andBtnId:i];
					return; //ensure can only run once
				}	
			}
		}
	}
}

-(void)getLastestTriggers:(NSNotification *)pNotification{
	//get latest trigger values into arrays
	if(!timeTriggerArray) timeTriggerArray = [[NSMutableArray alloc]init];
	if(!sensorTriggerArray) sensorTriggerArray = [[NSMutableArray alloc]init];
	if(!timeArray) timeArray = [[NSMutableArray alloc]init];
	if(!triggerConditionValue) triggerConditionValue = [[NSMutableArray alloc]init];
	if(!triggerSensorValue) triggerSensorValue = [[NSMutableArray alloc]init];
	if(!triggerSensorServiceName) triggerSensorServiceName = [[NSMutableArray alloc]init];
	if(!triggerSensorZone) triggerSensorZone = [[NSMutableArray alloc]init];
	if(!actionServiceName) actionServiceName = [[NSMutableArray alloc]init];
	if(!actionZone) actionZone = [[NSMutableArray alloc]init];
	if(!actionStatus) actionStatus = [[NSMutableArray alloc]init];

	
	TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
	timeTriggerArray = [sharedTriggerManager triggerTimeObjectsArray];
	sensorTriggerArray = [sharedTriggerManager triggerSensorObjectsArray];
	
	//build time array --> remove all objects first
	[timeArray removeAllObjects];
	// we need to build an array of the times (hh:mm)
	for (int i=0;i<[timeTriggerArray count]; i++){
		if ([[timeTriggerArray objectAtIndex:i] respondsToSelector:@selector(isTriggerTime)]) {
			NSString* time = [[timeTriggerArray objectAtIndex:i] performSelector: @selector(returnTime)];
			[timeArray addObject:time];
		}
	}
	
	//now we must build the sensor triggers data
	
	//build array --> remove all objects first
	[triggerConditionValue removeAllObjects];
	[triggerSensorValue removeAllObjects];
	[triggerSensorServiceName removeAllObjects];
	[triggerSensorZone removeAllObjects];
	[actionServiceName removeAllObjects];
	[actionZone removeAllObjects];
	[actionStatus removeAllObjects];
	
	// we need to loop and build all arrays
	for (int i=0;i<[sensorTriggerArray count]; i++){
		if ([[sensorTriggerArray objectAtIndex:i] respondsToSelector:@selector(isTriggerSensor)]) {
			
			NSString* triggerCond = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnCondition)];
			NSNumber* triggerSensorVal = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnSensor)];
			NSNumber* triggerSensorSN = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnSensorSN)];
			NSNumber* triggerSensorZN = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnSensorZN)];
			NSNumber* actionSN = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnActionSN)];
			NSNumber* actionZN = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnActionZN)];
			NSNumber* actionST = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnActionStatus)];
			[triggerConditionValue addObject:triggerCond];
			[triggerSensorValue addObject:triggerSensorVal];
			[triggerSensorServiceName addObject:triggerSensorSN];
			[triggerSensorZone addObject:triggerSensorZN];
			[actionServiceName addObject:actionSN];
			[actionZone	addObject:actionZN];
			[actionStatus addObject:actionST];
			
			
		}
	}




}


//Floor Change Swiping

- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender {
	
	//we must minus 1 floor since all floors start at level 0
	if(currentFloor < (numberOfFloors-1)){
		currentFloor++;
		NSString *title = [NSString stringWithFormat:@"Control - Floor %i", currentFloor];	
		self.title = title; 
		
		[self stopWiggleMode];
		[self deleteAllButtons];
		[self rebuildContextImg];
		[imageView1 setNeedsDisplay];
	}
}

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
	//handle downSwipe, this is similar to the code used on
	//SetupRoomVC and SetupDevicesVC
	
	if(currentFloor > 0){
		currentFloor--;
		NSString *title = [NSString stringWithFormat:@"Control - Floor %i", currentFloor];	
		self.title = title; 
		
		[self stopWiggleMode];
		[self deleteAllButtons];
		[self rebuildContextImg];
		[imageView1 setNeedsDisplay];
	}
}


@end