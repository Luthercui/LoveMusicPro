//
//  ClassViewController.m
//  LoveMusic
//
//  Created by tt on 15/11/2.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "ClassViewController.h"
#import "FoundViewController.h"
#import "RecommendSongListViewController.h"
#import "AlbumViewController.h"
@interface ClassViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray   *dataArray;
@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    _dataArray = [[NSArray alloc] initWithObjects:@"热歌榜",@"摇滚榜",@"爵士",@"流行",@"欧美金曲榜",@"经典老歌榜", @"情歌对唱榜", @"网络歌曲榜", @"网络FM",@"有声小说",@"综艺娱乐",@"相声评书",@"情感生活",nil];
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    [self addConstraints];
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
    NSString *info = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = info;

    cell.textLabel.textColor = [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - UITableView Delegate
/*
 type: //1、新歌榜，2、热歌榜，
 11、摇滚榜，12、爵士，16、流行
 21、欧美金曲榜，22、经典老歌榜，23、情歌对唱榜，24、影视金曲榜，25、网络歌曲榜
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
            [recommend setTitle:@"热歌榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:2];
        }
            break;
        case 1:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
            [recommend setTitle:@"摇滚榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:11];
        }
            break;
        case 2:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
            [recommend setTitle:@"爵士"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:12];
        }
            break;
        case 3:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
            [recommend setTitle:@"流行"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:16];
        }
            break;
        case 4:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
             [recommend setTitle:@"欧美金曲榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:21];
        }
            break;
        case 5:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
             [recommend setTitle:@"经典老歌榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:22];
        }
            break;
        case 6:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
             [recommend setTitle:@"情歌对唱榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:23];
        }
            break;
        case 7:
        {
            RecommendSongListViewController *recommend = [[RecommendSongListViewController alloc] init];
             [recommend setTitle:@"网络歌曲榜"];
            [self.navigationController pushViewController:recommend animated:YES];
            [recommend requestSongList:24];
        }
            break;
        case 8:
        {
            FoundViewController *found = [[FoundViewController alloc] init];
            [self.navigationController pushViewController:found animated:YES];
        }
            break;
        case 9:
        {
            AlbumViewController *album = [[AlbumViewController alloc] init];
            [album setTitle:@"有声小说"];
            [self.navigationController pushViewController:album animated:YES];
            [album requestSongList:@"book"];

        }
            break;
        case 10:
        {
            AlbumViewController *album = [[AlbumViewController alloc] init];
            [album setTitle:@"综艺娱乐"];
            [self.navigationController pushViewController:album animated:YES];
            [album requestSongList:@"entertainment"];
            
        }
            break;
        case 11:
        {
            AlbumViewController *album = [[AlbumViewController alloc] init];
             [album setTitle:@"相声评书"];
            [self.navigationController pushViewController:album animated:YES];
            [album requestSongList:@"comic"];
            
        }
            break;
        case 12:
        {
            
            AlbumViewController *album = [[AlbumViewController alloc] init];
            [album setTitle:@"情感生活"];
            [self.navigationController pushViewController:album animated:YES];
            [album requestSongList:@"emotion"];
        }
            break;
        default:
            break;
    }
}

@end
