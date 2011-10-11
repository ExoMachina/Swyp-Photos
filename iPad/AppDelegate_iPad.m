//
//  AppDelegate_iPad.m
//  swypPhotos
//
//  Created by Alexander List on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "swypPhotoPlayground.h"

@implementation AppDelegate_iPad


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    // Override point for customization after application launch.
	
	[[[self swypWorkspace] view] setFrame:[self.window bounds]];
	swypPhotoArrayDatasource	* mainPhotoDataSource	=	[[swypPhotoArrayDatasource alloc] initWithImageDataArray:[NSArray arrayWithObject:UIImagePNGRepresentation([UIImage imageNamed:@"swypPhotosIconHuge.png"])]];
	[[[self swypWorkspace] contentManager] setContentDataSource:mainPhotoDataSource];
	SRELS(mainPhotoDataSource);
	
	swypPhotoPlayground *	contentDisplayController	=	[[swypPhotoPlayground alloc] initWithPhotoSize:CGSizeMake(225, 225)];
	//work on proper sizing soon
	
	CGRect contentRect	=	CGRectMake(0,0, [self.window bounds].size.width,[self.window bounds].size.height);
	[contentDisplayController.view setFrame:contentRect];
	[[[self swypWorkspace] contentManager] setContentDisplayController:contentDisplayController];
	SRELS(contentDisplayController);


	[self.window setRootViewController:[self swypWorkspace]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[super applicationDidBecomeActive:application];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[super applicationWillEnterForeground:application];
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	
	[super dealloc];
}


@end

