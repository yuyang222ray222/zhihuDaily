//
//  APiRequest.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIRequest : NSObject
+ (void)requestWithUrl:(NSString*)url;
+ (void)requestWithUrl:(NSString*)url completion:(void (^)(id data))completion;

+ (NSDictionary*)objToDic:(id)object;
@end
