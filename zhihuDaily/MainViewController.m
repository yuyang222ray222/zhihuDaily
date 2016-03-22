//
//  ViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIDataSource.h"
#import "APIRequest.h"
#import "CacheUtil.h"
#import "DataKeys.m"
#import "DateUtil.h"
#import "GCDUtil.h"
#import "MD5Util.h"
#import "MainViewController.h"
#import "SliderView.h"
#import "SliderViewController.h"
#import "Stories.h"
#import "StoriesHeaderCell.h"
#import "StoriesTableViewCell.h"
#import "UINavigationBar+BackgroundColor.h"

static NSString* const kStoriesIdentifier = @"stories";
static NSString* const kStoriesHeaderIdentifier = @"storiesHeader";
static NSUInteger const kHeaderViewHeight = 44;

@interface
MainViewController ()
@property (strong, nonatomic) APIDataSource* dataSource;

@property (copy, nonatomic) NSArray<Stories*>* topStories;
@property (strong, nonatomic) NSMutableDictionary* stories;
@property (strong, nonatomic) NSMutableArray* dates;

@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) CGSize viewSize;
@property (assign, nonatomic) NSUInteger sliderDisplayHeight;
@property (assign, nonatomic) NSInteger sliderInsetY;

@property (nonatomic, readonly) UIColor* themeColorWithAdjustmentAlpha;
@end

@implementation MainViewController
#pragma mark - getters
- (APIDataSource*)dataSource
{
  if (_dataSource == nil) {
    _dataSource = [APIDataSource dataSource];
  }
  return _dataSource;
}
- (NSMutableDictionary*)stories
{
  if (_stories == nil) {
    _stories = [NSMutableDictionary dictionary];
  }
  return _stories;
}
- (NSMutableArray*)dates
{
  if (_dates == nil) {
    _dates = [NSMutableArray array];
  }
  return _dates;
}

- (CGSize)viewSize
{
  return self.view.bounds.size;
}
+ (UIColor*)themeColor
{
  static UIColor* color = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    color = [UIColor colorWithRed:51.0 / 255
                            green:153.0 / 255
                             blue:230.0 / 255
                            alpha:1];
  });
  return color;
}
- (NSInteger)sliderInsetY
{
  return -100;
}
- (NSUInteger)sliderDisplayHeight
{
  return 736 == [[UIScreen mainScreen] bounds].size.height ? 230 : 200;
}
- (SliderViewController*)sliderViewController
{
  if (_sliderViewController == nil) {
    _sliderViewController = [[SliderViewController alloc]
      initWithFrame:CGRectMake(0, self.sliderInsetY, self.viewSize.width,
                               self.sliderDisplayHeight +
                                 labs(self.sliderInsetY))
         andStories:self.topStories];
  }
  return _sliderViewController;
}
- (UIColor*)themeColorWithAdjustmentAlpha
{
  CGFloat contentOffsetY = self.tableView.contentOffset.y;
  contentOffsetY = MAX(contentOffsetY, 0);
  CGFloat alpha =
    (contentOffsetY + self.sliderInsetY) / (self.sliderDisplayHeight - 64);
  UIColor* color =
    [[MainViewController themeColor] colorWithAlphaComponent:alpha];
  return color;
}
#pragma mark - initialization
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self buildMainPage];
}
- (void)buildMainPage
{
  [self loadLatestData];
  [self buildNavigation];
  [self buildTableView];
}
- (void)buildSliderView
{
  [self addChildViewController:self.sliderViewController];
  self.tableView.tableHeaderView = self.sliderViewController.view;
}
- (void)buildNavigation
{
  [self setNavigationBarTransparent];
  [self.navigationController.navigationBar setTitleTextAttributes:@{
    NSForegroundColorAttributeName : [UIColor whiteColor]
  }];
}
- (void)buildTableView
{
  [self.tableView registerNib:[UINib nibWithNibName:@"StoriesTableViewCell"
                                             bundle:nil]
       forCellReuseIdentifier:kStoriesIdentifier];
  self.tableView.showsVerticalScrollIndicator = false;
  self.tableView.showsHorizontalScrollIndicator = false;
  self.tableView.rowHeight = 90;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
  return self.stories.count;
}
- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [self.stories[self.dates[section]] count];
}
- (CGFloat)tableView:(UITableView*)tableView
  heightForHeaderInSection:(NSInteger)section
{
  return kHeaderViewHeight;
}
- (UIView*)tableView:(UITableView*)tableView
  viewForHeaderInSection:(NSInteger)section
{
  StoriesHeaderCell* header = [[StoriesHeaderCell alloc]
    initWithFrame:CGRectMake(0, 0, self.viewSize.width, kHeaderViewHeight)];
  header.text = [DateUtil dateString:self.dates[section]
                          fromFormat:@"yyyyMMdd"
                            toFormat:@"MM月dd日 EEEE"];

  return header;
}
- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  StoriesTableViewCell* cell =
    [tableView dequeueReusableCellWithIdentifier:kStoriesIdentifier
                                    forIndexPath:indexPath];
  NSArray<Stories*>* storiesOfADay =
    self.stories[self.dates[indexPath.section]];
  cell.stories = storiesOfADay[indexPath.row];

  return cell;
}
#pragma mark - api datasource
- (void)loadLatestData
{
  [self.dataSource newsLatest:^(BOOL needsToReload) {
    if (!needsToReload && self.topStories.count != 0)
      return;

    self.topStories = self.dataSource.topStories;
    [self.stories setObject:self.dataSource.stories
                     forKey:self.dataSource.date];
    [self.dates addObject:self.dataSource.date];

    [self buildSliderView];
    [self.tableView reloadData];
  }];
}
#pragma mark - scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
  [self.sliderViewController.sliderView stopSliding];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate
{
  [self.sliderViewController.sliderView startSliding];
}
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
  //限制scrollview的bounce size
  if (scrollView.contentOffset.y <= 0) {
    CGPoint offset = scrollView.contentOffset;
    offset.y = 0;
    scrollView.contentOffset = offset;
  }
  [self adjustNavigationAlpha];
}
#pragma mark navigationbar styles
- (void)setNavigationBarTransparent
{
  self.navigationController.navigationBar.translucent = true;

  UIColor* color = [UIColor clearColor];
  CGRect rect = CGRectMake(0, 0, self.viewSize.width, 64);

  UIGraphicsBeginImageContext(rect.size);
  CGContextRef ref = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(ref, color.CGColor);
  CGContextFillRect(ref, rect);
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  [self.navigationController.navigationBar
    setBackgroundImage:image
         forBarMetrics:UIBarMetricsDefault];
}

- (void)adjustNavigationAlpha
{
  if (self.tableView.contentOffset.y >
      self.sliderDisplayHeight + labs(self.sliderInsetY + 20)) {
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    //这里不能直接隐藏navigationbar，会导致tableview的insettop失控
    self.navigationItem.title = @"";
    //缩短背景视图避免其挡住section header
    [self.navigationController.navigationBar setBackgroundLayerHeight:20];
  } else {
    self.tableView.contentInset = UIEdgeInsetsMake(self.sliderInsetY, 0, 0, 0);
    self.navigationItem.title = @"今日热闻";
    [self.navigationController.navigationBar
      setNavigationBackgroundColor:self.themeColorWithAdjustmentAlpha];

    [self.navigationController.navigationBar setBackgroundLayerHeight:64];
  }
}
@end
