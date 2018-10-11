//
//  Z_ZoneAppDelegate.h
//  Z-Zone
//
//  Created by Mark Laramee on 2/15/11.
//  Copyright 2011 Mark Laramee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Z_ZoneAppDelegate : NSObject <UIApplicationDelegate> 
{
  UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	//
	@public NSMutableArray *arrContacts;
	@public NSMutableArray *arrZzoneContacts;
	@public NSMutableArray *arrNormalContacts;
	@public NSMutableArray *arrSortedContacts;
	@public NSMutableArray *arrAllCounts;
	@public NSMutableArray *arrZCounts;
	@public NSMutableArray *arrNormalCounts;
	@public NSArray *arrLetters;
	@public NSString *strPrefix;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
//
@property (retain, nonatomic) NSMutableArray *arrContacts;
@property (retain, nonatomic) NSMutableArray *arrZzoneContacts;
@property (retain, nonatomic) NSMutableArray *arrNormalContacts;
@property (retain, nonatomic) NSMutableArray *arrAllCounts;
@property (retain, nonatomic) NSMutableArray *arrZCounts;
@property (retain, nonatomic) NSMutableArray *arrNormalCounts;
@property (retain, nonatomic) NSArray *arrLetters;
@property (nonatomic, retain) NSString *strPrefix;

-(NSString *)stripPrefix:(NSString *)strName;
static NSInteger order (id a, id b, void* context); 
-(void)modContact:(NSArray *)arrPerson;
-(void)populateAllContacts;
-(void)populateZContacts;
-(void)populateNormalContacts;
-(void)resetPrefix:(NSString *)strNewPrefix;

@end

