//
//  RecommendViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "RecommendViewController.h"
#import "NetFm.h"
#import "SongListModel.h"
#import "SongInfo.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "AppDelegate.h"
#import "Tool.h"
#import "RecommendSongListViewController.h"
#import "RecommendTableViewCell.h"

@interface RecommendViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@end
@implementation RecommendViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"推荐音乐"];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"推荐音乐" image:[UIImage imageNamed:@"icon2"] selectedImage:[UIImage imageNamed:@"icon2"]];
        self.tabBarItem  = tabBarItem;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    self.currentPlayIndex = -1;
    [self addConstraints];
//    [NetFm getRecommendAlbumCompletionHandler:^(NSError *error, NSArray *songListModelArray) {
//        if (songListModelArray) {
//            _dataArray = songListModelArray;
//            __weak typeof(self) weakSelf = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.tableView reloadData];
//            });
//        }
//    }];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    [NetFm getSongListWith:1 withPage:0 completionHandler:^(NSError *error, NSArray *songListModelArray) {
        
        
        if (songListModelArray) {
            [_dataArray addObjectsFromArray:songListModelArray];
            [NetFm getSongListWith:2 withPage:1 completionHandler:^(NSError *error, NSArray *songListModelArray) {
                if (songListModelArray) {
                    [_dataArray addObjectsFromArray:songListModelArray];
                    __weak typeof(self) weakSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_activityIndicatorView stopAnimating];
                        [weakSelf.tableView reloadData];
                        
                    });
                }
            }];

        }else{
            [_activityIndicatorView stopAnimating];
        }
        
    }];
    
}
- (void)addConstraints {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-120-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (!cell) {
        cell = [[RecommendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.title;
    cell.subTitleLabel.text = info.author;
    if (info && info.pic_small) {
        [cell.songImageView setImageWithURL:[NSURL URLWithString:info.pic_small] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
   // cell.textLabel.textColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
    cell.backgroundColor =  [Tool colorWithHexColorString:@"fafafa"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.currentPlayIndex == indexPath.row) {
        
    }else{
        self.currentPlayIndex = indexPath.row;
        [self.tableView reloadData];
        SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
        [NetFm getSongInformationWith:info.song_id completionHandler:^(NSError *error, SongInfo *songInfo) {
            if (songInfo) {
                 AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [SongInfo setCurrentSongIndex:0];
                [SongInfo setCurrentSong:songInfo];
                [delegate.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                [delegate.player play];
                [delegate.playView upDatePlayButton:YES];
                [delegate.playView upDatePlayImage:[SongInfo currentSong].picture];
            }
        }];
    }
}
@end
