//
//  TestViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIDataSource.h"
#import "APIRequest.h"
#import "GCDUtil.h"
#import "MainViewController.h"
#import "SliderView.h"
#import "SliderViewController.h"
#import "StartImage.h"
#import "Story.h"
#import "StoryViewController.h"
#import "UINavigationBar+BackgroundColor.h"

@interface
StoryViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView* webView;

@property (strong, nonatomic) Story* story;
@property (strong, nonatomic) APIDataSource* dataSource;

@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) CGSize viewSize;

@property (assign, nonatomic) CGPoint gestureStartPoint;
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

    [self loadStoryData];
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
      initWithFrame:CGRectMake(0, 0, self.viewSize.width,
                               [MainViewController sliderDisplayHeight] +
                                 labs([MainViewController sliderInsetY]))
           andStory:self.story];
  }
  return _sliderViewController;
}
#pragma mark - init
- (void)viewDidLoad
{
  [super viewDidLoad];
}
- (instancetype)init
{
  if (self = [super init]) {
    [self buildWebView];
    [self buildNavigation];
  }
  return self;
}
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [self.navigationController.navigationBar setHidden:true];
  [self.navigationController.navigationBar
    setNavigationBackgroundColor:[UIColor clearColor]];
}
- (void)buildWebView
{
  self.webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.view = self.webView;
  self.webView.backgroundColor = [UIColor whiteColor];
  self.webView.scrollView.delegate = self;
  self.webView.scrollView.contentInset =
    UIEdgeInsetsMake([MainViewController sliderInsetY], 0, 0, 0);

  [self addGestureRecognizer];
}
- (void)buildNavigation
{
}
#pragma mark - data load
- (void)loadSliderView
{
  [self addChildViewController:self.sliderViewController];
  [self.webView.scrollView addSubview:self.sliderViewController.view];
}
- (void)loadWebView
{
  [[GCDUtil globalQueueWithLevel:HIGH] async:^{
    NSData* data =
      [NSData dataWithContentsOfURL:[NSURL URLWithString:self.story.css]];
    NSString* cssContent =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger bodyPadding =
      736 == [[UIScreen mainScreen] bounds].size.height ? 130 : 100;
    NSString* customCss =
      [NSString stringWithFormat:@"body {padding-top:%ldpx;}", bodyPadding];
    NSString* htmlFormatString = @"<html><head><style>%@</style><style "
                                 @"type='text/css'>%@</style></head><body>%@</"
                                 @"body></html>";
    NSString* htmlString =
      [NSString stringWithFormat:htmlFormatString, cssContent, customCss,
                                 self.story.body];
    [[GCDUtil mainQueue] async:^{
      [self.webView loadHTMLString:htmlString baseURL:nil];
    }];
  }];
}
- (void)loadStoryData
{
  [self.dataSource news:self.identifier
             completion:^{
               self.story = self.dataSource.story;

               [self loadSliderView];
               [self loadWebView];
             }];
}
#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
  //限制scrollview的bounce size
  if (scrollView.contentOffset.y <= 0) {
    CGPoint offset = scrollView.contentOffset;
    offset.y = 0;
    scrollView.contentOffset = offset;
  }
}
#pragma mark - swipe back
- (void)addGestureRecognizer
{
  UISwipeGestureRecognizer* horizontal = [[UISwipeGestureRecognizer alloc]
    initWithTarget:self
            action:@selector(reportHorizontalSwipe:)];
  horizontal.direction = UISwipeGestureRecognizerDirectionLeft |
                         UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:horizontal];
}
- (void)reportHorizontalSwipe:(UIGestureRecognizer*)recognizer
{
  [self backToMainViewController];
}
- (void)backToMainViewController
{
  [UIView animateWithDuration:0.3
    animations:^{
      self.view.frame =
        CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width,
                   self.view.bounds.size.height);
    }
    completion:^(BOOL finished) {
      [self dismissViewControllerAnimated:false completion:nil];
    }];
}
@end
