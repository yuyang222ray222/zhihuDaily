//
//  ViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "SliderView.h"

@interface SliderView () <UIScrollViewDelegate>
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIPageControl *pageControl;
@property(assign, nonatomic) CGSize viewSize;
@property(assign, nonatomic) NSUInteger pageIndex;
@property(strong, nonatomic) NSTimer *timer;

@property(assign, nonatomic) NSUInteger imageCount;
@end

@implementation SliderView
#pragma mark - Initialization
- (instancetype)init {
  if (self = [super init]) {
    [self initImagesAndContents];
    [self bringSubviewToFront:self.pageControl];
    [self startTimer];
  }
  return self;
}

- (NSUInteger)imageCount {
  if (_imageCount == NSNotFound) {
    _imageCount = [self.dataSource numberOfItemsInSliderView];
  }
  return _imageCount;
}

- (UIScrollView *)scrollView {
  if (_scrollView == nil) {
    _scrollView =
        [[UIScrollView alloc] initWithFrame:CGRectMake(10, 20, 300, 130)];
    _scrollView.backgroundColor = [UIColor grayColor];

    [_scrollView
        setContentSize:CGSizeMake(self.viewSize.width * self.imageCount,
                                  self.viewSize.height)];
    [_scrollView setPagingEnabled:true];

    UIButton *button = [[UIButton alloc]
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

    [_scrollView setDelegate:self];
  }
  return _scrollView;
}
- (CGSize)viewSize {
  return self.scrollView.bounds.size;
}
- (UIPageControl *)pageControl {
  if (_pageControl == nil) {
    _pageControl = [[UIPageControl alloc] init];

    _pageControl.numberOfPages = self.imageCount;
    CGSize pagerSize = [_pageControl sizeForNumberOfPages:self.imageCount];
    _pageControl.bounds =
        CGRectMake(0, 0, self.viewSize.width, pagerSize.height);
    _pageControl.center = CGPointMake(self.center.x, 130);
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [_pageControl addTarget:self
                     action:@selector(pageChanged:)
           forControlEvents:UIControlEventValueChanged];

    [self addSubview:_pageControl];
  }
  return _pageControl;
}
- (NSUInteger)pageIndex {
  return self.scrollView.contentOffset.x / self.viewSize.width;
}

- (void)initImagesAndContents {
  self.viewSize = self.scrollView.bounds.size;

  for (int i = 0; i < self.imageCount; i++) {
    //初始化图片
    UIImage *image = [self.dataSource imageForSliderAtIndex:i];

    UIImageView *imageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(i * self.viewSize.width, 0,
                                 self.viewSize.width, self.viewSize.height)];
    imageView.image = image;

    [self.scrollView addSubview:imageView];

    //初始化内容
    NSString *content = [self.dataSource contentForSliderAtIndex:i];

    //    UILabel *label =
    //        [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 320, 100)];
    //    label.text = @"我是标题标题标题！";
    //    label.textColor = [UIColor whiteColor];
    //
    //    _layerView =
    //        [[UIView alloc] initWithFrame:CGRectMake(0, 320 - 100, 320, 100)];
    //
    //    _gradientLayer = [CAGradientLayer layer]; // 设置渐变效果
    //    _gradientLayer.bounds = _layerView.bounds;
    //    _gradientLayer.borderWidth = 0;
    //
    //    _gradientLayer.frame = _layerView.bounds;
    //    _gradientLayer.colors =
    //        [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],
    //                                  (id)[[UIColor blackColor] CGColor],
    //                                  nil];
    //    _gradientLayer.startPoint = CGPointMake(0.5, 0.5);
    //    _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    //
    //    [_layerView.layer insertSublayer:_gradientLayer atIndex:0];
    //
    //    [_imageView addSubview:_layerView];
    //    [_layerView addSubview:label];
  }
}
#pragma mark - slider click event
- (void)sliderClicked {
  [self.dataSource touchUpForSliderAtIndex:self.pageControl.currentPage];
}

#pragma mark - Timer
- (void)startTimer {
  self.timer =
      [NSTimer scheduledTimerWithTimeInterval:1.5
                                       target:self
                                     selector:@selector(intervalTriggered)
                                     userInfo:nil
                                      repeats:true];
}
- (void)intervalTriggered {
  int pageIndex = (self.pageControl.currentPage + 1) % self.imageCount;
  self.pageControl.currentPage = pageIndex;
  [self pageChanged:self.pageControl];
}

- (void)pageChanged:(UIPageControl *)pageControl {
  CGFloat offsetX = pageControl.currentPage * self.viewSize.width;
  [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
}

#pragma mark - ScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  //拖拽时停止计时器
  [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  //拖拽结束重新开始
  [self startTimer];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  self.pageControl.currentPage = self.pageIndex;
}
@end
