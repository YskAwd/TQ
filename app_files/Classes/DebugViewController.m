//
//  DebugViewController.m
//  WWY
//
//  Created by awaBook on 09/06/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DebugViewController.h"
#import "WWYViewController.h"

@implementation DebugViewController

@synthesize parentViewController;
@synthesize textViewForDebug;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.view.frame = CGRectMake(0, 310, self.view.frame.size.width, self.view.frame.size.height);
	}
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(IBAction)startMoveUpOnDebug{
	[parentViewController moveStartOnDebug:0];
}
-(IBAction)startMoveRightOnDebug{
	[parentViewController moveStartOnDebug:1];
}
-(IBAction)startMoveDownOnDebug{
	[parentViewController moveStartOnDebug:2];
}
-(IBAction)startMoveLeftOnDebug{
	[parentViewController moveStartOnDebug:3];
}
-(IBAction)stopMoveOnDebug{
	[parentViewController moveStopOnDebug];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
