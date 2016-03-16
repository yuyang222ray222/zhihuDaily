//
//  StartImage.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "StartImage.h"

@implementation StartImage
- (instancetype)initWithDic:(NSDictionary*)dic
{
  if (self = [super init]) {
    [self setValuesForKeysWithDictionary:dic];
  }
  return self;
}
+ (instancetype)startImageWithDic:(NSDictionary*)dic
{
  return [[StartImage alloc] initWithDic:dic];
}
@end
