//
//  LaunchScreenViewController.m
//  zhihuDaily
//
//  Created by Siegrain on 16/3/16.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "APIRequest.h"
#import "AppDelegate.h"
#import "CacheUtil.h"
#import "DataKeys.m"
#import "GCDUtil.h"
#import "GradientView.h"
#import "LoadingViewController.h"
#import "MainViewController.h"
#import "StartImage.h"
#import "zhihuDailyAPI.h"

@interface
LoadingViewController ()
@property (strong, nonatomic) IBOutlet UILabel* authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView* startImage;
@property (strong, nonatomic) IBOutlet UIImageView* logoImage;

@property (strong, nonatomic) StartImage* model;
@end

@implementation LoadingViewController
- (void)viewDidLoad
{
  [super viewDidLoad];

  //放大动画
  [UIView animateWithDuration:2
                        delay:0.0
                      options:(UIViewAnimationOptionTransitionCrossDissolve)
                   animations:^{
                     self.startImage.layer.transform =
                       CATransform3DMakeScale(1.1, 1.1, 1.1);
                   }
                   completion:nil];

  //跳转
  UIStoryboard* storyboard =
    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UINavigationController* viewController = [storyboard
    instantiateViewControllerWithIdentifier:@"RootNavigationController"];
  AppDelegate* delegate = [UIApplication sharedApplication].delegate;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [delegate changeRootViewController:viewController
                                              animate:true];
                 });
  //下面这段是通过present出来的控制器，会有tableview设置style无效的bug
  //    dispatch_after(
  //      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
  //      dispatch_get_main_queue(), ^{
  //        mainVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  //        [self presentViewController:mainVC animated:true completion:nil];
  //      });
}
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self loadGradientView];
  [self loadStartImage];
}
- (void)loadStartImage
{
  CacheUtil* cache = [CacheUtil cache];
  UIImage* image = [cache imageWithKey:DATAKEY_STARTIMAGE];
  if (image != nil) {
    self.startImage.image = image;
    self.authorLabel.text = cache.dataDic[DATAKEY_STARTIMAGE_AUTHOR];
  }
}
- (void)loadGradientView
{
  GradientView* gradientView = [[GradientView alloc] init];

  [self.view addSubview:gradientView];

  NSDictionary* views = NSDictionaryOfVariableBindings(gradientView, self.view);
  NSString* vfw = [NSString
    stringWithFormat:@"H:|[gradientView(%f)]|", self.view.bounds.size.width];
  [self.view
    addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfw
                                                           options:0
                                                           metrics:nil
                                                             views:views]];
  [self.view
    addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:[gradientView(250)]|"
                                         options:0
                                         metrics:nil
                                           views:views]];

  [self.view bringSubviewToFront:self.logoImage];
  [self.view bringSubviewToFront:self.authorLabel];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}
@end
