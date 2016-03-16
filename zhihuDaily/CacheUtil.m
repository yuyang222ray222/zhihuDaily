//
//  CacheUtil.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "CacheUtil.h"
#import "DateUtil.h"

NSString* const kCacheImagePath = @"images/";
NSString* const kDataPath = @"data.plist";

@interface CacheUtil ()
@property (copy, nonatomic) NSString* documentPath;

@property (copy, nonatomic) NSString* dataPath;
@property (copy, nonatomic) NSString* imagePath;
@end

@implementation CacheUtil
#pragma mark - getters
- (NSString*)dataPath
{
    if (_dataPath == nil) {
        _dataPath = [self.documentPath stringByAppendingString:kDataPath];
    }
    return _dataPath;
}
- (NSString*)imagePath
{
    if (_imagePath == nil) {
        _imagePath = [self.documentPath stringByAppendingString:kCacheImagePath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_imagePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_imagePath withIntermediateDirectories:true attributes:nil error:nil];
            NSLog(@"成功创建图片缓存目录");
        }
    }
    return _imagePath;
}
- (NSString*)documentPath
{
    if (_documentPath == nil) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
            NSUserDomainMask, true);
        _documentPath = [paths[0] stringByAppendingString:@"/"];
    }
    return _documentPath;
}
- (NSDictionary*)dataDic
{
    if (_dataDic == nil) {
        _dataDic = [NSMutableDictionary dictionary];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataPath]) {
            _dataDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.dataPath];
            NSLog(@"成功加载plist文件");
        }
    }
    return _dataDic;
}

#pragma mark - plist cache
- (void)saveData
{
    BOOL result = [self.dataDic writeToFile:self.dataPath atomically:true];
    if (!result)
        NSLog(@"保存plist失败！%@", self.dataPath);
}

#pragma mark - image cache
- (void)cacheImage:(UIImage*)image withKey:(NSString*)key
{
    NSString* cachedImagePath = [self.dataDic objectForKey:key];
    if (cachedImagePath == nil) {
        NSString* savePath = [self.imagePath stringByAppendingString:[NSString stringWithFormat:@"%@.png", [DateUtil dateIdentifierNow]]];
        NSError* error = nil;
        BOOL result = [UIImagePNGRepresentation(image) writeToFile:savePath options:NSDataWritingAtomic error:&error];
        if (result) {
            [self.dataDic setObject:savePath forKey:key];
            [self saveData];
        }
        else {
            NSLog(@"Fail to save image %@", error.localizedDescription);
        }
    }
}
- (UIImage*)imageWithKey:(NSString*)key
{
    NSString* path = [self.dataDic objectForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.imagePath]) {
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        return image;
    }
    return nil;
}
@end
