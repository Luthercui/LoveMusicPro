//
//  PlayerViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import "SongInfo.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

#import "Tool.h"
#import "NetFm.h"
#import "ChannelInfo.h"
#import <CoreMedia/CoreMedia.h>

@interface PlayerViewController (){
    NSInteger currentBackImageIndex;
}
@property(nonatomic,strong)UIImageView *backImageView;
@property(nonatomic,strong)UINavigationBar *bbar;
@property(nonatomic,strong)NSArray *backImageArray;

@property(nonatomic,strong)UIButton *playButton;
@property(nonatomic,strong)UIButton *nextButton;

@property(nonatomic,strong)UILabel  *playProgress;
@property(nonatomic, strong) NSTimer *kTimer;

@property(nonatomic,assign)BOOL isPlay;

@property(nonatomic,strong)UILabel *artistLabel;
@property(nonatomic,strong)UILabel *titleLable;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isPlay = YES;
    NSNumber *currenNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"backImageIndex"];
    if (currenNumber) {
       currentBackImageIndex = [currenNumber integerValue];
    }else{
        currentBackImageIndex = 0;
    }
    self.backImageArray = [NSArray arrayWithObjects:@"player_backimage1",@"player_backimage2",@"player_backimage3",@"player_backimage4",@"player_backimage5", nil];
    UINavigationBar *nav = [[UINavigationBar alloc] init];
    nav.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [nav addSubview:backButton];
    
    self.titleLable = [[UILabel alloc] init];
    _titleLable.backgroundColor = [UIColor clearColor];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.textColor = [UIColor blackColor];
    _titleLable.text = [SongInfo currentSong].title;
    _titleLable.frame = CGRectMake(50, 20, self.view.frame.size.width-100, 44);
    [nav addSubview:_titleLable];
    
    self.backImageView = [[UIImageView alloc] init];
    _backImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_backImageView];
    UIImage *image = [UIImage imageNamed:[self.backImageArray objectAtIndex:currentBackImageIndex]];
    [self.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.3]];
//     __weak typeof(self) weakSelf = self;
//    if ([SongInfo currentSong].picture && [SongInfo currentSong].picture.length >3) {
//        [_backImageView setImageWithURL:[NSURL URLWithString:[SongInfo currentSong].picture] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if (image) {
//                [weakSelf.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.3]];
//            }
//            
//        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    }

    
    self.bbar = [[UINavigationBar alloc] init];
    _bbar.frame = CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 80);

    
    [self.view addSubview:nav];
    [self.view addSubview:_bbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateTitle) name:@"PlayerViewUpdate" object:nil];
    
    [self addG];
    [self initButton];
    [self fireTimer];
}
- (void)fireTimer{
    [self invalidateTimer];
    _kTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}
-(void)updateProgress{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    float currentPlayPorgress = delegate.player.currentPlaybackTime/delegate.player.duration;
    float progressw = self.view.frame.size.width*currentPlayPorgress;
    if (!isnan(progressw)) {
        self.playProgress.frame = CGRectMake(0, self.view.frame.size.height-85, progressw, 5);
    }
}
- (void)invalidateTimer {
    if (_kTimer) {
        [_kTimer invalidate];
        _kTimer = nil;
    }
}
-(void)addG{
    UISwipeGestureRecognizer*leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer*rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
}
-(void)initButton{
    self.playButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame =CGRectMake((_bbar.frame.size.width/2-64)/2, (_bbar.frame.size.height-64)/2, 64, 64);
    [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
    
//    [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
//    [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
    
    [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [_bbar addSubview:_playButton];
    
    
    float nextx = (_bbar.frame.size.width/2 -_playButton.frame.origin.x -64)/2;
    nextx += (_playButton.frame.origin.x +  _playButton.frame.size.width);
    
    self.nextButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton.frame =CGRectMake(nextx, (_bbar.frame.size.height-64)/2, 64, 64);
    [_nextButton setImage:[UIImage imageNamed:@"player_btn_next_highlight"] forState:UIControlStateNormal];
    [_nextButton setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateHighlighted];
    
    [_nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [_bbar addSubview:_nextButton];
    
    
    self.playProgress = [[UILabel alloc] initWithFrame:CGRectZero];
    _playProgress.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
    [self.view addSubview:_playProgress];
    
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-85-50, self.view.frame.size.width, 50)];
    _artistLabel.backgroundColor = [UIColor clearColor];
    _artistLabel.textAlignment = NSTextAlignmentCenter;
    _artistLabel.font = [UIFont systemFontOfSize:18];
    _artistLabel.textColor = [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
    _artistLabel.text = [SongInfo currentSong].artist;
    [self.view addSubview:_artistLabel];
    
}
-(void)play{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (_isPlay) {
        _isPlay = NO;
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
        [delegate.assistiveTouch upDatePlayButton:YES];
        [delegate.player pause];
    }else{
        _isPlay = YES;
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
        [delegate.assistiveTouch upDatePlayButton:NO];
        [delegate.player play];
    }
}
-(void)next{
    ChannelInfo *info = [ChannelInfo currentChannel];
    if (info) {
        [NetFm playBillWithChannelId:info.ID withType:@"n" completionHandler:^(NSError *error, NSArray *playBills) {
            if (playBills) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate.playList removeAllObjects];
                    [delegate.playList addObjectsFromArray:playBills];
                    if ([delegate.playList count] != 0) {
                        [SongInfo setCurrentSongIndex:0];
                        [SongInfo setCurrentSong:[delegate.playList objectAtIndex:[SongInfo currentSongIndex]]];
                        [delegate.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                        [delegate.player play];
                        [delegate.assistiveTouch upDatePlayButton:YES];
                        [delegate.assistiveTouch upDatePlayImage:[SongInfo currentSong].picture];
                        
                        
                        weakSelf.artistLabel.text = [SongInfo currentSong].artist;
                        weakSelf.titleLable.text = [SongInfo currentSong].title;
                        
                    }
                });
            }
        }];
    }

}
-(void)upDateTitle{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.artistLabel.text = [SongInfo currentSong].artist;
        weakSelf.titleLable.text = [SongInfo currentSong].title;
    });
}
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (currentBackImageIndex == 0) {
            currentBackImageIndex = 4;
        }else{
            currentBackImageIndex--;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentBackImageIndex] forKey:@"backImageIndex"];
        UIImage *image = [UIImage imageNamed:[self.backImageArray objectAtIndex:currentBackImageIndex]];
        [self.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.3]];

    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if (currentBackImageIndex == 4) {
            currentBackImageIndex = 0;
        }else{
            currentBackImageIndex++;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentBackImageIndex] forKey:@"backImageIndex"];
        UIImage *image = [UIImage imageNamed:[self.backImageArray objectAtIndex:currentBackImageIndex]];
        [self.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.3]];
    }
}
-(void)back{
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:^{
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        delegate.assistiveTouch.hidden = NO;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
