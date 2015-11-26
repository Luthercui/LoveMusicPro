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
}
@property(nonatomic, strong) NSTimer *kTimer;
@property(nonatomic, strong) XHTwitterPaggingViewer *twitterPaggingViewer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initLib];
    _playList = [[NSMutableArray alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _twitterPaggingViewer = [[XHTwitterPaggingViewer alloc] init];
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
    self.twitterPaggingViewer.viewControllers = viewControllers;
    WS(ws);
    self.twitterPaggingViewer.didChangedPageCompleted = ^(NSInteger cuurentPage, NSString *title) {
         NSLog(@"cuurentPage : %ld on title : %@", (long)cuurentPage, title);
        if (cuurentPage == 2) {
            MeViewController *meVc =  (MeViewController*)ws.twitterPaggingViewer.viewControllers[cuurentPage];
            [meVc resetTableViewDataSource];
        }
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.twitterPaggingViewer];
    self.window.rootViewController = navigationController;
    [self initplayer];

    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)initLib{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"SongModel.sqlite"];
    [MobClick startWithAppkey:@"56388066e0f55ae3da001336" reportPolicy:BATCH channelId:@"App Store"];
    [[DownloadManager shareDownloadManager] startDownload];
}
-(void)initplayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        BABAudioPlayer *player = [BABAudioPlayer new];
        player.allowsBackgroundAudio = YES;
        [BABAudioPlayer setSharedPlayer:player];
        [BABAudioPlayer sharedPlayer].delegate = self;
        //后台播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
    });
    _playView = [[PlayView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-55,  [UIScreen mainScreen].bounds.size.width, 55)];
    _playView.playDelegate = self;
    [self.twitterPaggingViewer.navigationController.view addSubview:_playView];
    [self.twitterPaggingViewer.navigationController.view bringSubviewToFront:_playView];
    
}
//BABAudioPlayerStateIdle,
//BABAudioPlayerStateBuffering,
//BABAudioPlayerStateWaiting,
//BABAudioPlayerStatePlaying,
//BABAudioPlayerStatePaused,
//BABAudioPlayerStateStopped,
//BABAudioPlayerStateScrubbing
- (void)audioPlayer:(BABAudioPlayer *)player didChangeState:(BABAudioPlayerState)state{
    switch (state) {
        case BABAudioPlayerStatePlaying:
        {
            [self.playView upDatePlayButton:YES];
            [self.playView fireTimer];
        }
            break;
        case BABAudioPlayerStatePaused:
        {

        }
            break;
        case BABAudioPlayerStateWaiting:
        {

            
        }
            break;
        case BABAudioPlayerStateStopped:
        {
            [self.playView upDatePlayButton:NO];
            [self.playView invalidateTimer];
            
        }
            break;
            
        default:
            break;
    }
}
- (void)audioPlayer:(BABAudioPlayer *)player didBeginPlayingAudioItem:(BABAudioItem *)audioItem{
    [self.playView fireTimer];
}
- (void)audioPlayer:(BABAudioPlayer *)player didFinishPlayingAudioItem:(BABAudioItem *)audioItem{
    [self.playView invalidateTimer];
    [Tool nextPlaySong];
}
- (void)audioPlayer:(BABAudioPlayer *)player didLoadMetadata:(NSDictionary *)metadata forAudioItem:(BABAudioItem *)audioItem{
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:metadata];
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            
            break;
        case UIEventSubtypeRemoteControlPlay:
             [self.playView upDatePlayButton:YES];
             [[BABAudioPlayer sharedPlayer] play];
            break;
        case UIEventSubtypeRemoteControlPause:
             [[BABAudioPlayer sharedPlayer] pause];
            [self.playView upDatePlayButton:NO];
            
            break;
        case UIEventSubtypeRemoteControlStop:
             [self.playView upDatePlayButton:NO];
             [[BABAudioPlayer sharedPlayer] stop];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [Tool nextPlaySong];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [Tool nextPlaySong];
            break;
        default:
            break;
        }
    
}

-(void)playTocuhs{
    
    if ([BABAudioPlayer sharedPlayer].state == BABAudioPlayerStatePlaying) {
        PlayerViewController *viewController = [[PlayerViewController alloc] init];
        viewController.view.backgroundColor = [UIColor whiteColor];
        [self.twitterPaggingViewer presentViewController:viewController animated:YES completion:^{
        }];
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
     [MagicalRecord cleanUp];
}

@end
