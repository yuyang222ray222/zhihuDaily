//
//  MainTableViewCell.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/20.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stories;

@interface StoriesTableViewCell : UITableViewCell
@property (strong, nonatomic) Stories* stories;
@end
