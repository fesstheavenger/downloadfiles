//
//  FileDownload.m
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import "FileDownload.h"

@interface FileDownload ()

@property (nonatomic, assign, readwrite) NSInteger index;
@property (nonatomic, strong, readwrite) NSURL *remoteURL;
@property (nonatomic, strong, readwrite) NSURL *localURL;

@end

@implementation FileDownload

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL andIndex:(NSInteger)index
{
    if(self = [super init])
    {
        _remoteURL = remoteURL;
        _index = index;
        _isDownloading = NO;
        _isCompleted = NO;
        _downloadProgress = @0;
    }
    return self;
}

+ (instancetype)fileDownloadWithRemoteURL:(NSURL *)remoteURL andIndex:(NSInteger)index
{
    return [[[self class] alloc] initWithRemoteURL:remoteURL andIndex:index];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"index = %li, url = %@, progress = %lf%%", (long)self.index, self.remoteURL.absoluteString, (float)self.downloadProgress.floatValue * 100];
}

- (NSString *)formattedString
{
    return [NSString stringWithFormat:@"File %li: %@", self.index + 1, self.remoteURL.absoluteString.lastPathComponent];
}

- (NSString *)formattedCompletedString
{
    return [NSString stringWithFormat:@"Completed %li: %@ (%@)", self.index + 1, [@(self.totalSize) formattedSizeValue], self.remoteURL.absoluteString.lastPathComponent];
}

- (NSString *)formattedDownloadInfoString
{
    return [NSString stringWithFormat:@"Downloading %li (%@ of %@)", self.index + 1, [@(self.downloadedSize) formattedSizeValue], [@(self.totalSize) formattedSizeValue]];
}

@end
