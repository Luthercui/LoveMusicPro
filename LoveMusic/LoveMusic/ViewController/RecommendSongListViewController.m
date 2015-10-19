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
@interface RecommendSongListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation RecommendSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    
     self.currentPlayIndex = -1;
    [self addConstraints];
    
    [NetFm getSongRecommendAlbumListWithPageSize:20 withPage:0 completionHandler:^(NSError *error, NSArray *songDicArray) {
        if (songDicArray && songDicArray.count > 0) {
            _dataArray = songDicArray;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];

}
- (void)addConstraints{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
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
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = info[@"title"];
    cell.detailTextLabel.text = info[@"nickname"];
//    if (info[@"cover_url_142"]) {
//        [cell.imageView setImageWithURL:[NSURL URLWithString:info[@"cover_url_142"]] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    }
    if (self.currentPlayIndex == indexPath.row) {
        cell.textLabel.textColor = [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
        cell.backgroundColor =  [Tool colorWithHexColorString:@"f5f5f5"];
    }else{;
        cell.textLabel.textColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
        cell.backgroundColor =  [Tool colorWithHexColorString:@"fafafa"];
    }
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
        //        SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
        //        [NetFm getSongInformationWith:info.song_id completionHandler:^(NSError *error, SongInfo *songInfo) {
        //            if (songInfo) {
        //                 AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        //                [SongInfo setCurrentSongIndex:0];
        //                [SongInfo setCurrentSong:songInfo];
        //                [delegate.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
        //                [delegate.player play];
        //                [delegate.assistiveTouch upDatePlayButton:YES];
        //                [delegate.assistiveTouch upDatePlayImage:[SongInfo currentSong].picture];
        //            }
        //        }];
        [self.tableView reloadData];
    }
}

@end
