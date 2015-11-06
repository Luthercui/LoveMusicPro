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
#import "RecommendTableViewCell.h"
@interface AlbumListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,copy) NSString*songSid;
@property (nonatomic ,copy) NSString*imageUrl;
@end

@implementation AlbumListViewController

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
-(void)requestSongList:(NSString*)sid withImageUrl:(NSString *)url{
    self.songSid = sid;
    self.imageUrl = url;
    [_activityIndicatorView startAnimating];
    [NetFm getSongTracksWithType:self.songSid completionHandler:^(NSError *error, NSArray *songDicArray) {
        [self.activityIndicatorView stopAnimating];
        if (songDicArray && songDicArray.count > 0) {
            [self.dataArray addObjectsFromArray:songDicArray];
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
    RecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (!cell) {
        cell = [[RecommendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        //cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = info[@"title"];
    cell.subTitleLabel.text = info[@"nickname"];
    if (self.imageUrl) {
        [cell.songImageView setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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
