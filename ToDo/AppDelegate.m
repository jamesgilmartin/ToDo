//
//  AppDelegate.m
//  ToDo
//
//  Created by James Gilmartin on 25/09/2014.
//  Copyright (c) 2014 James Gilmartin. All rights reserved.
//

#import "AppDelegate.h"

// App Key & Secret for the remote persistence via DropBox Datastore
#define DBAppKey @"6d7zhmf8ihqvhth"
#define DBAppSecret @"ymuv4vkkcazqfwb"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set up Dropbox Account Manager
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DBAppKey secret:DBAppSecret];
    [DBAccountManager setSharedManager:accountManager];
    
    // Set up the datastore manager
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        // Use Dropbox datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
    } else {
        // Use local datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager localManagerForAccountManager:
                                              [DBAccountManager sharedManager]]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma - Dropbox Login Handler

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(NSString *)source annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account)
    {
        // Login was successful
        
        // Migrate any local datastores to the linked account
        DBDatastoreManager *localManager = [DBDatastoreManager localManagerForAccountManager:
                                            [DBAccountManager sharedManager]];
        [localManager migrateToAccount:account error:nil];
        // Now use Dropbox datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
        
        return YES;
    }
    else
    {
        // Login failed or was cancelled
        
        // Dispatch notification in order to inform of cancel or error
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DBLoginFailed" object:nil];
    }
    return NO;
}

@end
