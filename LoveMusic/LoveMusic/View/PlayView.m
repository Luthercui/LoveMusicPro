//
//  PlayView.m
//  LoveMusic
//
//  Created by tt on 15/10/19.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "PlayView.h"
#import "SongInfo.h"
#import "AppDelegate.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
@interface PlayView(){
    BOOL  _isPaly;
}
@property(nonatomic,strong)UIImageView *palyImageView;
@property(nonatomic,strong)UIButton *playButton;
@property(nonatomic,strong)UILabel *playerInfoLabel;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *playProgress;
@end

@implementation PlayView
-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        
        UIImageView *imageBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,  frame.size.height)];
        imageBackGround.image = [UIImage imageNamed:@"navbar"];
        [self addSubview:imageBackGround];
        

        _palyImageView = [[UIImageView alloc] init];
        _palyImageView.frame = CGRectMake(frame.size.width- frame.size.height, 5, frame.size.height-10, frame.size.height-10);
        _palyImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_palyImageView];
        _palyImageView.layer.masksToBounds = YES;
        _palyImageView.layer.cornerRadius = (frame.size.height-10)/2.0;
        
        _playButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame =CGRectMake(5, 5, 45, 45);
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
        
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        _isPaly = NO;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, frame.size.width-140, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor =  [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        _playerInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, frame.size.width-140, 20)];
        _playerInfoLabel.backgroundColor = [UIColor clearColor];
        _playerInfoLabel.font = [UIFont systemFontOfSize:15];
        _playerInfoLabel.textColor =  [UIColor grayColor];
        _playerInfoLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_playerInfoLabel];
        
        self.playProgress = [[UILabel alloc] initWithFrame:CGRectZero];
        _playProgress.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
        [self addSubview:_playProgress];
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}
-(void)upDatePlayImage:(NSString*)imageUrl{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_isPaly) {
            _isPaly = YES;
            [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
            [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
        }
        
        [_palyImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _playerInfoLabel.text = [SongInfo currentSong].artist;
        _titleLabel.text = [SongInfo currentSong].title ;
    });
}
-(void)play{

    if (!_isPaly) {
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
            if(_playDelegate && [_playDelegate respondsToSelector:@selector(musicToPlay)])
            {
                [_playDelegate musicToPlay];
            }
    }else{
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
            if(_playDelegate && [_playDelegate respondsToSelector:@selector(musicToPause)])
            {
                [_playDelegate musicToPause];
            }
    }
    _isPaly = !_isPaly;
}
-(void)transformRotatePlayImage{
    _palyImageView.transform = CGAffineTransformRotate(_palyImageView.transform, M_PI / 1440);
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    float currentPlayPorgress = delegate.player.currentPlaybackTime/delegate.player.duration;
    float progressw = self.frame.size.width*currentPlayPorgress;
    if (!isnan(progressw)) {
        self.playProgress.frame = CGRectMake(0, self.frame.size.height-2, progressw, 4);
    }
}
-(void)upDatePlayButton:(BOOL)isPlay{

    if (!_isPaly) {
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
    }else{
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
    }
    _isPaly = isPlay;
}
//点击事件
-(void)click:(UITapGestureRecognizer*)t
{
    if(_playDelegate && [_playDelegate respondsToSelector:@selector(playTocuhs)])
    {
        [_playDelegate playTocuhs];
    }

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
