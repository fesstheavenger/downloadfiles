//
//  DFViewController.m
//  DownloadFiles
//
//  Created by Aleh on 7/9/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import "DFViewController.h"
#import "DownloadFileCell.h"
#import "DownloadManager.h"

static NSString *const kCellID = @"cell";

@interface DFViewController () <UITableViewDelegate, UITableViewDataSource, DownloadManagerDelegate>

@property (nonatomic, strong) UITableView *downloadsTableView;

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DownloadManager sharedInstance].delegate = self;
    
    [self.view addSubview:self.downloadsTableView];
    [self.downloadsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DownloadFileCell class]) bundle:nil] forCellReuseIdentifier:kCellID];
    
    [self reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[DownloadManager sharedInstance] runAllDownloads];
    });
}

- (UITableView *)downloadsTableView
{
    if(!_downloadsTableView)
    {
        CGRect rect = self.view.frame;
        _downloadsTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _downloadsTableView.delegate = self;
        _downloadsTableView.dataSource = self;
        _downloadsTableView.showsVerticalScrollIndicator = NO;
        _downloadsTableView.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return _downloadsTableView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.downloadsTableView.frame = self.view.frame;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DownloadManager sharedInstance].downloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileDownload *fd = [DownloadManager sharedInstance].downloads[indexPath.row];
    DownloadFileCell *cell = [self.downloadsTableView dequeueReusableCellWithIdentifier:kCellID];
    
    NSString *text = fd.isCompleted ? [fd formattedCompletedString] : (fd.isDownloading ? [fd formattedDownloadInfoString] : [fd formattedString]);
    cell.mainLabel.text = text;
    cell.progressView.progress = fd.downloadProgress.floatValue;
    cell.progressLabel.text = [NSString stringWithFormat:@"%li%%", (NSInteger)(fd.downloadProgress.floatValue * 100)];
    cell.iconImageView.hidden = !fd.isCompleted;
    if(fd.isCompleted)
    {
        cell.iconImageView.image = [UIImage imageNamed:@"completed"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.downloadsTableView reloadData];
}

#pragma mark - DownloadManagerDelegate

- (void)allDownloadsCompleted
{
    __weak DFViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [weakSelf showCompletionAlert];
    });
}

- (void)completedFileDownloadWithIndex:(NSInteger)index
{
    __weak DFViewController *weakSelf = self;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf updateNavigationItem];
        [weakSelf.downloadsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)updatedProgress:(float)progress forFileDownloadWithIndex:(NSInteger)index
{
    __weak DFViewController *weakSelf = self;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf updateNavigationItem];
        [weakSelf.downloadsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)completedBackgroundSessionWithHandler:(BackgroundSessionCompletionHandler)completionHandler
{
    __weak DFViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if(completionHandler)
        {
            completionHandler();
            [weakSelf reloadData];
        }
    });
}

#pragma mark - UI

- (void)updateNavigationItem
{
    NSString *activeStr = NSLocalizedString(@"Active", nil);
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %li", activeStr, (long)[[DownloadManager sharedInstance]activeDownloadsCount]];
}

- (void)reloadData
{
    [self updateNavigationItem];
    [self.downloadsTableView reloadData];
}

- (void)showCompletionAlert
{
    NSString *title = NSLocalizedString(@"Success", nil);
    NSString *msg = NSLocalizedString(@"All downloads are completed!", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *ok = NSLocalizedString(@"OK", nil);
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
