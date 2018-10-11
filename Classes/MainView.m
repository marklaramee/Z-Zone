//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.
//
// intializes app view

#import "MainView.h"


@implementation MainView
@synthesize vwScroll;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	vwScroll.contentSize = CGSizeMake(320.0, 380.0);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}


- (void)dealloc 
{
	[vwScroll release];
    [super dealloc];
}

@end
