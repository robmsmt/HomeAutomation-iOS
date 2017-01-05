//
//  FirstViewController.m
//  dis
//
//  Created by Robert Smith on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*This VC is responsible for the where the user is directed based on what saved data they have
 
 if user has no houseData --> load SetupHouse, ELSE
			 no roomData --> load SetupRooms, ELSE
			 no deviceData --> load SetupDevices, ELSE
							--> load control*/

#import "FirstViewController.h"
#import "DevicesManager.h"
#import "RoomManager.h"
#import "HouseManager.h"
	
#define kHouseData   @"houseData"
#define kRoomData   @"roomData"
#define kDeviceData   @"deviceData"
#define kDatabaseData @"deviceDatabase.sql"
 
@interface FirstViewController ()

@end

@implementation FirstViewController


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
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];

}


-(void)viewDidAppear:(BOOL)animated{
	//create path for house,room and device data
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dataPathHouse = [[paths objectAtIndex:0] stringByAppendingPathComponent:kHouseData];
	NSString *dataPathRoom = [[paths objectAtIndex:0] stringByAppendingPathComponent:kRoomData];
	NSString *dataPathDevice = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDeviceData];
	
	//delete device database- the shared networking will recreate this
	//this is to ensure that the database file is the most recent
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *database = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDatabaseData];
	[fileManager removeItemAtPath:database error:NULL];
	
	//create datatype from path
	NSData *houseData = [[NSMutableData alloc] initWithContentsOfFile:dataPathHouse];
	NSData *roomData = [[NSMutableData alloc] initWithContentsOfFile:dataPathRoom];
	NSData *deviceData = [[NSMutableData alloc] initWithContentsOfFile:dataPathDevice];
	
	//we can then test to see if the path/data exists and depending on wether it does or
	//not direct the person to the correct location
	if (!houseData) {
		NSLog(@"No house data --> loading house");
		[self performSegueWithIdentifier:@"SetupSegue" sender: self];
	} else if (!roomData) {
		NSLog(@"No room data --> loading room");
		[self performSegueWithIdentifier: @"RoomViewSegue" sender: self];
	} else if (!deviceData){
		NSLog(@"No device data --> loading device");
		[self performSegueWithIdentifier: @"DevicesViewSegue" sender: self];
	} else {
		NSLog(@"All data req --> loading control");
		[self performSegueWithIdentifier: @"ControlSegue" sender: self];
	}
   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
	//we detect when a segue is about to be performed and try to remove the 
	//auto generated back button to this FirstViewController since there is no
	//need for the user to get back here
	
	if ([segue.identifier isEqualToString:@"SetupSegue"])
	{
		//back btn hidden by default here.
		
	} else if([segue.identifier isEqualToString:@"RoomViewSegue"]){
		
		[segue.destinationViewController performSelector:@selector(hideBackBtn)];
	} else if([segue.identifier isEqualToString:@"DevicesViewSegue"]){
		[segue.destinationViewController performSelector:@selector(hideBackBtn)];
		
	} else if([segue.identifier isEqualToString:@"ControlSegue"]){
		//back btn hidden by default here.
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	//force landscape orientation
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
