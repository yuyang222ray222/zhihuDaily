//
//  AppDelegate.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIRequest.h"
#import "AppDelegate.h"
#import "CacheUtil.h"
#import "CachedImages.h"
#import "DataKeys.m"
#import "StartImage.h"
#import "zhihuDailyAPI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self cacheStartImage];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [[CacheUtil cache] saveData];
}
- (void)applicationWillResignActive:(UIApplication*)application
{
    [[CacheUtil cache] saveData];
}
- (void)cacheStartImage
{
    NSString* imageApiUrl =
        [NSString stringWithFormat:@"%@%@", API_Url_StartImage, @"1080*1776"];
    [APIRequest
        requestWithUrl:imageApiUrl
            completion:^(id data, NSString* md5) {
                StartImage* model = [StartImage
                    startImageWithDic:[APIRequest objToDic:data]];
                CacheUtil* cache = [CacheUtil cache];

                //已经缓存过的图片不缓存
                CachedImages* cachedImage = [cache cachedImageWithKey:DATAKEY_STARTIMAGE];
                if ([model.img isEqualToString:cachedImage.url])
                    return;

                [cache cacheImageWithKey:DATAKEY_STARTIMAGE andUrl:model.img completion:nil];
                [cache.dataDic setValue:model.text forKey:DATAKEY_STARTIMAGE_AUTHOR];
            }];
}
@end
