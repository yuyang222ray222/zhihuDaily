//
//  DateUtil.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject
+ (NSString*)dateString:(NSDate*)date WithFormat:(NSString*)format;
+ (NSString*)dateIdentifierNow;
@end
