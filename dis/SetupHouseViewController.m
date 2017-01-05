//
//  SetupHouseViewController.m
//  dis
//
//  Created by Robert Smith on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


// This viewcontroller is responsible for the HouseView and HouseManager
// it loads HouseView on init and is a good example of MVC design

#import "SetupHouseViewController.h"
#import "HouseManager.h"

@implementation SetupHouseViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [houseView setDelegate:self]; //set the Views delegate to (this) VC
	self.navigationItem.rightBarButtonItem = nil; //we don't need done button on toolbar as alertview takes care of taking user to the next section
	self.navigationItem.hidesBackButton = YES; //hides the back button because it's not needed
	
	//we must be notified by the model when the data changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHouseNotification:) name:@"housePointsChanged" object:nil]; 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHouseClearNotification:) name:@"housePointsChangedClear" object:nil]; 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)handleHouseNotification:(NSNotification *)pNotification{
	[houseView reloadHousePoints]; //notifies the house through public method
}

- (void)handleHouseClearNotification:(NSNotification *)pNotification{
	[houseView resetAllClearButtonPressed]; //notifies the houseview of reset through public method
}

- (void)viewDidUnload{
	// Release any retained subviews of the main view.
    [super viewDidUnload];
	btn_clear = nil;
	barbtn_done = nil;
    houseView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//fixes the orientation to landscape
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (IBAction)cancel:(id)sender{
	//CANCEL button takes us back
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)pressedClear:(id)sender{
    //Delete all button
	//tells the model to delete data
    HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    [sharedHouseManager clearAllPoints];
    
}

- (void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish{
    //This method is the only delegate method that our UIVIEW can repsond with
	//it provides the start and end points of the line
	//this method takes that data and sends it to  the model (HouseManager)
    HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    [sharedHouseManager setHousePoints:start andSetFinish: finish];
	if([self checkForCompleteShape]) [houseView completeHouseShape]; //if complete shape then notify view so it can colour shape
}

- (BOOL)checkForCompleteShape{
    // this method gets an array of house points from HouseManager and checks if the first and last are the same
	// if they are then it will return yes, else no.
	// it also creates an alert to notify the user asking them how many floors they have
    HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
    NSMutableArray *wallArray = [sharedHouseManager getHousePoints];
    if ([wallArray count] > 6){ //> 3 walls
        NSValue *first = [wallArray lastObject];
        NSValue *last = [wallArray objectAtIndex:0];
        CGPoint firstP = [first CGPointValue];
        CGPoint lastP = [last CGPointValue];
        if(firstP.x == lastP.x && firstP.y == lastP.y){
            NSLog(@"Complete shape with CO-ORDS:%@", wallArray);
            //shape is complete
            UIAlertView *alert = [[UIAlertView alloc]init];
			alert.title = @"Nice House Shape";
			alert.message = @"How many floors do you have?";
			alert.delegate = self;
			[alert addButtonWithTitle:@"1"];
			[alert addButtonWithTitle:@"2"];
			[alert addButtonWithTitle:@"3"];
			[alert addButtonWithTitle:@"4"];
			[alert addButtonWithTitle:@"5"];
            [alert show];
            return 1;            
        }
    }
    return 0;  
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	//depending on which button the user picks it will send this number to be stored in the HouseManager
	//this is used by other views. Once this is done it sends the user to the next viewcontroller
	//by invoking the segue.
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
	NSNumber *val = [NSNumber numberWithInteger:(buttonIndex+1)];
	[sharedHouseManager setNumberOfFloors:val];
	[self performSegueWithIdentifier:@"RoomViewSegue" sender:self];
}

- (IBAction)goToRoomsBtn:(UIBarButtonItem *)sender {
	//invoked by the user pressing the done button, it's now obsolete since this is done automatically
	[self performSegueWithIdentifier:@"RoomViewSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	//This is a good point to save to disk because we can ensure that the house data is valid beforehand, it does this by detecting that we are moving to a different scene
	if ([segue.identifier isEqualToString:@"RoomViewSegue"])
	{
		NSLog(@"ROOMVIEWSEGUE --> SAVE HOUSE DATA"); //output to console
		HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
		[sharedHouseManager saveSettingsToDisk];
	}
}


@end
