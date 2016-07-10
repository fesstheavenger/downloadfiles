//
//  NSNumber+Formatting.m
//  DownloadFiles
//
//  Created by Aleh on 7/10/16.
//  Copyright © 2016 Aleh. All rights reserved.
//

#import "NSNumber+Formatting.h"

static const int64_t kBytesInMb = 1024 * 1024;

@implementation NSNumber (Formatting)

- (NSString *)formattedSizeValue
{
    if(self.longLongValue >= 0)
    {
        float m = (float)self.longLongValue / (float)kBytesInMb;
        return [NSString stringWithFormat:@"%.01fMb", m];
    }
    else
    {
        return [self stringValue];
    }
}

@end
