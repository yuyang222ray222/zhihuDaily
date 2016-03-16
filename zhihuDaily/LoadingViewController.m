//
//  LaunchScreenViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIRequest.h"
#import "CacheUtil.h"
#import "GCDUtil.h"
#import "LoadingViewController.h"
#import "StartImage.h"
#import "zhihuDailyAPI.h"

@interface LoadingViewController ()
@property (strong, nonatomic) IBOutlet UILabel* authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView* startImage;

@property (strong, nonatomic) StartImage* model;
@end

@implementation LoadingViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadStartImage];
}
- (void)loadStartImage
{
    NSString* imageApiUrl =
        [NSString stringWithFormat:@"%@%@", API_Url_StartImage, @"1080*1776"];
    [APIRequest
        requestWithUrl:imageApiUrl
            completion:^(id data) {
                self.model = [StartImage
                    startImageWithDic:[APIRequest objToDic:data]];

                CacheUtil* cache = [[CacheUtil alloc] init];
                UIImage* image = [cache imageWithKey:self.model.img];
                if (image != nil)
                    self.startImage.image = image;
                else {
                    NSURL* url = [NSURL URLWithString:self.model.img];
                    NSData* imgData = [NSData dataWithContentsOfURL:url];
                    image = [UIImage imageWithData:imgData];
                    [cache cacheImage:image withKey:self.model.img];
                    self.startImage.image = image;
                }
                self.authorLabel.text = self.model.text;
            }];
}
@end
