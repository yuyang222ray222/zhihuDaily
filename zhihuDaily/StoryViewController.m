//
//  TestViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIDataSource.h"
#import "APIRequest.h"
#import "MainViewController.h"
#import "SliderViewController.h"
#import "StartImage.h"
#import "Story.h"
#import "StoryViewController.h"

@interface
StoryViewController ()

@property (strong, nonatomic) Story* story;
@property (strong, nonatomic) APIDataSource* dataSource;

@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) CGSize viewSize;
@end

@implementation StoryViewController
#pragma mark - accessors
- (APIDataSource*)dataSource
{
  if (_dataSource == nil) {
    _dataSource = [APIDataSource dataSource];
  }
  return _dataSource;
}
- (void)setIdentifier:(NSUInteger)identifier
{
  if (identifier != _identifier) {
    _identifier = identifier;
  }
}
- (CGSize)viewSize
{
  return self.view.bounds.size;
}
- (SliderViewController*)sliderViewController
{
  if (_sliderViewController == nil) {
    _sliderViewController = [[SliderViewController alloc]
      initWithFrame:CGRectMake(0, [MainViewController sliderInsetY],
                               self.viewSize.width,
                               [MainViewController sliderDisplayHeight] +
                                 labs([MainViewController sliderInsetY]))
         andStories:@[ self.story ]];
  }
  return _sliderViewController;
}
#pragma mark - init
- (void)viewDidLoad
{
  [super viewDidLoad];
}
- (void)loadStoryData
{
  [self.dataSource news:self.identifier
             completion:^{
               self.story = self.dataSource.story;
             }];
}

@end
