//
//  TriggerViewController.m
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


/*
 This trigger view controller is used to set a trigger on the sensor values
 
 
 firstly it loads the details into the UIPicker
 
 condition
 sensorvalue
 complete action
 
 
 we then pass this information to the triggerManager where it gets stored, this will get interpreted by the trigger parts of the ControlViewContoller and the action will be performed if the details are correct
 
 the user can also pinch the view to close it
 
 */

#import "TriggerViewController.h"
#import "TriggerManager.h"


@implementation TriggerViewController


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
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]]; 
	conditionArray = [[NSMutableArray alloc] init];
    [conditionArray addObject:@" is equal to "];
	[conditionArray addObject:@" is not equal to "];
	[conditionArray addObject:@" is less than "];
	[conditionArray addObject:@" is more than "];
	//[conditionArray addObject:@" is  to "];
	
	valueArray = [[NSMutableArray alloc]init];
	

	
		
	actionArray = [[NSMutableArray alloc]init];
	[actionArray addObject:@" Light On "]; //6,14,1,8,1,154,1,
	[actionArray addObject:@" Light Off "]; //6,14,1,8,1,153,1


	[conditionPicker selectRow:0 inComponent:0 animated:NO];
	[conditionPicker selectRow:10 inComponent:1 animated:NO];
	[conditionPicker selectRow:0 inComponent:2 animated:NO];
    
	
}

-(void)viewWillAppear:(BOOL)animated{

		UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
	recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
	[self.view addGestureRecognizer:recognizer];
	
}

-(void)setSensorName:(NSString *)sensorN{
	
	sensorNameLabel.text = sensorN;
	sensorName = sensorN;
	
	if([sensorName isEqualToString:@"Temperature"]){
		//need temperature
		for(int i = 10; i<45; i++){
			[valueArray addObject:[NSString stringWithFormat:@" %i ", i]];
		}
		sensorSN = [NSNumber numberWithInt:1];
		sensorZN = [NSNumber numberWithInt:4];

	} else if([sensorName isEqualToString:@"Humidity"]){
		//need humidity
		for(int i = 0; i<101; i++){
			[valueArray addObject:[NSString stringWithFormat:@"%i%%", i]];
		}
		sensorSN = [NSNumber numberWithInt:3];
		sensorZN = [NSNumber numberWithInt:4];
		
	} else if([sensorName isEqualToString:@"Light Level"]){
		//need light value
		for(int i = 0; i<7; i++){
			[valueArray addObject:[NSString stringWithFormat:@" %i/6 ", i]];
		}
		sensorSN = [NSNumber numberWithInt:4];
		sensorZN = [NSNumber numberWithInt:4];
	}
	
	
}

- (void)viewDidUnload
{
	conditionPicker = nil;
	sensorNameLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}



- (IBAction)closeBtnPressed:(UIButton *)sender {
	[self dismissModalViewControllerAnimated:YES];
	
	
}

- (IBAction)saveTriggerBtnPressed:(UIButton *)sender {
	
	//when the saved button is pressed this action gets all the values and sends to
	//trigger manager
	
	NSString *condition;
	NSString *value;
	NSString *action;
	NSString *description; //should be sensor name & action.
	
	condition = [self pickerView:conditionPicker titleForRow:[conditionPicker selectedRowInComponent:0] forComponent:0];
	condition = [condition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	value = [self pickerView:conditionPicker titleForRow:[conditionPicker selectedRowInComponent:1] forComponent:1];
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
	action = [self pickerView:conditionPicker titleForRow:[conditionPicker selectedRowInComponent:2] forComponent:2];
	action = [action stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSNumber* actionSN;
	NSNumber* actionZN;
	NSNumber* actionST;

	if([action isEqualToString:@"Light On"]){

		actionSN = [NSNumber numberWithInt:8];
		actionZN = [NSNumber numberWithInt:1];
		actionST = [NSNumber numberWithInt:1];
	} else if([action isEqualToString:@"Light Off"]){

		actionSN = [NSNumber numberWithInt:8];
		actionZN = [NSNumber numberWithInt:1];
		actionST = [NSNumber numberWithInt:0];
	} else {
		//if anything else is selected turn light off

	}
	
	description = [NSString stringWithFormat:@"if %@ %@ %@ then %@",sensorName ,condition, value, action];
	NSLog(@"%@",description);
	
	TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
	
	if([sensorName isEqualToString:@"Temperature"]){
		//need temperature
		
		
	} else if([sensorName isEqualToString:@"Humidity"]){
		//need humidity remove percent symbol
		if ( [value length] > 0)
			value = [value substringToIndex:[value length] - 1];

		
	} else if([sensorName isEqualToString:@"Light Level"]){
		//need light value remove "/6"
		if ( [value length] > 0)
			value = [value substringToIndex:[value length] - 2];
		
	}

	NSNumber *numberFromStr = [NSNumber numberWithInt:[value integerValue]];

	//sends data to triggermanager 
	[sharedTriggerManager setTriggerCondition:condition andSensorVal:numberFromStr andSensorSN:sensorSN andSensorZone:sensorZN andActionSN:actionSN andActionZone:actionZN andActionStatus:actionST andDesc:description];
	
	
	
	
	[self dismissModalViewControllerAnimated:YES];
}


- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
	//handles pinch close
	
    if (sender.state == UIGestureRecognizerStateEnded)
	{
		NSLog(@"PINCHCLOSE TRIGGERED");

			[self dismissModalViewControllerAnimated:YES];
			[self.view.window removeGestureRecognizer:sender];
        
	}
}

//the following sections regard the layout of the pickerview

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
	//sets number of components of picker view
    return 3;
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//
//}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0){
		return [conditionArray count];
		
	} else if(component == 1){
		return [valueArray count];
		
	} else if(component == 2){
		return [actionArray count];
		
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	
	if(component == 0){
		return [conditionArray objectAtIndex:row];
		
	} else if(component == 1){
		return [valueArray objectAtIndex:row];
		
	} else if(component == 2){
		return [actionArray objectAtIndex:row];
		
	}
	return @"undef";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	//this method sets the width of the sections of the picker view
	//condition requires 180px
	//value requires 65px
	//action requires 180px
	switch (component){
		case 0: 
			return 180.0f;
		case 1: 
			return 65.0f;
		case 2:
			return 180.0f;
	}
	return 0;
}


@end
