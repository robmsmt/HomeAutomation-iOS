//
//  TriggerTableViewController.m
//  dis
//
//  Created by Robert Smith on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriggerTableViewController.h"
#import "TriggerManager.h"

//this section is responsible for displaying all the triggers in a tableview

@implementation TriggerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//onload get data
	[self getData];


}

-(void)getData{
	//loads the instancevariable arrays with the trigger data stored in trigger manager
	if(!timeTriggerArray) timeTriggerArray = [[NSMutableArray alloc]init];
	if(!sensorTriggerArray) sensorTriggerArray = [[NSMutableArray alloc]init];
	if(!timeDescArray) timeDescArray = [[NSMutableArray alloc]init];
	if(!sensorDescArray) sensorDescArray = [[NSMutableArray alloc]init];
	
	TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
	timeTriggerArray = [sharedTriggerManager triggerTimeObjectsArray];
	sensorTriggerArray = [sharedTriggerManager triggerSensorObjectsArray];
	
	
	for (int i=0;i<[timeTriggerArray count]; i++){
		if ([[timeTriggerArray objectAtIndex:i] respondsToSelector:@selector(isTriggerTime)]) {
			
			NSString* desc = [[timeTriggerArray objectAtIndex:i] performSelector: @selector(returnDesc)];
			[timeDescArray addObject:desc];
		}
	}
	
	for (int i=0;i<[sensorTriggerArray count]; i++){
		if ([[sensorTriggerArray objectAtIndex:i] respondsToSelector:@selector(isTriggerSensor)]) {
			
			NSString* desc = [[sensorTriggerArray objectAtIndex:i] performSelector: @selector(returnDesc)];
			[sensorDescArray addObject:desc];
		}
	}
	
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	//2 sections one for time triggers another for sensors
	
	if (section==0) {
		
		return @"Time Triggers";
	} else {
		return @"Sensor Triggers";
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section based on the number of triggers
	//
	
	if(section == 0) return [timeTriggerArray count];
    else if(section == 1) return [sensorTriggerArray count];
	else return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	//sets the text of each tablerow
	switch (indexPath.section) {
		case 0:
				cell.textLabel.text = [timeDescArray objectAtIndex:indexPath.row];
			break;
		case 1:
				cell.textLabel.text = [sensorDescArray objectAtIndex:indexPath.row];
			break;

		default:
			break;
	}

	return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//this function gives us a delete button to remove triggers when swiping
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		if(indexPath.section == 0){
			//delete data from timertrigger
			TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
			[sharedTriggerManager deleteTimeObjectsAtIndex:indexPath.row];
			timeTriggerArray = [sharedTriggerManager triggerTimeObjectsArray];
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			
		} else if(indexPath.section	== 1){
			//delete data from sensortrigger
			TriggerManager *sharedTriggerManager = [TriggerManager sharedTriggerManager];
			[sharedTriggerManager deleteSensorObjectsAtIndex:indexPath.row];
			sensorTriggerArray = [sharedTriggerManager triggerSensorObjectsArray];
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
    }  
}
	

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (IBAction)addTriggerBtnPressed:(UIBarButtonItem *)sender {
	
	//this method is responsible for creating the ADD TIME TRIGGERS modal display
	UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
	triggerModalPopover=[mainStoryboard instantiateViewControllerWithIdentifier:@"ModalTimeTriggerPopover"];
	triggerModalPopover.modalPresentationStyle = UIModalPresentationFormSheet;
	triggerModalPopover.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:triggerModalPopover animated:YES];
	triggerModalPopover.view.superview.frame = CGRectMake(0, 0, 660, 520);
	triggerModalPopover.view.superview.center = self.view.center;
	[triggerModalPopover setDelegate:self];
	
}

-(void)savedButtonPressed{
	//when the save button is pressed inside the timetrigger screen it causes this method
	//to be called refreshing the arrays and refreshing the table 
	[timeDescArray removeAllObjects];
	[sensorDescArray removeAllObjects];
	[self getData];
	//refresh table to show new added entry
	[self.tableView reloadData];
	
}
@end
