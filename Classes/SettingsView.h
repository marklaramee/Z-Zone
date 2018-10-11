//
//  SettingsView.h
//  Z-Zone
//
//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Z_ZoneAppDelegate.h"


@interface SettingsView : UIViewController 
{
	IBOutlet UITextField *txtPrefix;
	IBOutlet UIActivityIndicatorView *objLoading;
	Z_ZoneAppDelegate *appDelegate;
	IBOutlet UIScrollView *vwScroll;
}
@property (nonatomic, retain) UIScrollView  *vwScroll;
@property (nonatomic, retain) IBOutlet UITextField *txtPrefix;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *objLoading;
@property (nonatomic, retain) Z_ZoneAppDelegate *appDelegate;
-(IBAction)savePrefix:(id)sender;
-(IBAction)hideKeyboard:(id)sender;



@end
