//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.

/***********************************************
	This is where all of the contact processing happens
		It was necessary to use C language in some places to work natively with the iPhone contacts
		As Objective-C did not provide the necessary tools to do what I wanted

		Contact object arrays use the following keys
		0 NSNumber record ID
	 	1 NSString composite name
	 	2 NSString is this a zzone contact? (YES/NO)
	 	3 NSString first name
	 	4 NSString last name 
	 	5 NSString name order preference (first/last) - set by user in operating system
************************************************/

#import "Z_ZoneAppDelegate.h"
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation Z_ZoneAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize arrContacts;
@synthesize arrZzoneContacts;
@synthesize arrNormalContacts;
@synthesize strPrefix;
@synthesize arrAllCounts, arrLetters, arrZCounts, arrNormalCounts;

#pragma mark -
#pragma mark Application lifecycle

/**
 * Required method to handle application launch
 *
 * @param 
 *	boilerplate parameters
 *
 * @return 
 *	YES, as required by operating system
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	
	//Get the user settings
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	//get the saved alternate prefix, if it exists
	strPrefix = [userDefaults objectForKey:@"strPrefix"];
	//if it does not exist, use the default "zzz"
	if (strPrefix==nil) 
	{
		strPrefix=@"Zzz";
	}
	
	//This is used to created the alphabetized right navigation for scrolling quickly through contacts
	arrLetters = [[NSArray alloc] initWithObjects:@"#",@"A",@"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
				  @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
		
	//Global variables
	arrContacts = [[NSMutableArray alloc] init];       //array of all contacts
	arrZzoneContacts = [[NSMutableArray alloc] init];  //array of Z-Zone contacts
	arrNormalContacts = [[NSMutableArray alloc] init]; //array of non Z-Zone contacts
	
	//Get the contact counts of each view, segmented alphabetically (plus a segment of contacts that begin with a number)
	arrAllCounts = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
	
	arrZCounts = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
				  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
	
	arrNormalCounts = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
					   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];

	// Override point for customization after application launch.
	[window addSubview:tabBarController.view];
	[self.window makeKeyAndVisible];
    
	return YES;
}


/**
 * Populate all contacts array (regardless of prefix)
 *
 * @return 
 *	none, populates global arrays
 */
-(void)populateAllContacts
{
	//initialize arrAllCounts (segmented by letter/number)
	for (int iii=0; iii<27; iii++) 
	{
		[arrAllCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:0]];
	}
	
	//Declare contact variables
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook); //get the complete collection of contact objects
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);  //get the total count of people as a loop count
	ABRecordRef objRecord;
	ABRecordID objRecordId;
	ABPersonSortOrdering objNamePreference; 
	NSRange intZprefix;

	[arrContacts removeAllObjects];
	//loop through all contacts
	for( int i = 0 ; i < nPeople ; i++ )
	{
		//initialize vars
		NSString *strCompositeName, *strFirstName, *strLastName;
		NSString  *strZzoneComparable, *strZzone, *strOrderPreference;
		
		objRecord = CFArrayGetValueAtIndex(allPeople, i );
		objRecordId = ABRecordGetRecordID(objRecord); 
		strFirstName = [(NSString *)ABRecordCopyValue(objRecord, kABPersonFirstNameProperty) autorelease];
		strLastName  = [(NSString *)ABRecordCopyValue(objRecord, kABPersonLastNameProperty) autorelease];
		objNamePreference = ABPersonGetSortOrdering();

		//don't allow empty first or last names
		if(strFirstName==nil)
		{
			strFirstName=@" ";
		}
		if(strLastName==nil)
		{
			strLastName=@" ";
		}
		
		//To find out if this person is in the Zzone
		//first determine if they order their contact book by first or last name
		//also strip prefix, if exists, for purposes of sorting
		if (objNamePreference==kABPersonSortByFirstName) 
		{
			strZzoneComparable=strFirstName;
			strOrderPreference=@"first";
			strCompositeName = [NSString stringWithFormat:@"%@ %@", [self stripPrefix:strFirstName], strLastName];
		}
		else 
		{
			strZzoneComparable=strLastName;
			strOrderPreference=@"last";
			//handle cases where ordering is by last name; but, no last name exists for this contact
			if ([[self stripPrefix:strLastName] length]>1) 
			{
				strCompositeName = [NSString stringWithFormat:@"%@, %@", [self stripPrefix:strLastName], strFirstName];
			}
			else 
			{
				strCompositeName = [NSString stringWithFormat:@"%@", strFirstName];
			}	
		}

		//here's where the prefix is detected (or not)
		intZprefix = [strZzoneComparable rangeOfString: (NSString *)strPrefix];
		NSArray *arrRecord;
		if(intZprefix.location==0)
		{
			//Zzone
			strZzone=@"YES";
		}
		else 
		{
			strZzone=@"NO";
		}
		//create the record with keys (delineated at top of file)
		arrRecord = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:objRecordId], strCompositeName, strZzone, strFirstName, strLastName, strOrderPreference, nil];
		[arrContacts addObject:arrRecord];
		[arrRecord release];
	}
	
	//now that we have all of the contacts, sort them
	[arrContacts sortUsingFunction:order context:NULL];
	
	//update alphabetic contact counts
	for (NSArray *arrContact in arrContacts) 
	{
		NSString *firstLetter = [[[arrContact objectAtIndex:1] substringToIndex:1] lowercaseString]; 
		if ([firstLetter isEqualToString: @"a"]) 
		{
			[arrAllCounts replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:1] intValue]+1]];	
		}
		else if ([firstLetter isEqualToString: @"b"]) 
		{
			[arrAllCounts replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:2] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"c"])
		{
			[arrAllCounts replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:3] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"d"])
		{
			[arrAllCounts replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:4] intValue]+1]];		
		}
		else if ([firstLetter isEqualToString: @"e"])
		{
			[arrAllCounts replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:5] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"f"])
		{
			[arrAllCounts replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:6] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"g"])
		{
			[arrAllCounts replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:7] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"h"])
		{
			[arrAllCounts replaceObjectAtIndex:8 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:8] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"i"])
		{
			[arrAllCounts replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:9] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"j"])
		{
			[arrAllCounts replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:10] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"k"])
		{
			[arrAllCounts replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:11] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"l"])
		{
			[arrAllCounts replaceObjectAtIndex:12 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:12] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"m"])
		{
			[arrAllCounts replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:13] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"n"])
		{
			[arrAllCounts replaceObjectAtIndex:14 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:14] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"o"])
		{
			[arrAllCounts replaceObjectAtIndex:15 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:15] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"p"])
		{
			[arrAllCounts replaceObjectAtIndex:16 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:16] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"q"])
		{
			[arrAllCounts replaceObjectAtIndex:17 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:17] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"r"])
		{
			[arrAllCounts replaceObjectAtIndex:18 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:18] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"s"])
		{
			[arrAllCounts replaceObjectAtIndex:19 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:19] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"t"])
		{
			[arrAllCounts replaceObjectAtIndex:20 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:20] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"u"])
		{
			[arrAllCounts replaceObjectAtIndex:21 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:21] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"v"])
		{
			[arrAllCounts replaceObjectAtIndex:22 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:22] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"w"])
		{
			[arrAllCounts replaceObjectAtIndex:23 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:23] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"x"])
		{
			[arrAllCounts replaceObjectAtIndex:24 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:24] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"y"])
		{
			[arrAllCounts replaceObjectAtIndex:25 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:25] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"z"])
		{
			[arrAllCounts replaceObjectAtIndex:26 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:26] intValue]+1]];
		}
		else 
		{
			[arrAllCounts replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[arrAllCounts objectAtIndex:0] intValue]+1]];
		}
	}
		
	for (int iii=1; iii<27; iii++) 
	{
		[arrAllCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:([[arrAllCounts objectAtIndex:iii-1] intValue] + [[arrAllCounts objectAtIndex:iii] intValue])]];
	}

	//garbage collection
	CFRelease(addressBook);
	CFRelease(allPeople);
}


/**
 * Populate Z-Zone contacts array
 *
 * @return 
 *	none, populates global arrays
 *
 * see populateAllContacts() (above) for detailed commenting on functionality
 */
-(void)populateZContacts
{
	for (int iii=0; iii<27; iii++) 
	{
		[arrZCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:0]];
	}
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	ABRecordRef objRecord;
	ABRecordID objRecordId;
	ABPersonSortOrdering objNamePreference;
	NSRange intZprefix;
	[arrZzoneContacts removeAllObjects];

	
	for( int i = 0 ; i < nPeople ; i++ )
	{
		NSString *strCompositeName, *strFirstName, *strLastName;
		NSString  *strZzoneComparable, *strZzone, *strOrderPreference;
		objRecord = CFArrayGetValueAtIndex(allPeople, i );
		objRecordId = ABRecordGetRecordID(objRecord); 
		strFirstName = [(NSString *)ABRecordCopyValue(objRecord, kABPersonFirstNameProperty) autorelease];
		strLastName  = [(NSString *)ABRecordCopyValue(objRecord, kABPersonLastNameProperty) autorelease];
		objNamePreference = ABPersonGetSortOrdering();
		
		
		if(strFirstName==nil)
		{
			strFirstName=@" ";
		}
		if(strLastName==nil)
		{
			strLastName=@" ";
		}
		
		//find out if this person is in the Zzone
		//see which name to search
		if (objNamePreference==kABPersonSortByFirstName) 
		{
			strZzoneComparable=strFirstName;
			strOrderPreference=@"first";
			strCompositeName = [NSString stringWithFormat:@"%@ %@", [self stripPrefix:strFirstName], strLastName];
		}
		else 
		{
			strZzoneComparable=strLastName;
			strOrderPreference=@"last";
			if ([[self stripPrefix:strLastName] length]>1) 
			{
				strCompositeName = [NSString stringWithFormat:@"%@, %@", [self stripPrefix:strLastName], strFirstName];
			}
			else 
			{
				strCompositeName = [NSString stringWithFormat:@"%@", strFirstName];
			}
		}
		
		intZprefix = [strZzoneComparable rangeOfString: (NSString *)strPrefix];
		NSArray *arrRecord;
		if(intZprefix.location==0)
		{
			//this is a Zzone contact
			strZzone=@"YES";
			arrRecord = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:objRecordId], strCompositeName, strZzone, strFirstName, strLastName, strOrderPreference, nil];
			[arrZzoneContacts addObject:arrRecord];
			[arrRecord release];
		}
	}
	
	[arrZzoneContacts sortUsingFunction:order context:NULL];
	
	for (NSArray *arrContact in arrZzoneContacts) 
	{
		NSString *firstLetter = [[[arrContact objectAtIndex:1] substringToIndex:1] lowercaseString]; 
		if ([firstLetter isEqualToString: @"a"]) 
		{
			[arrZCounts replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:1] intValue]+1]];
			
		}
		else if ([firstLetter isEqualToString: @"b"]) 
		{
			[arrZCounts replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:2] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"c"])
		{
			[arrZCounts replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:3] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"d"])
		{
			[arrZCounts replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:4] intValue]+1]];		
		}
		else if ([firstLetter isEqualToString: @"e"])
		{
			[arrZCounts replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:5] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"f"])
		{
			[arrZCounts replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:6] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"g"])
		{
			[arrZCounts replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:7] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"h"])
		{
			[arrZCounts replaceObjectAtIndex:8 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:8] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"i"])
		{
			[arrZCounts replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:9] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"j"])
		{
			[arrZCounts replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:10] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"k"])
		{
			[arrZCounts replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:11] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"l"])
		{
			[arrZCounts replaceObjectAtIndex:12 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:12] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"m"])
		{
			[arrZCounts replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:13] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"n"])
		{
			[arrZCounts replaceObjectAtIndex:14 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:14] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"o"])
		{
			[arrZCounts replaceObjectAtIndex:15 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:15] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"p"])
		{
			[arrZCounts replaceObjectAtIndex:16 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:16] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"q"])
		{
			[arrZCounts replaceObjectAtIndex:17 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:17] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"r"])
		{
			[arrZCounts replaceObjectAtIndex:18 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:18] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"s"])
		{
			[arrZCounts replaceObjectAtIndex:19 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:19] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"t"])
		{
			[arrZCounts replaceObjectAtIndex:20 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:20] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"u"])
		{
			[arrZCounts replaceObjectAtIndex:21 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:21] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"v"])
		{
			[arrZCounts replaceObjectAtIndex:22 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:22] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"w"])
		{
			[arrZCounts replaceObjectAtIndex:23 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:23] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"x"])
		{
			[arrZCounts replaceObjectAtIndex:24 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:24] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"y"])
		{
			[arrZCounts replaceObjectAtIndex:25 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:25] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"z"])
		{
			[arrZCounts replaceObjectAtIndex:26 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:26] intValue]+1]];
		}
		else 
		{
			[arrZCounts replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[arrZCounts objectAtIndex:0] intValue]+1]];
		}
	}
		
	for (int iii=1; iii<27; iii++) 
	{
		[arrZCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:([[arrZCounts objectAtIndex:iii-1] intValue] + [[arrZCounts objectAtIndex:iii] intValue])]];
	}

	CFRelease(addressBook);
	CFRelease(allPeople);
}

/**
 * Populate non Z-Zone contacts array
 *
 * @return 
 *	none, populates global arrays
 *
 * see populateAllContacts() (above) for detailed commenting on functionality
 */
-(void)populateNormalContacts
{
	for (int iii=0; iii<27; iii++) 
	{
		[arrNormalCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:0]];
	}

	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	ABRecordRef objRecord;
	ABRecordID objRecordId;
	ABPersonSortOrdering objNamePreference;
	NSRange intZprefix;
	[arrNormalContacts removeAllObjects];
	
	for( int i = 0 ; i < nPeople ; i++ )
	{
		NSString *strCompositeName, *strFirstName, *strLastName;
		NSString  *strZzoneComparable, *strZzone, *strOrderPreference;
		
		objRecord = CFArrayGetValueAtIndex(allPeople, i );
		objRecordId = ABRecordGetRecordID(objRecord); 
		strFirstName = [(NSString *)ABRecordCopyValue(objRecord, kABPersonFirstNameProperty) autorelease];
		strLastName  = [(NSString *)ABRecordCopyValue(objRecord, kABPersonLastNameProperty) autorelease];
		objNamePreference = ABPersonGetSortOrdering();

		if(strFirstName==nil)
		{
			strFirstName=@" ";
		}
		if(strLastName==nil)
		{
			strLastName=@" ";
		}
		
		if (objNamePreference==kABPersonSortByFirstName) 
		{
			strZzoneComparable=strFirstName;
			strOrderPreference=@"first";
			strCompositeName = [NSString stringWithFormat:@"%@ %@", [self stripPrefix:strFirstName], strLastName];
		}
		else 
		{
			strZzoneComparable=strLastName;
			strOrderPreference=@"last";
			if ([[self stripPrefix:strLastName] length]>1) 
			{
				strCompositeName = [NSString stringWithFormat:@"%@, %@", [self stripPrefix:strLastName], strFirstName];
			}
			else 
			{
				strCompositeName = [NSString stringWithFormat:@"%@", strFirstName];
			}
		}

		intZprefix = [strZzoneComparable rangeOfString: (NSString *)strPrefix];
		NSArray *arrRecord;
		if(intZprefix.location!=0)
		{
			strZzone=@"NO";
			arrRecord = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:objRecordId], strCompositeName, strZzone, strFirstName, strLastName, strOrderPreference, nil];
			[arrNormalContacts addObject:arrRecord];
			[arrRecord release];
		}		
	}
	[arrNormalContacts sortUsingFunction:order context:NULL];
	
	for (NSArray *arrContact in arrNormalContacts) 
	{
		NSString *firstLetter = [[[arrContact objectAtIndex:1] substringToIndex:1] lowercaseString]; 
		if ([firstLetter isEqualToString: @"a"]) 
		{
			[arrNormalCounts replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:1] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"b"]) 
		{
			[arrNormalCounts replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:2] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"c"])
		{
			[arrNormalCounts replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:3] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"d"])
		{
			[arrNormalCounts replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:4] intValue]+1]];		
		}
		else if ([firstLetter isEqualToString: @"e"])
		{
			[arrNormalCounts replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:5] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"f"])
		{
			[arrNormalCounts replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:6] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"g"])
		{
			[arrNormalCounts replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:7] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"h"])
		{
			[arrNormalCounts replaceObjectAtIndex:8 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:8] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"i"])
		{
			[arrNormalCounts replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:9] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"j"])
		{
			[arrNormalCounts replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:10] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"k"])
		{
			[arrNormalCounts replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:11] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"l"])
		{
			[arrNormalCounts replaceObjectAtIndex:12 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:12] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"m"])
		{
			[arrNormalCounts replaceObjectAtIndex:13 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:13] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"n"])
		{
			[arrNormalCounts replaceObjectAtIndex:14 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:14] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"o"])
		{
			[arrNormalCounts replaceObjectAtIndex:15 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:15] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"p"])
		{
			[arrNormalCounts replaceObjectAtIndex:16 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:16] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"q"])
		{
			[arrNormalCounts replaceObjectAtIndex:17 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:17] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"r"])
		{
			[arrNormalCounts replaceObjectAtIndex:18 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:18] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"s"])
		{
			[arrNormalCounts replaceObjectAtIndex:19 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:19] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"t"])
		{
			[arrNormalCounts replaceObjectAtIndex:20 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:20] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"u"])
		{
			[arrNormalCounts replaceObjectAtIndex:21 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:21] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"v"])
		{
			[arrNormalCounts replaceObjectAtIndex:22 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:22] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"w"])
		{
			[arrNormalCounts replaceObjectAtIndex:23 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:23] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"x"])
		{
			[arrNormalCounts replaceObjectAtIndex:24 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:24] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"y"])
		{
			[arrNormalCounts replaceObjectAtIndex:25 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:25] intValue]+1]];
		}
		else if ([firstLetter isEqualToString: @"z"])
		{
			[arrNormalCounts replaceObjectAtIndex:26 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:26] intValue]+1]];
		}
		else 
		{
			[arrNormalCounts replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[arrNormalCounts objectAtIndex:0] intValue]+1]];
		}
	}
	
	for (int iii=1; iii<27; iii++) 
	{
		[arrNormalCounts replaceObjectAtIndex:iii withObject:[NSNumber numberWithInt:([[arrNormalCounts objectAtIndex:iii-1] intValue] + [[arrNormalCounts objectAtIndex:iii] intValue])]];
	}

	CFRelease(addressBook);
	CFRelease(allPeople);
}


/**
 *	Helper method to prepare contact for sorting by stripping Z-Zone prefix, if present
 *
 * @param 
 *	NSString strName
 *		The name to strip the prefix from
 *
 * @return 
 *	The name without prefix
 */
-(NSString *) stripPrefix:(NSString *)strName
{
	//initialize vars
	NSString *strReturn;
	NSRange intZprefix;

	//determine the index of prefix
	intZprefix = [strName rangeOfString:strPrefix];

	//if exists, strip it
	if(intZprefix.location==0)
	{
		NSMutableString *strMutableName = [NSMutableString stringWithString:strName];
		[strMutableName replaceCharactersInRange: [strMutableName rangeOfString: (NSString *)strPrefix] withString: @""];
		strReturn = [NSString stringWithString:strMutableName];
	}
	else 
	{
		strReturn=strName;
	}
	
	return strReturn;	
}



/**
 *	Helper method that tells sortUsingFunction how to sort the contacts
 *
 * @param 
 *	id a
 *		id of first contact to compare
 *	id b
 *		id of second contact to compare
 *	context
 *		an unused parameter; but, required by sortUsingFunction
 *
 * @return NSInteger
 *	returns the comparison between the two contacts
 */
static NSInteger order (id a, id b, void* context) 
{
    NSString* catA = [a objectAtIndex:1];
    NSString* catB = [b objectAtIndex:1];
    return [catA caseInsensitiveCompare:catB];
}


/**
 *	Helper method that takes contacts in or out of Z-Zone
 *
 * @param 
 *	NSArray arrPerson
 *		The contact to change
 *
 * @return 
 *		None, this function changes the contact in the iOS address book
 */
-(void)modContact:(NSArray *)arrPerson
{
	//declare and set vars
	ABAddressBookRef objAddressBook = ABAddressBookCreate();
	CFErrorRef objError = NULL;
	NSInteger intContactID=[[arrPerson objectAtIndex:0] intValue];
	ABRecordRef objPerson = ABAddressBookGetPersonWithRecordID (objAddressBook,intContactID);
	NSRange intZprefix;
	
	if([arrPerson objectAtIndex:2]==@"YES")
	{
		//its a zzone contact so make it a normal contact
		if([arrPerson objectAtIndex:5]==@"first")
		{
			//change via first name
			ABRecordSetValue(objPerson, kABPersonFirstNameProperty, [self stripPrefix:[arrPerson objectAtIndex:3]], &objError);
		}
		else 
		{
			//change via last name
			ABRecordSetValue(objPerson, kABPersonLastNameProperty, [self stripPrefix:[arrPerson objectAtIndex:4]], &objError);
		}
		
	}
	else 
	{
		//it's a normal contact so make it Z-Zone contact
		if([arrPerson objectAtIndex:5]==@"first")
		{
			//change via first name
			intZprefix = [[arrPerson objectAtIndex:3] rangeOfString:strPrefix];
			if (intZprefix.location==0) 
			{
				//This contact was formerly a zzone contact and has a legacy prefix in the name so do not prefix
				ABRecordSetValue(objPerson, kABPersonFirstNameProperty, [arrPerson objectAtIndex:3], &objError);
			}
			else 
			{
				//NO prefix present in the array so prefix it
				ABRecordSetValue(objPerson, kABPersonFirstNameProperty, [NSString stringWithFormat:@"%@%@", strPrefix, [arrPerson objectAtIndex:3]], &objError);
			}
		}
		else 
		{
			//change via last name
			intZprefix = [[arrPerson objectAtIndex:4] rangeOfString:strPrefix];
			if (intZprefix.location==0) 
			{
				//prefix already present - do not prefix
				ABRecordSetValue(objPerson, kABPersonLastNameProperty, [arrPerson objectAtIndex:4], &objError);
			}
			else
			{
				//append prefix
				ABRecordSetValue(objPerson, kABPersonLastNameProperty, [NSString stringWithFormat:@"%@%@", strPrefix, [arrPerson objectAtIndex:4]], &objError);
			}
			
		}
	}
	
	ABAddressBookSave(objAddressBook, &objError);

	//garbage collection
	CFRelease(objAddressBook);
}

/**
 * Helper method that updates the prefix setting when the prefix setting is changed
 * and batch processes all contacts with the new prefix
 *
 * @param 
 *	NSString strNewPrefix
 *		The prefix to apply to all prefixed contacts 
 *
 * @return 
 *	None, this function changes the contact in the iOS address book
 */
-(void)resetPrefix:(NSString *)strNewPrefix
{
	if ([strNewPrefix length]>0 && strNewPrefix!=strPrefix) 
	{
		//intiialize and set vars
		ABAddressBookRef addressBook = ABAddressBookCreate();
		CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
		CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
		ABRecordRef objRecord;
		ABRecordID objRecordId;
		CFErrorRef objError = NULL;
		ABPersonSortOrdering objNamePreference;
		NSRange intZprefix;
		objNamePreference = ABPersonGetSortOrdering();
	
		//loop through all contacts
		for( int i = 0 ; i < nPeople ; i++ )
		{
			//initialize vars
			NSString *strFirstName, *strLastName, *strTemp;
		
			//get the contact's values
			objRecord = CFArrayGetValueAtIndex(allPeople, i );
			objRecordId = ABRecordGetRecordID(objRecord); 
			strFirstName = [(NSString *)ABRecordCopyValue(objRecord, kABPersonFirstNameProperty) autorelease];
			strLastName  = [(NSString *)ABRecordCopyValue(objRecord, kABPersonLastNameProperty) autorelease];
		
			//do not allow empty names
			if(strFirstName==nil)
			{
				strFirstName=@" ";
			}
			if(strLastName==nil)
			{
				strLastName=@" ";
			}
			
			//find out if this person is in the Zzone
			//get naming preference
			if (objNamePreference==kABPersonSortByFirstName) 
			{
				//prefix by first name
				intZprefix = [strFirstName rangeOfString:strPrefix];
				if(intZprefix.location==0)
				{
					//prefix exists, so change prefix
					strTemp = [self stripPrefix:strFirstName];
					strTemp=[NSString stringWithFormat:@"%@%@",strNewPrefix,strTemp];
					ABRecordSetValue(objRecord, kABPersonFirstNameProperty,strTemp , &objError);
				}
			}
			else 
			{
				intZprefix = [strLastName rangeOfString: (NSString *)strNewPrefix];
				if(intZprefix.location==0)
				{
					ABRecordSetValue(objRecord, kABPersonLastNameProperty, [NSString stringWithFormat:@"%@%@",strNewPrefix,[self stripPrefix:strLastName]], &objError);
				}	
			}
		
		}
	
		//save all contacts to the address book
		ABAddressBookSave(addressBook, &objError);
		
		//update the settings with the new prefix
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:strNewPrefix forKey:@"strPrefix"];
		strPrefix=[strNewPrefix copy];
	}
	else 
	{
		//NSLog(@"No prefix set");
	}
}

/***********************************
Boilerplate methods required by iOS
************************************/

- (void)applicationWillResignActive:(UIApplication *)application {
	/*
	Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	*/
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
	*/
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	/*
	Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
	*/
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	/*
	Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	*/
}


- (void)applicationWillTerminate:(UIApplication *)application {
	/*
	Called when the application is about to terminate.
	See also applicationDidEnterBackground:.
	*/
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	/*
	Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	*/
}

/**
 *	Garbage collection for Z-ZoneAppDelegate class
 */
- (void)dealloc 
{
	[arrContacts release];
	[arrNormalContacts release];
	[arrZzoneContacts release];
	[tabBarController release];
	[window release];
	[strPrefix release];
	[arrLetters release];
	[super dealloc];
}

@end
