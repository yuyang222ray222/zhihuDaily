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
#import "Stories.h"
#import "zhihuDailyAPI.h"

@interface MainViewController () <SliderViewDataSource>
@property (copy, nonatomic) NSArray<Stories*>* topStories;
@property (strong, nonatomic) NSMutableArray<Stories*>* stories;
@property (strong, nonatomic) NSMutableArray* dates;

@property (strong, nonatomic) SliderView* sliderView;

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
- (SliderView*)sliderView
{
    if (_sliderView == nil) {
        _sliderView = [[SliderView alloc] init];
        _sliderView.dataSource = self;
        _sliderView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    }
    return _sliderView;
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
    [self buildSliderView];
}
- (void)buildSliderView
{
    self.tableView.tableHeaderView = self.sliderView;
    //[self loadSliderViewImages];
}
#pragma mark - sliderView
- (void)loadSliderViewImages
{
    CacheUtil* util = [CacheUtil cache];
    [self.stories enumerateObjectsUsingBlock:^(Stories* stories, NSUInteger idx, BOOL* _Nonnull stop) {
        for (id url in stories.images) {
            if ([util cachedImageWithKey:url] == nil)
                [util cacheImageWithKey:url andUrl:url completion:^(UIImage* image) {
                    [self.sliderView setImage:image atIndex:idx];
                }];
        }
    }];
}
- (NSUInteger)numberOfItemsInSliderView
{
    return self.topStories.count;
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

    NSLog(@"%@\n%@", self.dates, self.topStories);
}
@end
