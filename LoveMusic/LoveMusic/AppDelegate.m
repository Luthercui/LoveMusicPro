//
//  AppDelegate.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import <AVFoundation/AVFoundation.h>
#import "RecommendViewController.h"
#import "FoundViewController.h"
#import "MeViewController.h"
#import "NetFm.h"
#import "ChannelInfo.h"
#import "SongInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PlayerViewController.h"


@interface AppDelegate ()<AssistiveTouchDelegate>{
    UITabBarController *tabBarController;
}
@property(nonatomic, strong) NSTimer *kTimer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    RecommendViewController *recommendVc = [[RecommendViewController alloc] init];
    FoundViewController *foundVc = [[FoundViewController alloc] init];
    MeViewController *meVc = [[MeViewController alloc] init];
    UINavigationController *recommend = [[UINavigationController alloc] initWithRootViewController:recommendVc];
    UINavigationController *found = [[UINavigationController alloc] initWithRootViewController:foundVc];
    UINavigationController *me = [[UINavigationController alloc] initWithRootViewController:meVc];
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[recommend,found,me];
    [self.window setRootViewController:tabBarController];
    
    [self initLib];
    [self initplayer];
    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)initLib{
    [MobClick startWithAppkey:@"55af9294e0f55a5ac1001f11" reportPolicy:BATCH channelId:@"App Store"];
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
//    self.assistiveTouch = [[AssistiveTouch alloc] initWithFrame:CGRectMake(0, 200, 90, 50)];
//    self.assistiveTouch.assistiveDelegate = self;
}
-(void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification*)not{

}
-(void)moviePlayerPreloadFinish{
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
                        [weakSelf.assistiveTouch upDatePlayButton:YES];
                        [weakSelf.assistiveTouch upDatePlayImage:[SongInfo currentSong].picture];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerViewUpdate" object:nil];
                    }
                });

            }
        }];
    }
}
-(void)assistiveTocuhs{
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        self.assistiveTouch.hidden = YES;
        PlayerViewController *viewController = [[PlayerViewController alloc] init];
        viewController.view.backgroundColor = [UIColor whiteColor];
        [tabBarController presentViewController:viewController animated:YES completion:^{
        }];
    }
}
-(void)musicToPlay{
    [self.player play];
}
-(void)musicToPause{
    [self.player pause];
}
-(void)musicToNext{
}
- (void)fireTimer {
    [self invalidateTimer];
    _kTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}
-(void)updateProgress{
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        if (!self.assistiveTouch.hidden) {
            [self.assistiveTouch transformRotatePlayImage];
        }
    }
}
- (void)invalidateTimer {
    if (_kTimer) {
        [_kTimer invalidate];
        _kTimer = nil;
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
