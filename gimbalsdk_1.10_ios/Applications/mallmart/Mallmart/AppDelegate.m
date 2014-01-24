/**
 * Copyright (C) 2011 Qualcomm Retail Solutions, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Qualcomm Retail Solutions, Inc.
 *
 * The following sample code illustrates various aspects of the Gimbal SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided AS IS and your use of this sample code, whether as provided or with
 * any modification, is at your own risk. Neither Qualcomm Retail Solutions, Inc. nor any
 * affiliate takes any liability nor responsibility with respect to the sample
 * code, and disclaims all warranties, express and implied, including without
 * limitation warranties on merchantability, fitness for a specified purpose,
 * and against infringement.
 */
#import "AppDelegate.h"

#import "MainViewController.h"
#import <ContextCore/QLPushNotificationsConnector.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%d",[[NSDate date] timeIntervalSinceDate:nil] >= 600000000);
    
    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [QLPushNotificationsConnector didFinishLaunchingWithOptions:launchOptions];
    [QLPushNotificationsConnector registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert |
                                                                     UIRemoteNotificationTypeBadge |
                                                                     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [QLPushNotificationsConnector didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [QLPushNotificationsConnector didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
}

@end
