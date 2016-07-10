//
//  DownloadFileCell.h
//  DownloadFiles
//
//  Created by Aleh on 7/10/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@end
