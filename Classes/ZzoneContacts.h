//
//  ZzoneContacts.h
//  Z-Zone
//
//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Z_ZoneAppDelegate.h"

@interface ZzoneContacts : UITableViewController 
{
	Z_ZoneAppDelegate *appDelegate;
}

@property (nonatomic,retain) Z_ZoneAppDelegate *appDelegate;


@end
