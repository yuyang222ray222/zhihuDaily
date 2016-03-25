//
//  ViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "CacheUtil.h"
#import "MainViewController.h"
#import "SliderView.h"
#import "SliderViewController.h"
#import "Stories.h"
#import "Story.h"

@interface
SliderViewController ()<SliderViewDataSource>
@property (strong, nonatomic) NSArray<Stories*>* stories;
@property (strong, nonatomic) Story* story;
@end

@implementation SliderViewController
#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame andStory:(Story*)story
{
  if (self = [super init]) {
    Stories* stories = [[Stories alloc] init];
    stories.image = story.image;
    stories.title = story.title;

    self.stories = @[ stories ];
    self.story = story;

    self.sliderView = [[SliderView alloc] initWithFrame:frame];

    [self buildSliderView];
  }
  return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                   andStories:(NSArray<Stories*>*)stories
{
  if (self = [super init]) {
    self.stories = stories;
    self.sliderView = [[SliderView alloc] initWithFrame:frame];

    [self buildSliderView];
  }

  return self;
}
- (void)buildSliderView
{
  self.sliderView.dataSource = self;
  self.sliderView.contentInsetY = [MainViewController sliderInsetY];
  self.view = self.sliderView;

  [self.sliderView buildSliderView];
  [self loadSliderViewImages];
}
- (void)loadSliderViewImages
{
  CacheUtil* util = [CacheUtil cache];
  [self.stories
    enumerateObjectsUsingBlock:^(Stories* stories, NSUInteger idx, BOOL* stop) {
      NSString* url = stories.image;
      if ([util imageWithKey:url] == nil)
        [util cacheImageWithKey:url
                         andUrl:url
                     completion:^(UIImage* image) {
                       [self.sliderView setImage:image atIndex:idx];
                     }];
      else
        [self.sliderView setImage:[util imageWithKey:url] atIndex:idx];
    }];
}
#pragma mark - sliderView datasource
- (NSUInteger)numberOfItemsInSliderView
{
  return self.stories.count;
}
- (NSString*)titleForSliderAtIndex:(NSInteger)index
{
  return self.stories[index].title;
}
- (NSString*)subTitleForSliderAtIndex:(NSInteger)index
{
  return self.story.imageSource;
}
@end
