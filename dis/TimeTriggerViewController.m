//
//  TriggerViewController.m
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimeTriggerViewController.h"
#import "TriggerManager.h"

/*
 This time trigger view controller is almost identical to TriggerViewController (for sensors opposed to time)
 
The differences are that this view uses a time UIDatePicker to set the time that the trigger will be performed and a normal UIPicker for the action with only 1 component- the action to be performed.
 Other than that they are identical.
 
 */


@implementation TimeTriggerViewController
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
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]]; 
	actionArray = [[NSMutableArray alloc]init];
	[actionArray addObject:@" Light On "];
	[actionArray addObject:@" Light Off "];


	[actionPicker selectRow:0 inComponent:0 animated:NO];
    
	
}

-(void)viewWillAppear:(BOOL)animated{

	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
	recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
	[self.view addGestureRecognizer:recognizer];
	
}

- (void)viewDidUnload{
	
	actionPicker = nil;
	timePicker = nil;
	actionArray = nil;
	_delegate = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)saveTriggerBtnPressed:(id)sender {
	
	NSString *action;
	NSString *description;
	

	NSDate *myDate = timePicker.date;
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm"];
	NSString *time = [dateFormat stringFromDate:myDate];

	
	action = [self pickerView:actionPicker titleForRow:[actionPicker selectedRowInComponent:0] forComponent:0];
	action = [action stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSNumber* serviceName;
	NSNumber* zone;
	NSNumber* status;
	
	//work out which action trigger has been selected
	if([action isEqualToString:@"Light On"]){

		serviceName = [NSNumber numberWithInt:8];
		zone = [NSNumber numberWithInt:1];
		status = [NSNumber numberWithInt:1];
		
		
	} else if([action isEqualToString:@"Light Off"]){
		serviceName = [NSNumber numberWithInt:8];
		zone = [NSNumber numberWithInt:1];
		status = [NSNumber numberWithInt:0];
		
	} else {
		
		serviceName = [NSNumber numberWithInt:8];
		zone = [NSNumber numberWithInt:3];
		status = [NSNumber numberWithInt:0];
		
	}
	
	description = [NSString stringWithFormat:@"if %@ then %@",time, action];
	NSLog(@"%@",description);
	
	TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
	//send message to triggermanager telling it to store the new trigger
	[sharedTriggerManager setTriggerTime:time andServiceName:serviceName andZone:zone andStatus:status andDesc:description];	
	[self dismissModalViewControllerAnimated:YES];
	//send message to delegate to reload table
	[_delegate savedButtonPressed];
	
}

- (IBAction)closeBtnPressed:(UIButton *)sender {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)handleTapBehind:(UITapGestureRecognizer *)sender{	
    if (sender.state == UIGestureRecognizerStateEnded)
	{
		NSLog(@"PINCHCLOSE TRIGGERED");

			[self dismissModalViewControllerAnimated:YES];
			[self.view.window removeGestureRecognizer:sender];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
		return [actionArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	
		return [actionArray objectAtIndex:row];
		
}

@end
