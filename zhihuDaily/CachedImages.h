//
//  CachedImages.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/17.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedImages : NSObject
@property (copy, nonatomic) NSString* url;
@property (copy, nonatomic) NSString* fileName;

- (instancetype)initWithDic:(NSDictionary*)dic;
+ (instancetype)cachedImageWithDic:(NSDictionary*)dic;
@end
