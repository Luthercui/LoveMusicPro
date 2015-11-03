//
//  RecommendSongListViewController.m
//  LoveMusic
//
//  Created by tt on 15/10/19.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "RecommendSongListViewController.h"
#import "NetFm.h"
#import "SongListModel.h"
#import "SongInfo.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "AppDelegate.h"
#import "Tool.h"
#import "RecommendTableViewCell.h"
@interface RecommendSongListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,assign) NSInteger songtype;

@end

@implementation RecommendSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_press"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    _page = 0;
    _dataArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicatorView];
    
     self.currentPlayIndex = -1;
    [self addConstraints];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addConstraints{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)updateList{
//
//    [NetFm getSongListWith:_songtype withPage:_page withPageSize:20 completionHandler:^(NSError *error, NSArray *songListModelArray) {
//        
//        NSMutableArray *newTracks = nil;
//        NSMutableArray *arrCells=[NSMutableArray array];
//        if (songListModelArray && songListModelArray.count > 0) {
//            newTracks = [NSMutableArray arrayWithArray:self.dataArray];
//            
//            NSUInteger count = self.dataArray.count;
//            for (NSDictionary *moreDict in songListModelArray) {
//                [arrCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
//                [newTracks insertObject:moreDict atIndex:count++];
//            }
//            __weak typeof(self) weakSelf = self;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                  [weakSelf.tableView.infiniteScrollingView stopAnimating];
//                      [weakSelf.tableView insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationAutomatic];
//                
//            });
//            
//        }
//        
//    }];
//    
//}
-(void)requestSongList:(NSInteger)type{
    _songtype = type;
    [_activityIndicatorView startAnimating];
    
    [NetFm getSongListWith:type withPage:_page withPageSize:100 completionHandler:^(NSError *error, NSArray *songListModelArray) {
        
        
        if (songListModelArray && songListModelArray.count > 0) {
            [_dataArray addObjectsFromArray:songListModelArray];

            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicatorView stopAnimating];
                [weakSelf.tableView reloadData];
                
            });
            
        }else{
            [_activityIndicatorView stopAnimating];
        }
        
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
        SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
        if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
            [Tool showNoNetAlrtView];
            return;
        }
        
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
