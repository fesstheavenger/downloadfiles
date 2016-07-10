//
//  AppDelegate.h
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) BackgroundSessionCompletionHandler sessionCompletionHandler;

@end

