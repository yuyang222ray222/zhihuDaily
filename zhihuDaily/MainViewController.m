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
#import "zhihuDailyAPI.h"

@interface MainViewController ()
@property (copy, nonatomic) NSArray<Stories*>* topStories;
@property (strong, nonatomic) NSMutableArray<Stories*>* stories;
@property (strong, nonatomic) NSMutableArray* dates;

@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) BOOL isLoaded;
@end

@implementation MainViewController
#pragma mark - getters
- (NSMutableArray*)dates
{
    if (_dates == nil) {
        _dates = [NSMutableArray array];
    }
    return _dates;
}
- (SliderViewController*)sliderViewController
{
    if (_sliderViewController == nil) {
        _sliderViewController = [[SliderViewController alloc] initWithFrame:CGRectMake(0, kContentOffsetY, self.view.bounds.size.width, 180 + labs(kContentOffsetY)) andStories:self.topStories];
    }
    return _sliderViewController;
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
}
- (void)buildSliderView
{
    [self addChildViewController:self.sliderViewController];
    self.tableView.tableHeaderView = self.sliderViewController.view;
    self.tableView.bounds = CGRectMake(0, kContentOffsetY, self.view.bounds.size.width, self.view.bounds.size.height + labs(kContentOffsetY));
}

#pragma mark - 加载、初始化数据
- (void)loadData
{
    [APIRequest
        requestWithUrl:API_Url_NewsLatest
            completion:^(id data, NSString* md5) {
                //获取缓存
                CacheUtil* util = [CacheUtil cache];

                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[APIRequest objToDic:data]];
                NSString* date = dic[DATAKEY_STORIES_DATE];
                //如果没有缓存，就缓存下来
                if (util.dataDic[date] == nil) {
                    [dic setValue:md5 forKey:DATAKEY_STORIES_SIGNATURE];
                    [util.dataDic setObject:dic forKey:date];

                    self.isLoaded = false;
                }
                //如果有缓存，验证签名
                else {
                    NSDictionary* cachedDic = util.dataDic[date];
                    //签名不一样就缓存
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
                }
            }];
}
- (void)initDataWithDic:(NSDictionary*)dic
{
    self.topStories = [Stories stories:dic[DATAKEY_STORIES_TOPSTORIES]];
    [self.stories addObjectsFromArray:[Stories stories:dic[DATAKEY_STORIES_STORIES]]];

    NSDate* date = [DateUtil stringToDate:dic[DATAKEY_STORIES_DATE] format:@"yyyyMMdd"];
    NSString* dateStrWithWeek = [DateUtil appendWeekStringFromDate:date withFormat:@"MM月dd日 "];
    [self.dates addObject:dateStrWithWeek];

    NSLog(@"主页数据读取完毕");
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
    if (scrollView.contentOffset.y <= -50) {
        CGPoint offset = scrollView.contentOffset;
        offset.y = -50;
        scrollView.contentOffset = offset;
    }
}
#pragma mark statusbar style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
