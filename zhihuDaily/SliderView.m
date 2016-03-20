//
//  SliderView.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/19.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "GradientView.h"
#import "SliderView.h"

const NSInteger kContentOffsetY = -120;

@interface SliderView () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIPageControl* pageControl;

@property (assign, nonatomic) CGSize viewSize;
@property (assign, nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSTimer* timer;

@property (assign, nonatomic) NSUInteger imageCount;
@property (strong, nonatomic) NSMutableArray<UIImageView*>* imageViews;
@end

@implementation SliderView
#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.viewSize = frame.size;
    }
    return self;
}
- (void)buildSliderView
{
    [self loadImages];
    [self loadContents];
    [self addSubview:self.scrollView];

    //以下内容在imagecount大于1时才会初始化
    [self bringSubviewToFront:self.pageControl];
    [self startSliding];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(stopSliding) name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(startSliding) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)loadImages
{
    for (int i = 0; i < self.imageCount; i++) {
        UIImageView* imageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(i * self.viewSize.width, 0,
                              self.viewSize.width, self.viewSize.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;

        imageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [self.scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];

        //委托获取图片
        if ([self.dataSource respondsToSelector:@selector(imageForSliderAtIndex:)]) {
            UIImage* image = [self.dataSource imageForSliderAtIndex:i];
            if (image != nil)
                imageView.image = image;
        }
    }
}
- (void)loadContents
{
    if (![self.dataSource respondsToSelector:@selector(contentForSliderAtIndex:)])
        return;

    for (int i = 0; i < self.imageCount; i++) {
        //委托获取内容
        NSString* content = [self.dataSource contentForSliderAtIndex:i];
        if (content == nil)
            continue;

        GradientView* gradientView = [[GradientView alloc] initWithFrame:CGRectMake(i * self.viewSize.width, labs(kContentOffsetY), self.viewSize.width, self.viewSize.height + kContentOffsetY)];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, self.viewSize.width - 20, 50)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:20 weight:0.3];
        label.shadowOffset = CGSizeMake(0, 1);
        label.shadowColor = [UIColor blackColor];
        label.numberOfLines = 2;
        label.text = content;
        [label sizeToFit];

        [gradientView addSubview:label];
        [self.scrollView addSubview:gradientView];
    }
}
- (UIPageControl*)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        if (self.imageCount <= 1)
            return _pageControl;

        _pageControl.numberOfPages = self.imageCount;
        CGSize pagerSize = [_pageControl sizeForNumberOfPages:self.imageCount];
        _pageControl.bounds = CGRectMake(0, 0, self.viewSize.width, pagerSize.height);
        _pageControl.center = CGPointMake(self.center.x, self.viewSize.height - 15);

        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];

        [_pageControl addTarget:self
                         action:@selector(pageChanged:)
               forControlEvents:UIControlEventValueChanged];

        [self addSubview:_pageControl];
    }
    return _pageControl;
}
- (UIScrollView*)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.viewSize.width, self.viewSize.height)];

        [_scrollView
            setContentSize:CGSizeMake(self.viewSize.width * self.imageCount,
                               self.viewSize.height)];
        [_scrollView setPagingEnabled:true];

        UIButton* button = [[UIButton alloc]
            initWithFrame:CGRectMake(0, 0, _scrollView.contentSize.width,
                              _scrollView.contentSize.height)];
        button.titleLabel.text = @"";
        [button addTarget:self
                      action:@selector(sliderClicked)
            forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];

        // 禁止反弹效果，隐藏滚动条
        [_scrollView setBounces:false];
        [_scrollView setShowsVerticalScrollIndicator:false];
        [_scrollView setShowsHorizontalScrollIndicator:false];

        _scrollView.delegate = self;
    }
    return _scrollView;
}
#pragma mark - getters
- (CGSize)viewSize
{
    return self.bounds.size;
}
- (NSUInteger)imageCount
{
    if (_imageCount == 0) {
        _imageCount = [self.dataSource numberOfItemsInSliderView];
    }
    return _imageCount;
}

- (NSUInteger)pageIndex
{
    return self.scrollView.contentOffset.x / self.viewSize.width;
}
- (NSMutableArray<UIImageView*>*)imageViews
{
    if (_imageViews == nil) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}
#pragma mark - public methods
- (void)setImage:(UIImage*)image atIndex:(NSUInteger)index
{
    UIImageView* imageView = self.imageViews[index];
    if (imageView != nil) {
        //CGRect position = imageView.frame;
        [imageView setImage:image];
        [imageView setNeedsDisplay];
        [self setNeedsDisplay];
        [self.scrollView setNeedsDisplay];
    }
}
- (void)stopSliding
{
    [self.timer invalidate];
}
- (void)startSliding
{
    if (self.imageCount <= 1)
        return;

    self.timer =
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(intervalTriggered)
                                       userInfo:nil
                                        repeats:true];
}
#pragma mark - slider click event
- (void)sliderClicked
{
    if ([self.dataSource respondsToSelector:@selector(touchUpForSliderAtIndex:)])
        [self.dataSource touchUpForSliderAtIndex:self.pageControl.currentPage];
}

#pragma mark - Timer

- (void)intervalTriggered
{
    int pageIndex = (self.pageControl.currentPage + 1) % self.imageCount;
    self.pageControl.currentPage = pageIndex;
    [self pageChanged:self.pageControl];
}

- (void)pageChanged:(UIPageControl*)pageControl
{
    CGFloat offsetX = pageControl.currentPage * self.viewSize.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
}

#pragma mark - ScrollView delegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    //拖拽时停止计时器
    [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate
{
    //拖拽结束重新开始
    [self startSliding];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    self.pageControl.currentPage = self.pageIndex;
}

@end
