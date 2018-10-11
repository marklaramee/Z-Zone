//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.

/***********************************************
	This manages the all contacts view 
	alphabetized naturally (without regard to their prefix)
	and handles click events

	Contact object arrays use the following keys
	0 NSNumber record ID
	1 NSString composite name
	2 NSString is this a zzone contact? (YES/NO)
	3 NSString first name
	4 NSString last name 
	5 NSString name order preference (first/last) - set by user in operating system
************************************************/

#import "AllContacts.h"

@implementation AllContacts

@synthesize appDelegate, intTotalRows;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	appDelegate = (Z_ZoneAppDelegate *)[[UIApplication sharedApplication] delegate];
}



- (void)viewWillAppear:(BOOL)animated 
{
    [appDelegate populateAllContacts];
	[self.tableView reloadData];
	[super viewWillAppear:animated];
	intTotalRows=0;
	
}


#pragma mark -
#pragma mark Table view data source
/**
 *	Defines the number of sections for right side alphabetical navigation
 *
 * @param 
 * 		UITableView tableView
 *		The view to act on
 *
 * @return NSInteger
 * 		27 - the number of sections (a-z plus numbers)
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 27;
}

/**
 *	Returns the count of object for each section (for navigation)
 *
 * @param 
 * 		UITableView tableView
 *			The view to act on
 * 		NSInteger section
 *			which section to check
 *
 * @return 
 * 		NSInteger number of contacts in specified section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
	switch (section) 
	{
		case 0:
			return [[appDelegate.arrAllCounts objectAtIndex:section] intValue];
			break;
		default:
			return [[appDelegate.arrAllCounts objectAtIndex:section] intValue] - [[appDelegate.arrAllCounts objectAtIndex:section-1] intValue];
			break;
	}
}

/**
 *	Sets header for right side navigation
 *
 * @param 
 * 		tableView tableView
 *			The view to act on
 * 		NSInteger section
 *			which section to check
 *
 * @return 
 * 		NSString alphabetical section header (for displaay)
 */
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [appDelegate.arrLetters objectAtIndex:section];
}

/**
* boilerplate 
*/
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{	
	return index;	
}

/**
* provide array (from Z_ZoneAppDelegate) that maps index to letter
*/
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return appDelegate.arrLetters;
}

/**
 *	Create cell/contact for view
 *
 * @param 
 * 		tableView tableView
 *			The view to act on
 * 		NSIndexPath indexPath
 *			which cell to operate on
 *
 * @return 
 * 		UITableViewCell the processed cell view
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //intialize vars
    static NSString *CellIdentifier = @"Cell";
	NSUInteger intCurrentIndex;

	//get the index of cell to operate on
	switch (indexPath.section) 
	{
		case 0:
			intCurrentIndex=indexPath.row;
			break;
		default:
			intCurrentIndex = indexPath.row +  [[appDelegate.arrAllCounts objectAtIndex:indexPath.section-1] intValue];
			break;
	}
	
    //Get the cell and its configurations 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else 
	{
		UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
		transparentBackground.backgroundColor = [UIColor clearColor];
		cell.backgroundView = transparentBackground;
		cell.textLabel.textColor = [UIColor blackColor];
		[transparentBackground release];
	}
    
    // Configure the cell...
	if([[appDelegate.arrContacts objectAtIndex:intCurrentIndex] objectAtIndex:2]==@"YES")
	{
		//set Z-Zone display configuration
		UIImage *imgBackground = [UIImage imageNamed:@"zzone_cell_bg_purple.png"];
		cell.backgroundView = [[UIImageView alloc] initWithImage:imgBackground];
		cell.textLabel.textColor =[UIColor whiteColor];
		[imgBackground release];
	}
	else 
	{
		//Set normal configuration
		cell.textLabel.textColor = [UIColor blackColor];
	}
	[[cell textLabel]setText:[[appDelegate.arrContacts objectAtIndex:intCurrentIndex] objectAtIndex:1]];
	[[cell textLabel]setBackgroundColor:[UIColor clearColor]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



#pragma mark -
#pragma mark Table view delegate
/**
 *	Handle cell click events
 *
 * @param 
 * 		tableView tableView
 *			The view to act on
 * 		NSIndexPath indexPath
 *			the cell to operate on
 *
 * @return 
 * 		none, saves contact to iOS address book
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//get the index of cell to operate on
	NSUInteger intCurrentIndex;
	switch (indexPath.section) 
	{
		case 0:
			intCurrentIndex=indexPath.row;
			break;
		default:
			intCurrentIndex = indexPath.row +  [[appDelegate.arrAllCounts objectAtIndex:indexPath.section-1] intValue];
			break;
	}
	
	//get the clicked cell object
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	//set the formatting options for the cell (show background?)
	if([cell.backgroundView isKindOfClass:[UIImageView class]])
	{
		//a normal record
		UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
		transparentBackground.backgroundColor = [UIColor clearColor];
		cell.backgroundView = transparentBackground;
		cell.textLabel.textColor = [UIColor blackColor];
		[transparentBackground release];
	}
	else 
	{
		//a zzone record
		UIImage *imgBackground = [UIImage imageNamed:@"zzone_cell_bg_purple.png"];
		cell.backgroundView = [[UIImageView alloc] initWithImage:imgBackground];
		cell.textLabel.textColor =[UIColor whiteColor];
		[imgBackground release];
	}
	
	//get unprefixed contact text
	NSArray *arrContactText = [[NSArray alloc] init];
	arrContactText = [appDelegate.arrContacts objectAtIndex:intCurrentIndex];

	//save the contact to iOS address book
	[appDelegate modContact:arrContactText];
	
	//swap the Z-Zone value
	NSString *strzZone;
	if([arrContactText objectAtIndex:2]==@"YES")
	{
		strzZone = @"NO";
	}
	else 
	{
		strzZone = @"YES";
	}

	//update the contact array (keys at top of file)
	[appDelegate.arrContacts replaceObjectAtIndex:intCurrentIndex withObject:[[NSArray alloc] initWithObjects:[arrContactText objectAtIndex:0], 
		[arrContactText objectAtIndex:1],[strzZone copy],[arrContactText objectAtIndex:3],
		[arrContactText objectAtIndex:4],[arrContactText objectAtIndex:5],nil]];
	
	//garbage collection
	[strzZone release];
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)dealloc 
{
	[appDelegate release];
    [super dealloc];
}

@end

