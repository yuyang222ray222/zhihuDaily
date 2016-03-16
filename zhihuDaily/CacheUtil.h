//
//  CacheUtil.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const kCacheImagePath;
extern NSString* const kDataPath;

@interface CacheUtil : NSObject
@property (strong, nonatomic) NSMutableDictionary* dataDic;

- (void)cacheImage:(UIImage*)image withKey:(NSString*)key;
- (UIImage*)imageWithKey:(NSString*)key;
@end
