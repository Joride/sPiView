//
//  AppDelegate.m
//  sPiView
//
//  Created by Joride on 16-11-14.
//  Copyright (c) 2014 KerrelInc. All rights reserved.
//

#import "AppDelegate.h"
@import UserNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application registerForRemoteNotifications];
    UNUserNotificationCenter* center =
    [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted,
                                              NSError * _Nullable error)
     {
         // Enable or disable features based on authorization.
     }];
    return YES;
}

-(void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString * token = [NSMutableString string];
    const char      * data  = [deviceToken bytes];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    DebugLog(@"\t\t==== PUSHTOKEN: '%@' ====\n\n", token);
}
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}
@end
