//
//  SetupRoomsViewController.m
//  dis
//
//  Created by Robert Smith on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This viewcontroller is responsible for the RoomView and RoomManager
// it loads RoomView on init and is a good example of MVC design since 
// all room communication is done via this VC

#import "SetupRoomsViewController.h"
#import "RoomManager.h"
#import "HouseManager.h"


@implementation SetupRoomsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {

	}
	return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [roomView setDelegate:self]; //set roomViews this VC as roomViews delegate
	
	//we should delete any existing room data incase user has gone back and changed house shape
	RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
	[sharedRoomManager deleteAllRoomObjects];
	
	[self registerObserver];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
	
	self.title = @"Setup Rooms - Floor 0"; //sets title
	
	//on load first floor is always 0
	currentFloor = 0;
	
	//number of floors only needs to be recieved on load
	HouseManager *sharedHouseManager = [HouseManager sharedHouseManager];
	numberOfFloors = [[sharedHouseManager getNumberOfFloors] intValue];


}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	 [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	//restrict to landscape only
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)registerObserver {
	//register for notifications for the room data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRoomObjNotification:) name:@"roomObjectsChanged" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRoomObjNotification:) name:@"roomPointsChanged" object:nil];
}

- (void)handleRoomObjNotification:(NSNotification *)pNotification{
    //update roomview with latest array
	[roomView updateRooms];
}

- (IBAction)upSwipe:(UISwipeGestureRecognizer *)sender {
	//we must minus 1 floor since all floors start at level 0
	if(currentFloor < (numberOfFloors-1)){
		
		currentFloor++;
		NSString *title = [NSString stringWithFormat:@"Setup Rooms - Floor %i", currentFloor];	
		self.title = title; 
		
		[roomView setFloorLevel:currentFloor];
		[roomView rebuildContextImg];
		[roomView setNeedsDisplay];
	}
}

- (IBAction)downSwipe:(UISwipeGestureRecognizer *)sender {
	//handle downSwipe
	if(currentFloor > 0){
		
		currentFloor--;
		NSString *title = [NSString stringWithFormat:@"Setup Rooms - Floor %i", currentFloor];	
		self.title = title; 
		
		[roomView setFloorLevel:currentFloor];
		[roomView rebuildContextImg];
		[roomView setNeedsDisplay];
	}

}

- (void) wallSetStart:(CGPoint)start andSetFinish:(CGPoint)finish{
	//this method is called from the RoomView class, it provides the start
	//and finish points which are then sent to the RoomManager
	//the room is then checked to see if it is complete
	//if it is then we can update the roomView
	
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    [sharedRoomManager setRoomPoints:start andSetFinish: finish];
	
	
	if([self checkForCompleteShape]) [roomView completeRoomShapeCreated];
	
}

- (BOOL)checkForCompleteShape{
	
	// this method gets an array of room points from roomManager and checks if the first and last are the same
	// if they are then it will return yes, else no.
	// it also creates an alert to notify the user asking them what the room is called
    
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    NSMutableArray *wallArray = [sharedRoomManager roomPoints];
	
    if ([wallArray count] > 6){ //> 3 walls
    
        NSValue *first = [wallArray lastObject];
        NSValue *last = [wallArray objectAtIndex:0];
        CGPoint firstP = [first CGPointValue];
        CGPoint lastP = [last CGPointValue];
    
        if(firstP.x == lastP.x && firstP.y == lastP.y){
            
            
            UIAlertView *roomName = [[UIAlertView alloc] initWithTitle:@"What is this room called?"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Default"
                                                     otherButtonTitles:@"Set", nil];
            
            [roomName setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[roomName textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
            [roomName show];
            
            return 1;            
        }
        
    }

return 0;  

}

- (IBAction)deleteLastRoom:(id)sender {
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    [sharedRoomManager deleteLastRoom];
    //[roomView setupVariables];
	[roomView setFloorLevel:currentFloor];

}

- (IBAction)deleteAll:(id)sender {
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    [sharedRoomManager deleteAllRoomObjects];
	[roomView setupVariables];
	[roomView setFloorLevel:currentFloor];
}

- (IBAction)goToDevices:(UIBarButtonItem *)sender {
	//check that rooms are okay condition first
	//then goto device
	[self performSegueWithIdentifier:@"DevicesViewSegue" sender:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	//detect whether the the user presses default or types their own room name
    if(buttonIndex == 0){
        name = @"Default";
        [self sendCompleteObjToManager];
        
    }else if(buttonIndex == 1){
        name = [[alertView textFieldAtIndex:0] text];
        [self sendCompleteObjToManager];
    }
    
}

- (void)sendCompleteObjToManager{
    //this method is called from the alert view when the user enters a name
	//for a room or presses enter, it then assigns a random colour to the room
	
    RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
    
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	
	
    UIColor *col = [UIColor colorWithRed:red green:green blue:blue alpha:0.3];
    [sharedRoomManager createRoomObject:name andColor:col andFloor:[NSNumber numberWithInt:currentFloor]];
    [[sharedRoomManager roomPoints] removeAllObjects];
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
	//ensure that the user types at least 2 characters
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] >= 2 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([segue.identifier isEqualToString:@"DevicesViewSegue"])
	{	
		//detect when about to change to next view and save the room data
		
		NSLog(@"DEVICESVIEWSEGUE --> SAVE ROOM DATA");
		
		RoomManager *sharedRoomManager = [RoomManager sharedRoomManager];
		[sharedRoomManager saveSettingsToDisk];
	}
}

- (void)hideBackBtn{
	//hide button invoked by firstViewController when loading data from disk
	//ensures user can't get to area they shouldn't.
	self.navigationItem.hidesBackButton = YES;
}



@end
