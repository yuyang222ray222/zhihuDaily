//
//  TestViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIRequest.h"
#import "StartImage.h"
#import "TestViewController.h"
#import "zhihuDailyAPI.h"

@interface
TestViewController ()
@property (strong, nonatomic) IBOutlet UIImageView* startImage;

@property (strong, nonatomic) StartImage* model;
@end

@implementation TestViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadStartImage];
}

- (void)loadStartImage
{
  NSString* imageApiUrl =
    [NSString stringWithFormat:@"%@%@", API_Url_StartImage, @"1080*1776"];
  [APIRequest requestWithUrl:imageApiUrl
                  completion:^(id data) {
                    self.model =
                      [StartImage startImageWithDic:[APIRequest objToDic:data]];

                    NSURL* url = [NSURL URLWithString:self.model.img];
                    NSData* imgData = [NSData dataWithContentsOfURL:url];
                    self.startImage.image = [UIImage imageWithData:imgData];
                  }];
}

@end
