//
//  DownloadManager.h
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownload.h"

@class DownloadManager;

@protocol DownloadManagerDelegate <NSObject>

- (void)completedFileDownloadWithIndex:(NSInteger)index;
- (void)updatedProgress:(float)progress forFileDownloadWithIndex:(NSInteger)index;

@optional
- (void)allDownloadsCompleted;
- (void)completedBackgroundSessionWithHandler:(BackgroundSessionCompletionHandler)completionHandler;

@end

@interface DownloadManager : NSObject

@property (nonatomic, weak) id<DownloadManagerDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray *downloads;

+ (instancetype)sharedInstance;

- (void)runAllDownloads;
- (NSInteger)activeDownloadsCount;

@end
