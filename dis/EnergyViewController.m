//
//  EnergyViewController.m
//  dis
//
//  Created by Robert Smith on 17/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 This simple VC is responsible for the webview that displays the related energy information
 
 on load it creates a URL to the energy php page and sends the URL to the webView defined in
 interface builder accessed by the instanceVar webView.
 
 
 */

#import "EnergyViewController.h"

@interface EnergyViewController ()

@end

@implementation EnergyViewController

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
	
	
	//create URL and send to webview
	NSURL *url = [NSURL URLWithString:@"http://co-project.lboro.ac.uk/users/cors2/FYP/viewer.php"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestURL];
}

- (void)viewDidUnload
{
	webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	
	return YES;

					 
}





@end
