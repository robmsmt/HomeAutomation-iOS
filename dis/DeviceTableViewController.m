//
//  DeviceTableViewController.m
//  dis
//
//  Created by Robert Smith on 25/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//This file is a simple popup device table view
//it asks the zigbee adapter what is connected, when it replys it fills the table with the connected devices/imgs/name
//when the user selects a device it informs the SetupDevicesVC

#import "DeviceTableViewController.h"


@implementation DeviceTableViewController
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
    
	if(!sharedNetworking){
		sharedNetworking = [[SharedNetworking alloc]initWithDelegate:self] ;
	}
	
	
    [self addHeader];
	listOfDevID = [[NSMutableArray alloc]init];
    listOfDevices = [[NSMutableArray alloc]init];
    listOfImages = [[NSMutableArray alloc]init];
	listOfServiceNames = [[NSMutableArray alloc]init];
	listOfZones = [[NSMutableArray alloc] init];
	listOfDevType = [[NSMutableArray alloc] init];
    //we must get the devices from zigbee and fill this array.

	//example devices
	[listOfDevID addObject:[NSNumber numberWithInt:1]];
	[listOfDevices addObject:@"Example Lamp"];
	[listOfImages addObject:@"lightbulb.png"];
	[listOfServiceNames addObject:[NSNumber numberWithInt:8]];
	[listOfZones addObject:[NSNumber numberWithInt:1]];
	[listOfDevType addObject:[NSNumber numberWithInt:0]];
	
	[listOfDevID addObject:[NSNumber numberWithInt:2]];
	[listOfDevices addObject:@"Example Thermometer"];
	[listOfImages addObject:@"thermometer.png"];
	[listOfServiceNames addObject:[NSNumber numberWithInt:1]];
	[listOfZones addObject:[NSNumber numberWithInt:4]];
	[listOfDevType addObject:[NSNumber numberWithInt:1]];
	
}


-(void)networkResponseDevID:(NSMutableArray *)aDevID andDevName:(NSMutableArray *)aDevName andDevImg:(NSMutableArray *)aDevImg andServiceName:(NSMutableArray *)aServName andZone:(NSMutableArray *)aZone andDevType:(NSMutableArray *)aDevType{
	//here we handle the response from the network
	//the array is filled with UID's from the database.
	
	
	NSLog(@"responseDevicesOnNetworkCalled");
	
	[listOfDevID addObjectsFromArray:aDevID];
	[listOfDevices addObjectsFromArray:aDevName];
	[listOfImages addObjectsFromArray:aDevImg];
	[listOfServiceNames addObjectsFromArray:aServName];
	[listOfZones addObjectsFromArray:aZone];
	[listOfDevType addObjectsFromArray:aDevType];

	if ([listOfDevices count] > 1) self.tableView.tableHeaderView = nil;
        
	[self.tableView reloadData];
	[sharedNetworking disconnect];
	
}

-(void)dealloc{
    
    NSLog(@"dealloc called");
    listOfDevices=nil;
    listOfImages=nil;  

}

- (void)viewDidUnload{
    [super viewDidUnload];
    listOfDevices=nil;
    listOfImages=nil;
	listOfServiceNames=nil;
	listOfZones=nil;
	listOfDevType=nil;
    // Release any retained subviews of the main view.

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
    return [listOfDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...

    cell.imageView.image = [UIImage imageNamed:[listOfImages objectAtIndex:indexPath.row]];
    cell.textLabel.text = [listOfDevices objectAtIndex:indexPath.row];

        return cell;
    
}

-(void)addHeader{
    
	//this header gives the user a UIActivity spinner when the data is loading and we are waiting 
	//for a reply from the ZigBee adapter
	
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 40)];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [container addSubview:activityIndicator];
    activityIndicator.frame = CGRectMake(140, 5, 30, 30);
    
    CGRect frame = CGRectMake(0,0, self.view.bounds.size.width,self.view.bounds.size.height);
    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    container.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.tableHeaderView = container;
    [activityIndicator startAnimating];
}



#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//when the user selects a device from the table  we get needed info
	//then send the data to the delegate SetupDevicesViewController which builds the button
   
    if (_delegate != nil) {
        NSString *name = [listOfDevices objectAtIndex:indexPath.row];
        NSString *imgname = [listOfImages objectAtIndex:indexPath.row];
		NSNumber *serv = [listOfServiceNames objectAtIndex:indexPath.row];
		NSNumber *zone = [listOfZones objectAtIndex:indexPath.row];
		NSNumber *devType = [listOfDevType objectAtIndex:indexPath.row];
		
		
        [_delegate deviceNameSelected:name andImageName:imgname andServiceName:serv andZone:zone andDevType:devType];

    }
}

@end
