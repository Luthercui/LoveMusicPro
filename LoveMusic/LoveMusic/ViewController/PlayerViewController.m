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

@interface PlayerViewController ()
@property(nonatomic,strong)UIImageView *backImageView;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationBar *nav = [[UINavigationBar alloc] init];
    nav.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [nav addSubview:backButton];
    
    UILabel *title = [[UILabel alloc] init];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor blackColor];
    title.text = [SongInfo currentSong].title;
    title.frame = CGRectMake(50, 20, self.view.frame.size.width-100, 44);
    [nav addSubview:title];
    
    self.backImageView = [[UIImageView alloc] init];
    _backImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_backImageView];
    UIImage *image = [UIImage imageNamed:@"player_backimage1"];
    [self.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.4]];
//     __weak typeof(self) weakSelf = self;
//    if ([SongInfo currentSong].picture && [SongInfo currentSong].picture.length >3) {
//        [_backImageView setImageWithURL:[NSURL URLWithString:[SongInfo currentSong].picture] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if (image) {
//                [weakSelf.backImageView setImage:[Tool blurryImage:image withBlurLevel:0.3]];
//            }
//            
//        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    }

    
    [self.view addSubview:nav];
}
-(void)back{
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
