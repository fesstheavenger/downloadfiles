//
//  FileDownload.h
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownload : NSObject

@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, strong, readonly) NSURL *remoteURL;
@property (nonatomic, strong, readonly) NSURL *localURL;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSNumber *downloadProgress;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, assign) int64_t totalSize;
@property (nonatomic, assign) int64_t downloadedSize;

+ (instancetype)fileDownloadWithRemoteURL:(NSURL *)remoteURL andIndex:(NSInteger)index;

- (NSString *)formattedString;
- (NSString *)formattedCompletedString;
- (NSString *)formattedDownloadInfoString;

@end
