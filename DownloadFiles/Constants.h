//
//  Constants.m
//  DownloadFiles
//
//  Created by Aleh on 7/10/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BackgroundSessionCompletionHandler)();
typedef void (^CheckFreeSpaceCompletionHandler)(BOOL isEnough);

static const float kTableRowHeight = 50.0f;
static const NSInteger kMaxActiveDownloadsCount = 3;
static const NSInteger kNumberOfDownloads = 100;
