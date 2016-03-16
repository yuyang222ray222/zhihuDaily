//
//  DateUtil.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil
+ (NSString*)dateString:(NSDate*)date WithFormat:(NSString*)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    NSString* dateToString = [dateFormatter stringFromDate:date];
    return dateToString;
}
+ (NSString*)dateIdentifierNow
{
    return [self dateString:[NSDate date] WithFormat:@"yyyyMMddHHmmssfff"];
}
@end
