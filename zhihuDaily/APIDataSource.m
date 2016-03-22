//
//  zhihuDailyAPI.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/23.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIDataSource.h"
#import "APIRequest.h"
#import "CacheUtil.h"
#import "DataKeys.m"
#import "GCDUtil.h"
#import "Stories.h"
#import "Story.h"

@interface
APIDataSource ()

@end
@implementation APIDataSource
+ (instancetype)datasource
{
  static APIDataSource* datasource = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    datasource = [[APIDataSource alloc] init];
  });
  return datasource;
}

- (void)NewsLatest:(void (^)(BOOL needsToReload))completion
{
  [APIRequest
    requestWithUrl:API_Url_NewsLatest
        completion:^(id data, NSString* md5) {
          BOOL needsToReload = false;

          CacheUtil* util = [CacheUtil cache];
          NSMutableDictionary* dic = [NSMutableDictionary
            dictionaryWithDictionary:[APIRequest objToDic:data]];

          NSString* date = dic[DATAKEY_STORIES_DATE];
          if (util.dataDic[date] == nil) {
            [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
            [util.dataDic setObject:dic forKey:date];

            needsToReload = true;
          } else {
            NSDictionary* cachedDic = util.dataDic[date];
            // compare signature
            if (![cachedDic[DATAKEY_STORIES_SIGNATURE] isEqualToString:md5]) {
              [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
              [util.dataDic setObject:dic forKey:date];

              needsToReload = true;
            }
          }

          _topStories = [Stories stories:dic[DATAKEY_STORIES_TOPSTORIES]];
          _stories = [Stories stories:dic[DATAKEY_STORIES_STORIES]];
          _date = date;

          if (completion != nil)
            completion(needsToReload);
        }];
}
@end