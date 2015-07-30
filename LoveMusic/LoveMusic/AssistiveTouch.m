//
//  AssistiveTouch.m
//  navTest
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "AssistiveTouch.h"

#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@implementation AssistiveTouch

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;
        [self makeKeyAndVisible];
        _imageView = [[UIView alloc]initWithFrame:(CGRect){0, 0,frame.size.width, frame.size.height}];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.alpha = 0.3;
        [self addSubview:_imageView];
        
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
        
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)upDatePlayImage:(NSString*)imageUrl{
    [_palyImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
-(void)playButton{
    if (_isPaly) {
        _isPaly = NO;
        [_playButton setImage:[UIImage imageNamed:@"player_bt_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_bt_play_press"] forState:UIControlStateHighlighted];
        if(_assistiveDelegate && [_assistiveDelegate respondsToSelector:@selector(musicToPause)])
        {
            [_assistiveDelegate musicToPause];
        }
    }else{
        _isPaly = YES;
        if(_assistiveDelegate && [_assistiveDelegate respondsToSelector:@selector(musicToPlay)])
        {
            [_assistiveDelegate musicToPlay];
        }
        [_playButton setImage:[UIImage imageNamed:@"player_bt_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_bt_pause_press"] forState:UIControlStateHighlighted];
    }
    
}
//改变位置
-(void)locationChange:(UIPanGestureRecognizer*)p
{
    //[[UIApplication sharedApplication] keyWindow]
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeColor) object:nil];
        _imageView.alpha = 0.8;
    }
    else if (p.state == UIGestureRecognizerStateEnded)
    {
        [self performSelector:@selector(changeColor) withObject:nil afterDelay:4.0];
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        if(panPoint.x <= kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-HEIGHT/2-40 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2);
                }];
            }
            else if (panPoint.x < WIDTH/2+15 && panPoint.y > kScreenHeight-HEIGHT/2)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(WIDTH/2, kScreenHeight-HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y < HEIGHT/2 ? HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(WIDTH/2, pointy);
                }];
            }
        }
        else if(panPoint.x > kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20 )
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-40-HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(panPoint.x, 480-HEIGHT/2);
                }];
            }
            else if (panPoint.x > kScreenWidth-WIDTH/2-15 && panPoint.y < HEIGHT/2)
            {
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2, HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y > kScreenHeight-HEIGHT/2 ? kScreenHeight-HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:0.2 animations:^{
                    self.center = CGPointMake(320-WIDTH/2, pointy);
                }];
            }
        }
    }
}
//点击事件
-(void)click:(UITapGestureRecognizer*)t
{
    _imageView.alpha = 0.8;
    [self performSelector:@selector(changeColor) withObject:nil afterDelay:4.0];
    if(_assistiveDelegate && [_assistiveDelegate respondsToSelector:@selector(assistiveTocuhs)])
    {
        [_assistiveDelegate assistiveTocuhs];
    }
}
-(void)changeColor
{
    [UIView animateWithDuration:2.0 animations:^{
        _imageView.alpha = 0.3;
    }];
}

@end
