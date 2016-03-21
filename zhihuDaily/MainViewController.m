//
//  ViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

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
#import "StoriesTableViewCell.h"
#import "zhihuDailyAPI.h"

static NSString* const kStoriesIdentifier = @"stories";

@interface MainViewController ()
@property (copy, nonatomic) NSArray<Stories*>* topStories;
@property (strong, nonatomic) NSMutableDictionary* stories;
@property (strong, nonatomic) NSMutableArray* dates;

@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) BOOL isLoaded;
@property (strong, nonatomic) UIColor* themeColor;

@property (assign, nonatomic) NSUInteger sliderDisplayHeight;
@property (assign, nonatomic) NSInteger sliderOffsetY;
@end

@implementation MainViewController
#pragma mark - getters
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
- (NSInteger)sliderOffsetY
{
    return -120;
}
- (NSUInteger)sliderDisplayHeight
{
    return 230;
}
- (SliderViewController*)sliderViewController
{
    if (_sliderViewController == nil) {
        _sliderViewController = [[SliderViewController alloc] initWithFrame:CGRectMake(0, self.sliderOffsetY, self.view.bounds.size.width, self.sliderDisplayHeight + labs(self.sliderOffsetY)) andStories:self.topStories];
    }
    return _sliderViewController;
}
- (UIColor*)themeColor
{
    if (_themeColor == nil) {
        _themeColor = [UIColor colorWithRed:51 green:153 blue:230 alpha:1];
    }
    return _themeColor;
}
#pragma mark - init
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildMainPage];
}

#pragma mark - 构建界面
- (void)buildMainPage
{
    [self loadData];
    [self buildTableView];
}
- (void)buildSliderView
{
    [self addChildViewController:self.sliderViewController];
    self.tableView.tableHeaderView = self.sliderViewController.view;
    self.tableView.contentInset = UIEdgeInsetsMake(self.sliderOffsetY, 0, 0, 0);
}
- (void)buildTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"StoriesTableViewCell" bundle:nil] forCellReuseIdentifier:kStoriesIdentifier];
    self.tableView.rowHeight = 90;
}
#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSLog(@"%ld", self.stories.count);
    return self.stories.count;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stories[self.dates[section]] count];
}
- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    view.backgroundColor = self.themeColor;

    UILabel* label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [DateUtil dateString:self.dates[section] fromFormat:@"yyyyMMdd" toFormat:@"MM月dd日 EEEE"];
    label.textColor = [UIColor whiteColor];

    [view addSubview:label];
    return view;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    StoriesTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kStoriesIdentifier forIndexPath:indexPath];
    NSArray<Stories*>* storiesOfADay = self.stories[self.dates[indexPath.section]];
    cell.stories = storiesOfADay[indexPath.row];

    return cell;
}
#pragma mark - 加载、初始化数据
- (void)loadData
{
    [APIRequest
        requestWithUrl:API_Url_NewsLatest
            completion:^(id data, NSString* md5) {
                CacheUtil* util = [CacheUtil cache];

                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[APIRequest objToDic:data]];
                NSString* date = dic[DATAKEY_STORIES_DATE];
                if (util.dataDic[date] == nil) {
                    [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
                    [util.dataDic setObject:dic forKey:date];

                    self.isLoaded = false;
                }
                else {
                    NSDictionary* cachedDic = util.dataDic[date];
                    //compare signature
                    if (![cachedDic[DATAKEY_STORIES_SIGNATURE] isEqualToString:md5]) {
                        [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
                        [util.dataDic setObject:dic forKey:date];

                        self.isLoaded = false;
                    }
                }

                if (!self.isLoaded) {
                    [self initDataWithDic:dic];
                    self.isLoaded = true;

                    //数据加载完后构建SliderView
                    [self buildSliderView];
                    [self.tableView reloadData];
                }
            }];
}
- (void)initDataWithDic:(NSDictionary*)dic
{
    self.topStories = [Stories stories:dic[DATAKEY_STORIES_TOPSTORIES]];
    [self.stories setObject:[Stories stories:dic[DATAKEY_STORIES_STORIES]] forKey:dic[DATAKEY_STORIES_DATE]];
    [self.dates addObject:dic[DATAKEY_STORIES_DATE]];
}

#pragma mark - scrollview delegate
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    [self.sliderViewController.sliderView stopSliding];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
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
}
#pragma mark statusbar style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
