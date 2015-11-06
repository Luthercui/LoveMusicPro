//
//  AlbumTableViewCell.m
//  LoveMusic
//
//  Created by tt on 15/11/6.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "AlbumTableViewCell.h"

@implementation AlbumTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor =  [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
        
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
        
        
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:15];
        _subTitleLabel.textColor =  [UIColor grayColor];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_subTitleLabel];
        

        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-10-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_titleLabel(30)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_subTitleLabel]-5-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_subTitleLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_subTitleLabel]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_subTitleLabel)]];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
