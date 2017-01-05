//
//  ControlDevicePopupViewController.m
//  dis
//
//  Created by Robert Smith on 05/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ControlDevicePopupViewController.h"


@implementation ControlDevicePopupViewController

@synthesize delegate = _delegate;


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

	
	[[deviceImage imageView] setContentMode: UIViewContentModeScaleAspectFit];
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"settingsbackground.png"]];
	[tableView2 setBackgroundColor:[UIColor clearColor]];
    tableView2.backgroundView = nil; 
	currentLabel.font = [UIFont boldSystemFontOfSize:17];
	currentLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	currentLabel.shadowOffset = CGSizeMake(0, 1);
	currentLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0]; //#4c566c
	
}



- (void)viewDidUnload
{

	NSLog(@"viewdidunload called from popover");

	deviceImage = nil;
	deviceSwitch = nil;
	deviceImage = nil;
	deviceBattery = nil;
	deviceValue = nil;
    tableView2 = nil;
	deviceTriggerBtn = nil;
	notificationsArr = nil;
	timestampArr = nil;
	
    batteryBar = nil;
	currentLabel = nil;
	rangePicker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	//remove auto orientation
	return NO;
}

- (IBAction)imageButtonPressed:(UIButton *)sender {
	
	//pressing the image button causes an update or change of switch
	//if device is i/o

	if (deviceType == [NSNumber numberWithInt:0]){
		//its a light use the switch val
		if(deviceSwitch.on){
			//device is currently on therefore we turn it off
			deviceSwitch.on = NO;
			[self switchChanged:deviceSwitch];
		}else{
			//device is currently off theref we turn it on
			deviceSwitch.on = YES;
			[self switchChanged:deviceSwitch];
		}
		
	}	
	else if (deviceType == [NSNumber numberWithInt:1]){
			//sensor type therefore press button gets update
			[_delegate performNetworkUpdateWithDevice:tag];
		
	} else if(deviceType == [NSNumber numberWithInt:2]){
		//range input device detected e.g radiator
		//ability to turn on/max in future versions
		//however I haven't got radiator device to test
	}
}

- (IBAction)switchChanged:(UISwitch	*)sender {
	// this detects when the switch has changed and changes the buttons
	// imagename to imagename+ _on.png and just imagename for off.
	if(sender.isOn){
		NSString* newStr = deviceImg;
		
		if ( [newStr length] > 0)
			newStr = [newStr substringToIndex:[newStr length] - 4]; //removes .png

		newStr = [NSString stringWithFormat:@"%@_on.png", newStr]; //add _on.png
		
		[_delegate performNetworkingWithDevice:tag turn:1];
		[deviceImage setImage:[UIImage imageNamed:newStr] forState:UIControlStateNormal];
		
		
	}else {
		
		[_delegate performNetworkingWithDevice:tag turn:0];
		[deviceImage setImage:[UIImage imageNamed:deviceImg] forState:UIControlStateNormal];

	}
	
	
}

-(void)setName:(NSString *)devname{
	name = devname;
	//we can change the standard interface design here based on name of device
	//for non standard layouts
	if([devname isEqualToString:@"Powermeter"]){
		deviceBattery.hidden = YES;
		batteryBar.hidden = YES;
		deviceTriggerBtn.hidden = YES;
	}
}
-(void)setDeviceType:(NSNumber *)devnum withTag:(int)devTag withNotifications:(NSMutableArray *)arr andTimeStamp:(NSMutableArray *)timeArr withImg:(NSString *)imgName{
	
	//this function is called by the ControlViewController when the device button is pressed i.e. light icon 
	
	deviceType = devnum; //used to determine the load layout type (see block below)
	tag = devTag; //used to call data on vc
	deviceImg = imgName; //image
	
	/*
	 Device numbers are a way of grouping types of devices so that all lights have the same
	 device number and therefore will need the same controller GUI
	 
	 type 0 = lights simple input (on/off) and output 
	 
	 type 1 = sensor output only (doesnt take input)
		to remove battery image/text we must detect individual cases
		when name gets recieved
	 
	 type 2 = ranged input e.g. radiator and output

	 */
	
	//hide all features by default and only enable ones needed
	//for each dev type
	//deviceImage.hidden = YES;
	deviceSwitch.hidden = YES;
	deviceBattery.hidden = YES;
	batteryBar.hidden = YES;
	deviceValue.hidden = YES;
	deviceTriggerBtn.hidden = YES;
	rangePicker.hidden = YES;
	//tableView2.hidden = YES; every page needs noneed to hide
	
	[deviceImage setImage:[UIImage imageNamed:deviceImg] forState:UIControlStateNormal];
	
	
	if(devnum == [NSNumber numberWithInt:0]) {
		//simple io device unhide switch&val
		
		deviceSwitch.hidden = NO;
		deviceValue.hidden = NO;

		
	} else if (devnum == [NSNumber numberWithInt:1]){
		//sensor device unhide battery&val&trigger&batterybar
		
		deviceBattery.hidden = NO;
		deviceValue.hidden = NO;
		deviceTriggerBtn.hidden = NO;
		batteryBar.hidden = NO;
		
		
		
	} else if (devnum == [NSNumber numberWithInt:2]){
		//ranged io device e.g radiator show rangePicker&val

		deviceValue.hidden = NO;
		rangePicker.hidden = NO;

		
	}

	//load in notifications and time stamps
	if(!notificationsArr) notificationsArr = [[NSMutableArray alloc]init ];
	if(!timestampArr) timestampArr = [[NSMutableArray alloc]init ];
	
	//remove all notifications&timestamps
	[notificationsArr removeAllObjects];
	[timestampArr removeAllObjects];
	//this reverses the arrays
	for (id element in [arr reverseObjectEnumerator]) {
		[notificationsArr addObject:element];
	}
	for (id element in [timeArr reverseObjectEnumerator]) {
		[timestampArr addObject:element];
	}
	//reload table
	[tableView2 reloadData];
}

- (IBAction)triggerBtnPressed:(UIButton *)sender {
	//tells the VC that the trigger button has been pressed
	//this will load up the sensor trigger screen
	[_delegate triggerButtonPressed:tag];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section {

	if (section==0) {
		return @"Notifications";
	} else {
		return @"Other";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
		
	//this method fills the notifications table with:
	// datavalue				day hours:mins
	
	if(!notificationsArr) notificationsArr = [[NSMutableArray alloc]init ];
	if(!timestampArr) timestampArr = [[NSMutableArray alloc]init ];
	
	if([notificationsArr count] < 3){
		//add blank objects until there are 3
		
		while([notificationsArr count] < 3){
		[notificationsArr addObject:[NSString stringWithFormat:@""]];
		[timestampArr addObject:[NSString stringWithFormat:@""]];
		}
		
	}
	
	@try{ //stop potential crashes of notification table exceeding the number of rows
		  //this shouldn't happen anymore however is good to have enhanced security
		cell.textLabel.text = [notificationsArr objectAtIndex:indexPath.row];
		cell.detailTextLabel.text = [timestampArr objectAtIndex:indexPath.row];
	}
		
	@catch (NSException *exception) {
		
		NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
		
	}
		
		return cell;
    
}



-(void)updateValue:(NSString *)stringVal{
	//update val called by VC on response from network
	deviceValue.text = stringVal;
	
}

-(void)updateBattery:(NSString *)batt andBatteryFloat:(float)battFloat{
	//update battery called by VC on response from network
	deviceBattery.text = batt;
	batteryBar.progress = battFloat;
	
}
-(void)updateTableWithNotifications:arr andTimeStamp:timeArr{
	//update tablewithnotifications called by VC to ensure update
	
	//load in notifications and time stamps
	if(!notificationsArr) notificationsArr = [[NSMutableArray alloc]init ];
	if(!timestampArr) timestampArr = [[NSMutableArray alloc]init ];
	
	[notificationsArr removeAllObjects];
	[timestampArr removeAllObjects];
	//this reverses the arrays
	for (id element in [arr reverseObjectEnumerator]) {
		[notificationsArr addObject:element];
	}
	for (id element in [timeArr reverseObjectEnumerator]) {
		[timestampArr addObject:element];
	}
	//refresh table
	[tableView2 reloadData];
	
}

-(void)updateImg:(NSString*)img andState:(bool)state{
	//update the image, called by VC when network update recieved
	[deviceImage setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
	deviceSwitch.on = state;
}


@end
