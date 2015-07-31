//
//  FeedCell.h
//  LoveMusic
//
//  Created by le_cui on 15/7/31.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (nonatomic, strong) UIImageView* profileImageView;

@property (nonatomic, strong) UILabel* nameLabel;

@property (nonatomic, strong) UILabel* updateLabel;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UILabel* commentCountLabel;

@property (nonatomic, strong) UILabel* likeCountLabel;

@end
