//
//  AppDelegate.m
//  imagestore
//
//  Created by oddman on 11/1/15.
//  Copyright © 2015 oddman. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BinaryDAO.h"

@interface AppDelegate () {
}

@end

@implementation AppDelegate

- (NSString *) dbFilePath {
    //Get list of directories in Document path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    //Define new path for database in the documents directory because data cannot be written in the resource folder.
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:@"binaryDb.db"];
    return documentPath;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BinaryDAO *tmp = [[BinaryDAO alloc] initWithPath:[self dbFilePath]];
    [tmp createBinaryDB];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.window.rootViewController =
    [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];

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

@end
