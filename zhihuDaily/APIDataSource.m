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
#import "CachedImage.h"
#import "DataKeys.m"
#import "GCDUtil.h"
#import "StartImage.h"
#import "Stories.h"
#import "Story.h"

@interface
APIDataSource ()
@property (strong, nonatomic) CacheUtil* cache;
@end
@implementation APIDataSource
+ (instancetype)dataSource
{
  static APIDataSource* datasource = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    datasource = [[APIDataSource alloc] init];
  });
  return datasource;
}
- (CacheUtil*)cache
{
  if (_cache == nil) {
    _cache = [CacheUtil cache];
  }
  return _cache;
}
#pragma mark - NewsLatest
- (void)newsLatest:(void (^)(BOOL needsToReload))completion
{
  [APIRequest
    requestWithUrl:API_Url_NewsLatest
        completion:^(id data, NSString* md5) {
          BOOL needsToReload = false;

          NSMutableDictionary* dic = [NSMutableDictionary
            dictionaryWithDictionary:[APIRequest objToDic:data]];

          NSString* date = dic[DATAKEY_STORIES_DATE];
          if (self.cache.dataDic[date] == nil) {
            [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
            [self.cache.dataDic setObject:dic forKey:date];

            needsToReload = true;
          } else {
            NSDictionary* cachedDic = self.cache.dataDic[date];
            // compare signature
            if (![cachedDic[DATAKEY_STORIES_SIGNATURE] isEqualToString:md5]) {
              [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
              [self.cache.dataDic setObject:dic forKey:date];

              needsToReload = true;
            }
          }

          self.topStories = [Stories stories:dic[DATAKEY_STORIES_TOPSTORIES]];
          self.stories = [Stories stories:dic[DATAKEY_STORIES_STORIES]];
          self.date = date;

          if (completion != nil)
            completion(needsToReload);
        }];
}

#pragma mark - StartImage
- (UIImage*)startImage
{
  if (_startImage == nil) {
    _startImage = [self.cache imageWithKey:DATAKEY_STARTIMAGE];
  }
  return _startImage;
}
- (NSString*)startImageAuthor
{
  if (_startImageAuthor == nil) {
    _startImageAuthor = self.cache.dataDic[DATAKEY_STARTIMAGE_AUTHOR];
  }
  return _startImageAuthor;
}
- (void)startImage:(void (^)(void))completion
{
  NSString* imageApiUrl =
    [NSString stringWithFormat:@"%@%@", API_Url_StartImage, @"1080*1776"];
  [APIRequest requestWithUrl:imageApiUrl
                  completion:^(id data, NSString* md5) {
                    StartImage* model =
                      [StartImage startImageWithDic:[APIRequest objToDic:data]];
                    CachedImage* cachedImage =
                      [self.cache cachedImageWithKey:DATAKEY_STARTIMAGE];
                    if ([model.img isEqualToString:cachedImage.url])
                      return;

                    [self.cache cacheImageWithKey:DATAKEY_STARTIMAGE
                                           andUrl:model.img
                                       completion:nil];
                    [self.cache.dataDic setValue:model.text
                                          forKey:DATAKEY_STARTIMAGE_AUTHOR];
                  }];
}
@end