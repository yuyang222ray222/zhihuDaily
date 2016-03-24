//
//  ViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stories;
@class SliderView;

@interface SliderViewController : UIViewController
@property (strong, nonatomic) SliderView* sliderView;

- (instancetype)initWithFrame:(CGRect)frame
                   andStories:(NSArray<Stories*>*)stories;
@end
