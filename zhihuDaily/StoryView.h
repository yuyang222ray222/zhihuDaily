//
//  TestViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoryViewDelegate<NSObject>
/**
 *  当该控制器生命周期结束时调用该方法以释放SliderView
 */
- (void)releaseStoryView;
@end

@interface StoryView : UIWebView
@property (weak, nonatomic) id<StoryViewDelegate> delegate;
@property (strong, nonatomic) SliderViewController* sliderViewController;

@property (assign, nonatomic) NSUInteger identifier;
@end
