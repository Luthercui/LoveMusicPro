//
//  AlbumViewController.m
//  LoveMusic
//
//  Created by tt on 15/11/3.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "AlbumViewController.h"
#import "NetFm.h"
#import "SongListModel.h"
#import "SongInfo.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "AppDelegate.h"
#import "Tool.h"
#import "RecommendTableViewCell.h"
#import "AlbumListViewController.h"
@interface AlbumViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic ,assign) NSInteger page;
@property (nonatomic ,copy) NSString *songtype;

@end

@implementation AlbumViewController

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)requestSongList:(NSString*)type{
    _songtype = type;
    [_activityIndicatorView startAnimating];
    [NetFm getSongAlbumListWithPageSize:100 withPage:_page withType:_songtype completionHandler:^(NSError *error, NSArray *songDicArray) {
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

    cell.textLabel.text = info[@"title"];;
    cell.textLabel.textColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
    cell.backgroundColor =  [Tool colorWithHexColorString:@"fafafa"];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    self.currentPlayIndex = indexPath.row;
    NSDictionary *info = [_dataArray objectAtIndex:indexPath.row];
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
            [Tool showNoNetAlrtView];
            return;
    }
    AlbumListViewController*listController = [[AlbumListViewController alloc] init];
    [listController setTitle:[NSString stringWithFormat:@"%@",info[@"title"]]];
    [self.navigationController pushViewController:listController animated:YES];
    [listController requestSongList:[NSString stringWithFormat:@"%@",info[@"id"]] withImageUrl:info[@"cover_url_142"]];

}

@end
