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

@interface PlayerViewController ()<DownloadManagerDelegate>{
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

@property(nonatomic,strong)UIImageView *playImageView;

@property(nonatomic,strong)NSString *logMessage;

@property(nonatomic,strong)UIButton *commentButton;

@property( nonatomic,strong)NSString *currentPlaySid;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"就是爱音乐" auditFlag:MS_Audit_Flag];
    
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
    backButton.frame = CGRectMake(15, 30, 12, 21);
    [backButton setImage:[UIImage imageNamed:@"bt_back_press"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    CGAffineTransform at =CGAffineTransformMakeRotation(-M_PI/2);
    [backButton setTransform:at];
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
    [self.backImageView setImage:image];
    
    self.bbar = [[UINavigationBar alloc] init];
    _bbar.frame = CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 80);

    
    [self.view addSubview:nav];
    [self.view addSubview:_bbar];
    

    
    [self addG];
    [self initButton];
    [self fireTimer];
    
    _currentPlaySid = [SongInfo currentSong].sid;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self sdkAdRequestBannerAction];
}

//创建Smtaran横幅广告
-(void)sdkAdRequestBannerAction
{
    if (self.smtaranBanner) {
        self.smtaranBanner.delegate = nil;
        [self.smtaranBanner removeFromSuperview];
        self.smtaranBanner = nil;
    }
    // 设置delegate ,type  slotToken
    // 确保初始化banner前已设置过 publisherID

        //SmtaranBannerAdSizeNormal  iPhone 320X50  iPhone6 375*50 iPhone6 Plus 414*50  iPad 728X90
    self.smtaranBanner = [[SmtaranBannerAd alloc] initBannerAdSize:SmtaranBannerAdSizeNormal delegate:self slotToken:MS_paly_Banner];
    
    //轮播周期
    /*
     SmtaranBannerAdRefreshTimeNone,         //不刷新
     SmtaranBannerAdRefreshTimeHalfMinute,   //30秒刷新
     SmtaranBannerAdRefreshTimeOneMinute,    //60秒刷新
     */
    [self.smtaranBanner  setBannerAdRefreshTime:SmtaranBannerAdRefreshTimeHalfMinute];
    //轮播动画
    /*
     SmtaranBannerAdAnimationTypeNone    = -1,   //无动画
     SmtaranBannerAdAnimationTypeRandom  = 1,    //随机动画
     SmtaranBannerAdAnimationTypeFade    = 2,    //渐隐渐现
     SmtaranBannerAdAnimationTypeCubeT2B = 3,    //立体翻转从左到右
     SmtaranBannerAdAnimationTypeCubeL2R = 4,    //立体翻转从上到下
     */
    [self.smtaranBanner  setBannerAdAnimeType:SmtaranBannerAdAnimationTypeFade];

    self.smtaranBanner.frame = CGRectMake(0, 65, self.view.frame.size.width, 50);//此处的width和height可以是SDK返回的数据
  
    
    [self.view addSubview:self.smtaranBanner];
}

- (void)fireTimer{
    [self invalidateTimer];
    _kTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}
-(void)updateProgress{
    float currentPlayPorgress = [BABAudioPlayer sharedPlayer].timeElapsed/[BABAudioPlayer sharedPlayer].duration;
    float progressw = self.view.frame.size.width*currentPlayPorgress;
    if (!isnan(progressw)) {
        self.playProgress.frame = CGRectMake(0, self.view.frame.size.height-85, progressw, 5);
        [self transformRotatePlayImage];
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
    
    UISwipeGestureRecognizer*downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    downSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.view addGestureRecognizer:downSwipeGestureRecognizer];
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
    
    self.commentButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.frame =CGRectMake(nextx+64+15, (_bbar.frame.size.height-64)/2, 64, 64);
    [_commentButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_commentButton setTitleColor:[UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(commentClickButton) forControlEvents:UIControlEventTouchUpInside];
    [_bbar addSubview:_commentButton];
    
    
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
    
    
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-80)/2, self.view.frame.size.height-85-130, 80, 80)];
    _playImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_playImageView];
    _playImageView.layer.masksToBounds = YES;
    _playImageView.layer.cornerRadius = 80/2.0;
    [self updatePlayImage:[SongInfo currentSong].picture];
    
    if ([SongInfo currentSong].isDownload) {
        [_commentButton setTitle:@"本地" forState:UIControlStateNormal];
    }else{
        [_commentButton setTitle:@"下载" forState:UIControlStateNormal];
    }
}
-(void)play{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (_isPlay) {
        _isPlay = NO;
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateHighlighted];
        [delegate.playView upDatePlayButton:NO];
        [[BABAudioPlayer sharedPlayer] pause];
        [self invalidateTimer];
    }else{
        _isPlay = YES;
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
        [delegate.playView upDatePlayButton:YES];
        [[BABAudioPlayer sharedPlayer] play];
        [self fireTimer];
    }
}
-(void)next{
    [self invalidateTimer];
    [Tool nextPlaySong];
}
-(void)commentClickButton{
    if ([SongInfo currentSong].isDownload) {
        return;
    }
    DownloadModel *model = [[DownloadManager shareDownloadManager] getDownloadModel:[SongInfo currentSong].sid];
    if (model) {
        
    }else{
        [DownloadManager shareDownloadManager].delegate = self;
        [[DownloadManager shareDownloadManager] addDownloadModel];
    }
}
-(void)downloadManagerCompletion{
    [SongInfo currentSong].isDownload = YES;
    [_commentButton setTitle:@"本地" forState:UIControlStateNormal];
}
-(void)updatePlayImage:(NSString*)url{
    if (url && url.length > 0) {
        [_playImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
}
-(void)transformRotatePlayImage{
    if (![_currentPlaySid isEqualToString:[SongInfo currentSong].sid]) {
        _currentPlaySid = [SongInfo currentSong].sid;
        [self updatePlayImage:[SongInfo currentSong].picture];
        _isPlay = YES;
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_highlight"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateHighlighted];
        if ([SongInfo currentSong].isDownload) {
            [_commentButton setTitle:@"本地" forState:UIControlStateNormal];
        }else{
            [_commentButton setTitle:@"下载" forState:UIControlStateNormal];
        }
    }
    self.artistLabel.text = [SongInfo currentSong].artist;
    self.titleLable.text = [SongInfo currentSong].title;
    _playImageView.transform = CGAffineTransformRotate(_playImageView.transform, M_PI / 1440);
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
        [self.backImageView setImage:image];

    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if (currentBackImageIndex == 4) {
            currentBackImageIndex = 0;
        }else{
            currentBackImageIndex++;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentBackImageIndex] forKey:@"backImageIndex"];
        UIImage *image = [UIImage imageNamed:[self.backImageArray objectAtIndex:currentBackImageIndex]];
        [self.backImageView setImage:image];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionDown) {
        [self invalidateTimer];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}
-(void)back{
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - SmtaranBannerAdDelegate
#pragma mark

//横幅广告被点击时,触发此回调方法,用于统计广告点击数
- (void)smtaranBannerAdClick:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerAdClick");
}

//横幅广告成功展示时,触发此回调方法,用于统计广告展示数
- (void)smtaranBannerAdSuccessToShowAd:(SmtaranBannerAd *)adBanner
{
    NSLog(@"smtaranBannerAdSuccessToShowAd");
}

//横幅广告展示失败时,触发此回调方法
- (void)smtaranBannerAdFaildToShowAd:(SmtaranBannerAd *)adBanner withError:(NSError *)error
{
    NSLog(@"smtaranBannerAdFaildToShowAd, error = %@", [error description]);
}

//横幅广告点击后,打开 LandingSite 时,触发此回调方法,请勿释放横幅广告
- (void)smtaranBannerLandingPageShowed:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageShowed");
}

//关闭 LandingSite 回到应用界面时,触发此回调方法
- (void)smtaranBannerLandingPageHided:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageHided");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//    [RACObserve(self.mediaPlayerViewController, currentLogMessage) subscribeNext:^(NSAttributedString *logging) {
//        if (logging) {
//            NSAttributedString *existingString = _playInfoView.attributedText;
//            NSMutableAttributedString *entireLogging = [[NSMutableAttributedString alloc] initWithAttributedString:existingString];
//
//            if (entireLogging) {
//                [entireLogging appendAttributedString:logging];
//
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _playInfoView.attributedText = entireLogging;
//                CGRect rect = CGRectMake(0, _playInfoView.contentSize.height - _playInfoView.frame.size.height, _playInfoView.contentSize.width, _playInfoView.frame.size.height);
//                [_playInfoView scrollRectToVisible:rect animated:YES];
//            });
//        }
//    }];


@end
