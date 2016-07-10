//
//  DownloadManager.m
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import "DownloadManager.h"
#import "AppDelegate.h"

static NSString *const kDownloadURL = @"http://ftp.byfly.by/test/50mb.txt";
static NSString *const kSessionConfigID = @"DownloadSessionConfig";

@interface DownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, copy, readwrite) NSArray *downloads;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *activeTasks;
@property (nonatomic, strong) NSMutableSet *activeDownloadsIndexes;
@property (nonatomic, strong) NSMutableArray *restOfDownloads;

@end

@implementation DownloadManager

+ (instancetype)sharedInstance
{
    static DownloadManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (NSURLSession *)session
{
    if(!_session)
    {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kSessionConfigID];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = kMaxActiveDownloadsCount;
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    return _session;
}

- (NSMutableDictionary *)activeTasks
{
    if(!_activeTasks)
    {
        _activeTasks = [NSMutableDictionary dictionary];
    }
    return _activeTasks;
}

- (NSMutableArray *)restOfDownloads
{
    if(!_restOfDownloads)
    {
        _restOfDownloads = [self.downloads mutableCopy];
    }
    return _restOfDownloads;
}

- (NSMutableSet *)activeDownloadsIndexes
{
    if(!_activeDownloadsIndexes)
    {
        _activeDownloadsIndexes = [NSMutableSet set];
    }
    return _activeDownloadsIndexes;
}

- (void)addDownloadIndexToSet:(NSNumber *)index
{
    @synchronized (self)
    {
        [self.activeDownloadsIndexes addObject:index];
    }
}

- (void)removeDownloadIndexFromSet:(NSNumber *)index
{
    @synchronized (self)
    {
        [self.activeDownloadsIndexes removeObject:index];
    }
}

- (NSArray *)downloads
{
    if(!_downloads)
    {
        @synchronized(self)
        {
            NSMutableArray *ds = [NSMutableArray array];
            NSURL *url = [NSURL URLWithString:kDownloadURL];
            
            for(NSInteger i = 0; i < kNumberOfDownloads; i++)
            {
                FileDownload *fd = [FileDownload fileDownloadWithRemoteURL:url andIndex:i];
                [ds addObject:fd];
            }
            _downloads = [ds copy];
        }
    }
    return _downloads;
}

- (void)runAllDownloads
{
    for(NSInteger i = 0; i < kMaxActiveDownloadsCount; i++)
    {
        [self startNextDownload];
    }
}

- (FileDownload *)nextDownload
{
    @synchronized(self)
    {
        if(self.restOfDownloads.count)
        {
            FileDownload *fd = [self.restOfDownloads firstObject];
            [self.restOfDownloads removeObjectAtIndex:0];
            return fd;
        }
        else
        {
            return nil;
        }
    }
}

- (void)startNextDownload
{
    FileDownload *fileDownload = [self nextDownload];
    if(fileDownload)
    {
        fileDownload.downloadTask = [self.session downloadTaskWithURL:fileDownload.remoteURL];
        NSInteger taskID = fileDownload.downloadTask.taskIdentifier;
        [fileDownload.downloadTask resume];
        [self.activeTasks setObject:fileDownload forKey:@(taskID)];
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(appDelegate.sessionCompletionHandler)
    {
        BackgroundSessionCompletionHandler sessionHandler = [appDelegate.sessionCompletionHandler copy];
        appDelegate.sessionCompletionHandler = nil;
        if([self.delegate respondsToSelector:@selector(completedBackgroundSessionWithHandler:)])
        {
            [self.delegate completedBackgroundSessionWithHandler:sessionHandler];
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    FileDownload *fd = self.activeTasks[@(downloadTask.taskIdentifier)];
    if(fd)
    {
        [self removeDownloadIndexFromSet:@(fd.index)];
    
        fd.isDownloading = NO;
        fd.isCompleted = YES;
    
        NSError *error = nil;
        NSURL *newLocationURL = [NSURL fileURLWithPath:[self localFilePathForFileDownload:fd]];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:newLocationURL error:&error];
        
        [self.delegate completedFileDownloadWithIndex:fd.index];
        [self.activeTasks removeObjectForKey:@(downloadTask.taskIdentifier)];
    
        if(self.activeTasks.count < kMaxActiveDownloadsCount)
        {
            [self startNextDownload];
        }
    
        if((self.activeTasks.count == 0) && ![self nextDownload])
        {
            if([self.delegate respondsToSelector:@selector(allDownloadsCompleted)])
            {
                [self.delegate allDownloadsCompleted];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    FileDownload *fd = self.activeTasks[@(downloadTask.taskIdentifier)];
    if(fd)
    {
        [self addDownloadIndexToSet:@(fd.index)];
        fd.isDownloading = YES;
    
        fd.totalSize = totalBytesExpectedToWrite;
        fd.downloadedSize = totalBytesWritten;
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        if(progress > fd.downloadProgress.floatValue)
        {
            [self.delegate updatedProgress:progress forFileDownloadWithIndex:fd.index];
        }
        fd.downloadProgress = @(progress);
    }
}

- (NSString *)documentsDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSString *)localFilePathForFileDownload:(FileDownload *)fileDownload
{
    NSString *fileName = fileDownload.remoteURL.absoluteString.lastPathComponent;
    NSString *newFileName = [NSString stringWithFormat:@"%li_%@", (long)fileDownload.index, fileName];
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:newFileName];
}

- (int64_t)availableFreeSpaceInBytes
{
    return [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
}

- (void)isEnoughSpaceForFileDownload:(FileDownload *)fileDownload completionHandler:(CheckFreeSpaceCompletionHandler)completionHandler
{
    int64_t freeSpace = [self availableFreeSpaceInBytes];
    int64_t fileTotalSize = fileDownload.totalSize;
    if(completionHandler)
    {
        completionHandler(freeSpace >= fileTotalSize);
    }
}

- (NSInteger)activeDownloadsCount
{
    @synchronized (self)
    {
        return self.activeDownloadsIndexes.count;
    }
}

@end
