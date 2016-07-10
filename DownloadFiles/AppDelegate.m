//
//  AppDelegate.m
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.sessionCompletionHandler = completionHandler;
}

@end
