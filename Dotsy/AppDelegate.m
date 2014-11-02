//
//  AppDelegate.m
//  Dotsy
//
//  Created by Karl Grogan on 30/10/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import "AppDelegate.h"
#import "SoundCloudTableViewController.h"
#import "SCUI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize {
    // Configure our SoundCloud application.
    [SCSoundCloud setClientID:@"a8ec7af43896a1a16c722297804fa0fe"
                       secret:@"dafd2220336ddf759b7b103e3efa1f04"
                  redirectURL:[NSURL URLWithString:@"dotsy://oauth"]];
    
    // Login to SoundCloud using my credentials.
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    SoundCloudTableViewController *soundCloudTableViewController = [[SoundCloudTableViewController alloc] init];
    soundCloudTableViewController.title = @"SoundCloud";
    UINavigationController *souncCloudNavController = [[UINavigationController alloc] initWithRootViewController:soundCloudTableViewController];
    
    UITableViewController *spotifyTableViewController = [[UITableViewController alloc] init];
    spotifyTableViewController.title = @"Spotify";
    UINavigationController *spotifyNavController = [[UINavigationController alloc] initWithRootViewController:spotifyTableViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    [tabBarController setViewControllers:@[souncCloudNavController, spotifyNavController]];
    
    [self.window setRootViewController:tabBarController];
    
    [self.window makeKeyAndVisible];

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
