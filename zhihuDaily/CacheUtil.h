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

@class CachedImages;

/**
 *  缓存单例类
 */
@interface CacheUtil : NSObject
@property (strong, nonatomic) NSMutableDictionary* dataDic;

+ (instancetype)cache;

- (void)cacheImageWithKey:(NSString*)key andUrl:(NSString*)url completion:(void (^)(UIImage* image))completion;
- (UIImage*)imageWithKey:(NSString*)key;
- (CachedImages*)cachedImageWithKey:(NSString*)key;
- (void)saveData;
@end
