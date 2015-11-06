//
//  AlbumListViewController.m
//  LoveMusic
//
//  Created by tt on 15/11/3.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "AlbumListViewController.h"
#import "NetFm.h"
#import "SongListModel.h"
#import "SongInfo.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "AppDelegate.h"
#import "Tool.h"
#import "AlbumTableViewCell.h"
@interface AlbumListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic ,assign) NSInteger page;
@end

@implementation AlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_press"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    _page = 1;
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

    
    WS(ws);
    [self.tableView addPullToRefreshWithActionHandler:^{
        ws.page = 1;
        [ws requestSong];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        ws.page ++;
        
        [ws requestSong];
        
        
    }];
    
    [self.activityIndicatorView startAnimating];
    [self requestSong];
    
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateLoading];
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateStopped];
    self.tableView.pullToRefreshView.arrowColor =  [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)requestSong{
    
    
    if (1 == self.page) {
        self.dataArray = nil;
        [self.tableView reloadData];
    }
    WS(ws);
    [NetFm getSongTracksWithType:self.songSid withPage:self.page completionHandler:^(NSError *error, NSArray *songDicArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.activityIndicatorView stopAnimating];
            [ws.tableView.pullToRefreshView stopAnimating];
            [ws.tableView.infiniteScrollingView stopAnimating];
            
        });
        
        if (songDicArray == nil) {
            
            return ;
        }
        
        if (songDicArray.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [TSMessage showNotificationWithTitle:nil
                                            subtitle:NoMoreData
                                                type:TSMessageNotificationTypeMessage];
                
            });
            return;
        }
        
        NSMutableArray *newalbums = nil;
        NSMutableArray *arrCells=[NSMutableArray array];
        if (1 == ws.page) {
            newalbums = [NSMutableArray arrayWithArray:songDicArray];;
        }
        else
        {
            newalbums = [NSMutableArray arrayWithArray:ws.dataArray];
            
            NSUInteger count = ws.dataArray.count;
            for (NSDictionary *moreDict in songDicArray) {
                [arrCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [newalbums insertObject:moreDict atIndex:count++];
            }
        }
        
        ws.dataArray = newalbums;
        
        if (1 == ws.page) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationAutomatic];
                
            });
        }
    }];

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
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (!cell) {
        cell = [[AlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        //cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = info[@"title"];
    cell.subTitleLabel.text = info[@"nickname"];
    cell.backgroundColor =  [Tool colorWithHexColorString:@"fafafa"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.currentPlayIndex == indexPath.row) {
        if ([SongInfo currentSong].type != 3) {
            NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];
            SongInfo  * song = [SongInfo new];
            song.url = [info objectForKey:@"play_path_64"];
            song.title = [info objectForKey:@"title"];
            song.picture = self.imageUrl;
            song.length = [info objectForKey:@"duration"];
            song.artist = [info objectForKey:@"nickname"];
            song.sid = [info objectForKey:@"id"];
            song.type = 3;
            song.dataArray = self.dataArray;
            [SongInfo setCurrentSongIndex:0];
            [SongInfo setCurrentSong:song];
            
            [Tool toPlaySong];
        }
    }else{
        self.currentPlayIndex = indexPath.row;
        NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];    
        SongInfo  * song = [SongInfo new];
        song.url = [info objectForKey:@"play_path_64"];
        song.title = [info objectForKey:@"title"];
        song.picture = self.imageUrl;
        song.length = [info objectForKey:@"duration"];
        song.artist = [info objectForKey:@"nickname"];
        song.sid = [info objectForKey:@"id"];
        song.type = 3;
        song.dataArray = self.dataArray;
        [SongInfo setCurrentSongIndex:0];
        [SongInfo setCurrentSong:song];
        
        [Tool toPlaySong];

    }
}

@end
