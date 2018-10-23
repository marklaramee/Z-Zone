//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.
//
// manages the settings view (allows default prefix change)
// functionality handled in Z_ZoneAppDelegate

#import "SettingsView.h"
#import <AddressBook/AddressBook.h>

@implementation SettingsView

@synthesize txtPrefix;
@synthesize appDelegate;
@synthesize objLoading;
@synthesize vwScroll;

// Implement viewDidLoad to do additional setup (from a nib) after loading the view.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	appDelegate = (Z_ZoneAppDelegate *)[[UIApplication sharedApplication] delegate];
	txtPrefix.text=[appDelegate strPrefix];
	vwScroll.contentSize = CGSizeMake(320.0, 300.0);
}

//if prefix text has changed and it is not empty then update, otherwise just hide the keyboard
-(IBAction) savePrefix:(id)sender
{
	if(txtPrefix.text!=[appDelegate strPrefix] && [txtPrefix.text length] > 0)
	{
		[objLoading performSelectorInBackground: @selector(startAnimating) withObject: nil];
		[appDelegate resetPrefix:txtPrefix.text];
		UIAlertView *vwAlert;
		vwAlert = [[UIAlertView alloc] initWithTitle:@"You contacts have been updated" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[vwAlert show];
		[vwAlert release];
		[objLoading stopAnimating];
	}
	[txtPrefix resignFirstResponder];
}

-(IBAction)hideKeyboard:(id)sender
{
	//
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

//garbage collection
- (void)dealloc 
{
	[objLoading release];
	[txtPrefix release];
	[appDelegate release];
	[vwScroll release];
	[super dealloc];
}

@end
