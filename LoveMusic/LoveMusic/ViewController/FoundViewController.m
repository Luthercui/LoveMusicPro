//
//  FoundViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "FoundViewController.h"
#import "NetFm.h"
#import "ChannelInfo.h"
#import "AppDelegate.h"
#import "SongInfo.h"
#import "Tool.h"
@interface FoundViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@end


@implementation FoundViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"网络FM"];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt_back_press"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
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
    [self requestFm];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)requestFm{
    [_activityIndicatorView startAnimating];
    [NetFm playChannelsChannelId:3 completionHandler:^(NSError *error, NSArray *channels) {
        if (channels) {
            _dataArray = channels;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
        [_activityIndicatorView stopAnimating];
    }];
}
- (void)addConstraints {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-50-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}
- (void)updateViewConstraints {
    [super updateViewConstraints];
}
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
    ChannelInfo *info = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = info.name;
    cell.textLabel.textColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
    cell.backgroundColor =  [Tool colorWithHexColorString:@"fafafa"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.currentPlayIndex == indexPath.row) {
        
    }else{
        self.currentPlayIndex = indexPath.row;
        ChannelInfo *info = [_dataArray objectAtIndex:indexPath.row];
        [ChannelInfo updateCurrentCannel:info];
        if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
            [Tool showNoNetAlrtView];
            return;
        }
        [NetFm playBillWithChannelId:info.ID withType:@"n" completionHandler:^(NSError *error, NSArray *playBills) {
            if (playBills) {
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegate.playList removeAllObjects];
                [delegate.playList addObjectsFromArray:playBills];
                if ([delegate.playList count] != 0) {
                    [SongInfo setCurrentSongIndex:0];
                    [SongInfo setCurrentSong:[delegate.playList objectAtIndex:[SongInfo currentSongIndex]]];
     
                   [Tool toPlaySong];
                }
            }
        }];
    }
}

@end
