//
//  SetupDevicesViewController.m
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 The SetupDevicesViewController is responsible for drawing and creating devices on a view on of the house
 
 It creates the buttons for the devices and allows them to be panned around but restricting them to the confines 
 of the house.
 
 It is only present whilst the user is adding the devices to the map then the user can move to the ControlViewController
 which is the main view for the application.
 
 Note that many of the methods and instances variables are inherited from SharedViewController
 
 
 */

#import "SetupDevicesViewController.h"
#import "RoomManager.h"
#import "HouseManager.h"
#import "DevicesManager.h"


@implementation SetupDevicesViewController

@synthesize devicePopoverController;
@synthesize popSegue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
	//on load setup background and build house&rooms
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]]; 
	
	//delete all existing buttons incase user has gone back and changed house shape etc
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	[sharedDevicesManager deleteAllDeviceObjects];
	[self deleteAllButtons];
	
	[self setupBuffer];
    [self getHousePath];
    [self getRoomsPath];
    [self rebuildContextImg];
	
	//sets current floor
	currentFloor = 0;
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    numberOfFloors = [[sharedHouseManager getNumberOfFloors]intValue];
	self.title = @"Setup Devices - Floor 0";
	
}

- (void)viewDidUnload
{
    imageView1 = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setDevicePopoverController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//force landscape orientation
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


/// FROM HERE similar to ROOMVIEW: 

-(void)rebuildContextImg {
    
    [self drawHouse];
    [self drawRooms];
    [self drawRect];
	//draw devices
	[self addDeviceButtonsOnSwipe];
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

-(void)addDeviceButtonsOnSwipe{
	
	//this method is called when the user swipes and it means the buttons are all removed and recreated depending
	//on which floor the user is on
	
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	deviceArray = [sharedDevicesManager deviceObjectsArray];
	
	for (int i=0;i<[deviceArray count]; i++){
		
		if ([[deviceArray objectAtIndex:i] respondsToSelector:@selector(isDevice)]) {
			
			NSNumber *flr = [[deviceArray objectAtIndex:i] performSelector: @selector(returnFloor)];
            
			if([flr intValue] == currentFloor){ //only draw if it exists on current floor
			
				//get values from DeviceManager
				NSString* imgname = [[deviceArray objectAtIndex:i] performSelector: @selector(returnImg)];
				NSValue* pointVal = [[deviceArray objectAtIndex:i] performSelector: @selector(returnPoint)];
				CGPoint point = [pointVal CGPointValue];
			
				
				//create button
				UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
				
				//set button size and image
				imageButton.frame = CGRectMake(point.x-33.5, point.y-33.5, 75, 75);
				[imageButton setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
				[imageButton setUserInteractionEnabled:YES];
				
				//give button pan gesture
				panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] ;
				[panGesture setDelegate:self];
				[imageButton addGestureRecognizer:panGesture];
				imageButton.tag = i;
				//add button to subview
				[self.view addSubview:imageButton];
				
			}
		}
	}
	

	
	
	
	
}

- (IBAction)btnUndo:(UIButton *)sender {
	//handles the undoing of devices
	
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	[sharedDevicesManager undoLastDevice];
	[self deleteAllButtons];
	[self addDeviceButtonsOnSwipe];
	
}

- (IBAction)btnAddDevice:(id)sender {
    
	//btnAddDevice is called whenever the user presses the 'Add Device' button
	//it creates the table popup which lists the connected devices
	
    UIStoryboard *mainStoryboard=[UIStoryboard
                                  storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    DeviceTableViewController *deviceTable=[mainStoryboard
                                            instantiateViewControllerWithIdentifier:@"devicePopover"];

    deviceTable.delegate = self;
    self.devicePopoverController=[[UIPopoverController alloc]
                                  initWithContentViewController:deviceTable];
    self.devicePopoverController.popoverContentSize=CGSizeMake(300,400);
    self.devicePopoverController.delegate=self;
    [self.devicePopoverController presentPopoverFromRect:((UIView *)sender).frame
                                                  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
}

- (void)deviceNameSelected:(NSString*)name andImageName:(NSString*)imgname andServiceName:(NSNumber*)serv andZone:(NSNumber*)zone andDevType:(NSNumber*)devType{
    
	//this method creates the initial button when it is clicked on in the DeviceTable popover
	//the parameters are used to create the button and then add it to the devicesManager
	
	CGRect houseRect;
	CGFloat midx;
    CGFloat midy;
	
	//get centre of house
	//we want to put device at the center
	CGPoint points[[houseArray count]];
    for(int i=0; i<[houseArray count]; i++){
        NSValue *val1 = [houseArray objectAtIndex:i];
        CGPoint recFromPoint = [val1 CGPointValue];
        points[i]=recFromPoint;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddLines (path, NULL, points, [houseArray count]);
    CGContextAddPath(offScreenBuffer, path);

	houseRect = CGContextGetPathBoundingBox(offScreenBuffer);
	midx = CGRectGetMidX(houseRect);
	midy = CGRectGetMidY(houseRect);
	CGPathRelease(path);
	
	//we can double check to ensure that the point is in the center of the house
	CGPoint p1;
	p1.x = midx;
	p1.y = midy;
	if(![self isPointInsideHouse:p1]){
		//point isn't in center
		//this point is likely to be otherwise
		midx = 155;
		midy = 105;
		//future we could create random and test until insidehouse
	}
	
    //NSLog(@"device:%@, and imagename:%@", name, imgname); used for debug
	
	//create image button
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(midx, midy, 75, 75); //start by adding device to the house 
    [imageButton setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal]; //set btn image
	[imageButton setUserInteractionEnabled:YES];
	    
    //if popover open close it
    if ([self.devicePopoverController isPopoverVisible]) 
    {
        [self.devicePopoverController dismissPopoverAnimated:YES];        
    }
	
	//destroy popover obj
	self.devicePopoverController = nil;
	self.devicePopoverController.delegate = nil;
	
	panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] ;
	[panGesture setDelegate:self];
	[imageButton addGestureRecognizer:panGesture];

	//we've created a button added it to the screen
	//now we must tell the shared devicesmanager that we've created a new obj
	
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	
	CGRect frame = [imageButton frame];
	CGPoint point = frame.origin; 
	
	//add device to DevicesManager, it will return index number
	NSNumber *indexTag = [sharedDevicesManager createWithDeviceName:name andImg:imgname atPoint:point withServiceName:serv andDeviceZone:zone andDeviceType:devType andFloor:[NSNumber numberWithInt:currentFloor]];
	//set index number as button tag val
	imageButton.tag = [indexTag intValue];
	//add btn to view.
	[self.view addSubview:imageButton];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)sender {
	//handlePan gives us the ability to move devices
	//once they have been moved (panning ended) we update DevicesManager with the new position  

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
				break;
				
			default:
				break;
				
		}
	}
}

- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {
    //---called when the popover view is dismissed---
    NSLog(@"popover dismissed");
    
}

- (IBAction)doneButtonPressed:(id)sender {
	//we have finished creating the devices we can now save the data
	//release the offscreenbuffer and pop back to fireViewController
	NSLog(@"CONTROLVIEWSEGUE --> SAVE DEVICE DATA");
	
		DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
		[sharedDevicesManager saveSettingsToDisk];
		CGContextRelease(offScreenBuffer);
		[self.navigationController popToRootViewControllerAnimated:YES];
	
}

- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender {
	//we must minus 1 floor since all floors start at level 0
	if(currentFloor < (numberOfFloors-1)){
		
		currentFloor++;
		NSString *title = [NSString stringWithFormat:@"Setup Devices - Floor %i", currentFloor];	
		self.title = title; 
		
		[self deleteAllButtons];
		[self rebuildContextImg];
		[imageView1 setNeedsDisplay];
		
	}
}

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
	//handle downSwipe
	if(currentFloor > 0){
		
		currentFloor--;
		NSString *title = [NSString stringWithFormat:@"Setup Devices - Floor %i", currentFloor];	
		self.title = title; 
		
		[self deleteAllButtons];
		[self rebuildContextImg];
		[imageView1 setNeedsDisplay];
	}
	
}

- (IBAction)btnClearAllDevices:(UIButton *)sender {
	//removes all the devices by deleting the button objects and the deviceManager objs
	DevicesManager *sharedDevicesManager = [DevicesManager sharedDevicesManager];
	[sharedDevicesManager deleteAllDeviceObjects];
	[self deleteAllButtons];
	
}

-(void)hideBackBtn{
	//hide the back button since we don't want it visible
	//this is called by firstViewController
	self.navigationItem.hidesBackButton = YES;
}

@end
