//
//  PlayView.m
//  LoveMusic
//
//  Created by tt on 15/10/19.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "PlayView.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
@interface PlayView(){
    BOOL  _isPaly;
}
@property(nonatomic,strong)UIView *backView;
@property(nonatomic,strong)UIImageView *palyImageView;
@property(nonatomic,strong)UIButton *playButton;
@end

@implementation PlayView
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];

        _backView = [[UIView alloc]initWithFrame:(CGRect){0, 0,frame.size.width, frame.size.height}];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.3;
        [self addSubview:self.backView];
        
        _palyImageView = [[UIImageView alloc] init];
        _palyImageView.frame = CGRectMake(5, 5, frame.size.height-10, frame.size.height-10);
        _palyImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_palyImageView];
        _palyImageView.layer.masksToBounds = YES;
        _palyImageView.layer.cornerRadius = (frame.size.height-10)/2.0;
        
        _playButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame =CGRectMake(17, 31/2, 19, 19);
        [_playButton setImage:[UIImage imageNamed:@"player_bt_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_bt_play_press"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(playButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        _isPaly = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}
-(void)upDatePlayImage:(NSString*)imageUrl{
    [_palyImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}
-(void)transformRotatePlayImage{
    _palyImageView.transform = CGAffineTransformRotate(_palyImageView.transform, M_PI / 1440);
}
-(void)upDatePlayButton:(BOOL)isPlay{
    if (_isPaly != isPlay) {
        _isPaly = isPlay;
        if (!_isPaly) {
            [_playButton setImage:[UIImage imageNamed:@"player_bt_play"] forState:UIControlStateNormal];
            [_playButton setImage:[UIImage imageNamed:@"player_bt_play_press"] forState:UIControlStateHighlighted];
        }else{
            [_playButton setImage:[UIImage imageNamed:@"player_bt_pause"] forState:UIControlStateNormal];
            [_playButton setImage:[UIImage imageNamed:@"player_bt_pause_press"] forState:UIControlStateHighlighted];
        }
    }
}
//点击事件
-(void)click:(UITapGestureRecognizer*)t
{

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
