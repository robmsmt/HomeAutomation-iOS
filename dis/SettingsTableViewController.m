//
//  SettingsTableViewController.m
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"

/*
 This tableViewController is responsbile for letting the user reset the data on their device
 
 there are 3 choices:
 
 1) resetAll --> deletes house&room&device data and sends the user to SetupHouse
 2) resetRooms --> deletes rooms&devices data and sends the user to SetupRooms
 3) resetDevices --> deletes devices data and sends user to SetupDevices
 
 this viewcontroller is simply a table which contains these 3 options, it can can which table index
 was pressed 0,1,2 and call the oppropriate delegate on ControlViewController to perform the actual
 deleting functionality.
 
 */


@implementation SettingsTableViewController

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //onload init and populate the textList array with the textual names
	textList = [[NSMutableArray alloc]init];

	[textList addObject:@"Reset All"];
	[textList addObject:@"Reset Rooms"];
	[textList addObject:@"Reset Devices"];

}

-(void)dealloc{
    
    NSLog(@"dealloc called");
   textList=nil;    

}
- (void)viewDidUnload{
    [super viewDidUnload];
	textList=nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
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
    //return [listOfDevices count];
	return [textList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
 
    cell.textLabel.text = [textList objectAtIndex:indexPath.row];

        return cell;
    
}




#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//this is where the user has pressed on the table
	//depending on which text the user has pressed we can reset the
	//relavent part
	
    if (_delegate != nil) {
		//NSLog(@"index selected:%i", indexPath.row);
        if(indexPath.row == 0){
			[_delegate resetAll];
		} else if(indexPath.row == 1){
			[_delegate resetRooms];
		} else if(indexPath.row == 2){
			[_delegate resetDevices];
		}   

    }
}

@end
