//
//  AppDelegate.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "RecommendViewController.h"
#import "FoundViewController.h"
#import "MeViewController.h"
#import "NetFm.h"
#import "ChannelInfo.h"
#import "SongInfo.h"
#import "PlayerViewController.h"
#import "BaseNavigationController.h"
#import "ClassViewController.h"
#import "XHTwitterPaggingViewer.h"

#import "PlayView.h"

@interface AppDelegate ()<PlayTouchDelegate>{
    UITabBarController *tabBarController;
    XHTwitterPaggingViewer *twitterPaggingViewer;
}
@property(nonatomic, strong) NSTimer *kTimer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    twitterPaggingViewer = [[XHTwitterPaggingViewer alloc] init];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:7];
    NSArray *titles = @[@"推荐音乐", @"分类音乐", @"我的"];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case 0:
            {
                RecommendViewController *recommendVc = [[RecommendViewController alloc] init];
                recommendVc.title = title;
                [viewControllers addObject:recommendVc];
            }
                break;
            case 1:
            {
                ClassViewController *foundVc = [[ClassViewController alloc] init];
                foundVc.title = title;
                [viewControllers addObject:foundVc];
            }
                break;
            case 2:
            {
                MeViewController *meVc = [[MeViewController alloc] init];
                meVc.title = title;
                [viewControllers addObject:meVc];
            }
                break;
                
            default:
                break;
        }
    }];
    twitterPaggingViewer.viewControllers = viewControllers;
    twitterPaggingViewer.didChangedPageCompleted = ^(NSInteger cuurentPage, NSString *title) {
        // NSLog(@"cuurentPage : %ld on title : %@", (long)cuurentPage, title);
    };
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:twitterPaggingViewer];
    
    [self initLib];
    [self initplayer];
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)initLib{
    [MobClick startWithAppkey:@"56388066e0f55ae3da001336" reportPolicy:BATCH channelId:@"App Store"];
}
-(void)initplayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _player = [[MPMoviePlayerController alloc]init];
        _playList = [NSMutableArray array];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(moviePlayerPreloadFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:_player];
        [notificationCenter addObserver:self selector:@selector(moviePlayerPlaybackStateDidChangeNotification:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_player];

        
        //后台播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
    });
    _playView = [[PlayView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-55,  [UIScreen mainScreen].bounds.size.width, 55)];
    _playView.playDelegate = self;
    [twitterPaggingViewer.navigationController.view addSubview:_playView];
    [twitterPaggingViewer.navigationController.view bringSubviewToFront:_playView];
    
}

-(void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification*)not{
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        [self fireTimer];
        [self.playView upDatePlayButton:YES];
        [self configNowPlayingInfoCenter];
    }else{
        [self invalidateTimer];
    }
}

-(void)moviePlayerPreloadFinish{
    switch ([SongInfo currentSong].type) {
        case 1:
        {
            ChannelInfo *info = [ChannelInfo currentChannel];
            if (info) {
                __weak typeof(self) weakSelf = self;
                [NetFm playBillWithChannelId:info.ID withType:@"n" completionHandler:^(NSError *error, NSArray *playBills) {
                    if (playBills) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.playList removeAllObjects];
                            [weakSelf.playList addObjectsFromArray:playBills];
                            if ([weakSelf.playList count] != 0) {
                                [SongInfo setCurrentSongIndex:0];
                                [SongInfo setCurrentSong:[weakSelf.playList objectAtIndex:[SongInfo currentSongIndex]]];
                                [weakSelf.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                                [weakSelf.player play];
                            }
                        });
                        
                    }
                }];
            }
       
        }
            break;
        case 2:
        {

            
        }
            break;
        case 3:
        {
            for (int i = 0 ; i < [SongInfo currentSong].dataArray.count; i++) {
                NSDictionary *dic = [[SongInfo currentSong].dataArray objectAtIndex:i];
                if ([[SongInfo currentSong].sid isEqualToString:dic[@"id"]]) {
                    NSDictionary *infoDic = nil;
                    if (i+1 == [SongInfo currentSong].dataArray.count) {
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:0];
                    }else{
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:i+1];
                    }
                    SongInfo  * song = [SongInfo new];
                    song.url = [infoDic objectForKey:@"play_path_64"];
                    song.title = [infoDic objectForKey:@"title"];
                    song.length = [infoDic objectForKey:@"duration"];
                    song.artist = [infoDic objectForKey:@"nickname"];
                    song.sid = [infoDic objectForKey:@"id"];
                    song.picture = [SongInfo currentSong].picture;
                    song.type = 3;
                    song.dataArray = [SongInfo currentSong].dataArray;
                    [SongInfo setCurrentSongIndex:0];
                    [SongInfo setCurrentSong:song];
                    [self.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                    [self.player play];
                    [self.playView upDatePlayButton:YES];
                    [self.playView upDatePlayImage:[SongInfo currentSong].picture];
                    
                    break;
                }
            }

            
        }
            break;
        default:
            break;
    }
}
-(void)playTocuhs{
    
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        PlayerViewController *viewController = [[PlayerViewController alloc] init];
        viewController.view.backgroundColor = [UIColor whiteColor];
        [twitterPaggingViewer presentViewController:viewController animated:YES completion:^{
        }];
    }
}
-(void)musicToPlay{
    [self.player play];
    [self fireTimer];
}
-(void)musicToPause{
    [self.player pause];
    [self invalidateTimer];
}
-(void)musicToNext{
}
- (void)fireTimer{
    [self invalidateTimer];
    _kTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}
-(void)updateProgress{
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        [self.playView transformRotatePlayImage];
    }
}
- (void)invalidateTimer{
    if (_kTimer) {
        [_kTimer invalidate];
        _kTimer = nil;
    }
}
//设置锁屏状态，显示的歌曲信息
-(void)configNowPlayingInfoCenter{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //歌曲名称
        [dict setObject:[SongInfo currentSong].title forKey:MPMediaItemPropertyTitle];
        //设置锁屏状态下屏幕显示播放音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
