//
//  APiRequest.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIRequest.h"
#import "GCDUtil.h"

@implementation APIRequest
+ (void)requestWithUrl:(NSString*)url
{
    [self requestWithUrl:url completion:nil];
}
+ (void)requestWithUrl:(NSString*)url completion:(void (^)(id data))completion
{
    NSURLSession* session = [NSURLSession sharedSession];
    NSURL* requestURL = [NSURL URLWithString:url];

    [[session
          dataTaskWithURL:requestURL
        completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            [[GCDUtil globalQueueWithLevel:DEFAULT] async:^{
                NSHTTPURLResponse* responseFromServer = (NSHTTPURLResponse*)response;
                if (data != nil && error == nil && responseFromServer.statusCode == 200) {
                    NSError* parseError = nil;
                    id result = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&parseError];
                    NSLog(@"获取数据成功\n%@", result);
                    if (parseError)
                        return;
                    if (completion != nil) {
                        [[GCDUtil mainQueue] async:^{
                            completion(result);
                        }];
                    }
                }
            }];
        }] resume];
}
+ (NSDictionary*)objToDic:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)object;
    }
    return nil;
}
@end
