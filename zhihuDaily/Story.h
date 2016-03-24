//
//  Story.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject
@property (assign, nonatomic) NSUInteger id;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString* css;
@property (copy, nonatomic) NSString* body;
@property (copy, nonatomic) NSString* image;
@property (copy, nonatomic) NSString* imageSource;

- (instancetype)initWithDic:(NSDictionary*)dic;
+ (instancetype)storyWithDic:(NSDictionary*)dic;
@end
