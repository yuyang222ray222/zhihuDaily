//
//  zhihuDailyAPI.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#define API_Url @"http://news-at.zhihu.com/api/4/news/"
#define API_Url_NewsLatest @"http://news-at.zhihu.com/api/4/news/latest"
#define API_Url_NewsBefore @"http://news.at.zhihu.com/api/4/news/before/"
#define API_Url_StartImage @"http://news-at.zhihu.com/api/4/start-image/"

#import <Foundation/Foundation.h>
@class Stories;

@interface APIDataSource : NSObject
+ (instancetype)datasource;

@property (strong, nonatomic, readonly) NSArray<Stories*>* topStories;

@property (strong, nonatomic, readonly) NSString* date;
@property (strong, nonatomic, readonly) NSArray* stories;

- (void)NewsLatest:(void (^)(BOOL needsToReload))completion;
@end