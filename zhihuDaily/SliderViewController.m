//
//  ViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "CacheUtil.h"
#import "SliderView.h"
#import "SliderViewController.h"
#import "Stories.h"

@interface SliderViewController () <SliderViewDataSource>
@property (strong, nonatomic) NSArray<Stories*>* stories;
@end

@implementation SliderViewController
#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame andStories:(NSArray<Stories*>*)stories
{
    if (self = [super init]) {
        self.stories = stories;

        self.sliderView = [[SliderView alloc] initWithFrame:frame];
        self.sliderView.dataSource = self;
        self.view = self.sliderView;

        [self.sliderView buildSliderView];
        [self loadSliderViewImages];
    }

    return self;
}
- (void)loadSliderViewImages
{
    CacheUtil* util = [CacheUtil cache];
    [self.stories enumerateObjectsUsingBlock:^(Stories* stories, NSUInteger idx, BOOL* _Nonnull stop) {
        NSString* url = stories.image;
        if ([util imageWithKey:url] == nil)
            [util cacheImageWithKey:url andUrl:url completion:^(UIImage* image) {
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

@end
