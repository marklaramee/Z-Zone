//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.

/***********************************************
	This manages the Z-Zone contacts view
	and handles click events

	Contact object arrays use the following keys
	0 NSNumber record ID
	1 NSString composite name
	2 NSString is this a zzone contact? (YES/NO)
	3 NSString first name
	4 NSString last name 
	5 NSString name order preference (first/last) - set by user in operating system
************************************************/

#import "ZzoneContacts.h"

@implementation ZzoneContacts

@synthesize appDelegate;

#pragma mark -
#pragma mark View lifecycle

/**
 *	Boilerplate iOS method
 */
- (void)viewDidLoad 
{
    [super viewDidLoad];
	appDelegate = (Z_ZoneAppDelegate *)[[UIApplication sharedApplication] delegate];
}

/**
 *	Boilerplate iOS method
 */
- (void)viewWillAppear:(BOOL)animated 
{
	[appDelegate populateZContacts];
	[self.tableView reloadData];
    [super viewWillAppear:animated];
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
 * 		27 - A-Z plus one number section
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
 * 		NSInteger number of contacts in section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) 
	{
		case 0:
			return [[appDelegate.arrZCounts objectAtIndex:section] intValue];
			break;
		default:
			return [[appDelegate.arrZCounts objectAtIndex:section] intValue] - [[appDelegate.arrZCounts objectAtIndex:section-1] intValue];
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
* sprovide array (from Z_ZoneAppDelegate) that maps index to letter
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
			intCurrentIndex = indexPath.row +  [[appDelegate.arrZCounts objectAtIndex:indexPath.section-1] intValue];
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
    
	// Configure the cell
	if([[appDelegate.arrZzoneContacts objectAtIndex:intCurrentIndex] objectAtIndex:2]==@"YES")
	{
		//set Z-Zone display values
		UIImage *imgBackground = [UIImage imageNamed:@"zzone_cell_bg_purple.png"];
		cell.backgroundView = [[UIImageView alloc] initWithImage:imgBackground];
		cell.textLabel.textColor =[UIColor whiteColor];
		[imgBackground release];
		
	}
	else 
	{
		cell.textLabel.textColor = [UIColor blackColor];
	}
	[[cell textLabel]setText:[[appDelegate.arrZzoneContacts objectAtIndex:intCurrentIndex] objectAtIndex:1]];
	[[cell textLabel]setBackgroundColor:[UIColor clearColor]];
	[[cell textLabel]setBackgroundColor:[UIColor clearColor]];	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

/**
 *	Handle cell row/contact click events
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
			intCurrentIndex = indexPath.row +  [[appDelegate.arrZCounts objectAtIndex:indexPath.section-1] intValue];
			break;
	}
	
	//get the clicked cell object
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	//set the formatting options for the cell (show background?)
	if([cell.backgroundView isKindOfClass:[UIImageView class]])
	{
		UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
		transparentBackground.backgroundColor = [UIColor clearColor];
		cell.backgroundView = transparentBackground;
		cell.textLabel.textColor = [UIColor blackColor];
		[transparentBackground release];
	}
	else 
	{
		UIImage *imgBackground = [UIImage imageNamed:@"zzone_cell_bg_purple.png"];
		cell.backgroundView = [[UIImageView alloc] initWithImage:imgBackground];
		cell.textLabel.textColor =[UIColor whiteColor];
		[imgBackground release];
	}
	
	//get unprefixed contact text
	NSArray *arrContactText = [[NSArray alloc] init];
	arrContactText = [appDelegate.arrZzoneContacts objectAtIndex:intCurrentIndex];

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
	[appDelegate.arrZzoneContacts replaceObjectAtIndex:intCurrentIndex withObject:[[NSArray alloc] initWithObjects:[arrContactText objectAtIndex:0], 
		[arrContactText objectAtIndex:1],[strzZone copy],[arrContactText objectAtIndex:3],
		[arrContactText objectAtIndex:4],[arrContactText objectAtIndex:5],nil]];

	//garbage collection
	[strzZone release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
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

