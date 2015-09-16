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
@interface RecommendViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSArray   *dataArray;
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
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    self.currentPlayIndex = -1;
    [self addConstraints];
    [NetFm getSongListWith:1 withPage:0 completionHandler:^(NSError *error, NSArray *songListModelArray) {
        if (songListModelArray) {
            _dataArray = songListModelArray;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
}
- (void)addConstraints {
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
}
+(UIColor *)colorWithHexColorString:(NSString *)hexColorString{
    if ([hexColorString length] <6){//长度不合法
        return [UIColor blackColor];
    }
    NSString *tempString=[hexColorString lowercaseString];
    if ([tempString hasPrefix:@"0x"]){//检查开头是0x
        tempString = [tempString substringFromIndex:2];
    }else if ([tempString hasPrefix:@"#"]){//检查开头是#
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] !=6){
        return [UIColor blackColor];
    }
    //分解三种颜色的值
    NSRange range;
    range.location =0;
    range.length =2;
    NSString *rString = [tempString substringWithRange:range];
    range.location =2;
    NSString *gString = [tempString substringWithRange:range];
    range.location =4;
    NSString *bString = [tempString substringWithRange:range];
    //取三种颜色值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString]scanHexInt:&r];
    [[NSScanner scannerWithString:gString]scanHexInt:&g];
    [[NSScanner scannerWithString:bString]scanHexInt:&b];
    return [UIColor colorWithRed:((float) r /255.0f)
                           green:((float) g /255.0f)
                            blue:((float) b /255.0f)
                           alpha:1.0f];
}
+ (NSString *)totalTimeText:(CGFloat)totalTime{
    
    int time = (int)floor(totalTime);
    int munites = time %3600 /60;
    int second = time%3600%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", munites, second];
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
    SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@               %@",info.title,info.author];
    if (info.pic_small) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:info.pic_small] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    if (self.currentPlayIndex == indexPath.row) {
        cell.textLabel.textColor = [UIColor colorWithRed:8.0/255.0 green:129.0/255.0 blue:181.0/255.0 alpha:1.0];
        cell.backgroundColor =  [[self class] colorWithHexColorString:@"f5f5f5"];
    }else{;
        cell.textLabel.textColor = [UIColor colorWithRed:35.0/255.0 green:199.0/255.0 blue:125.0/255.0 alpha:1.0];
        cell.backgroundColor =  [[self class] colorWithHexColorString:@"fafafa"];
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
        SongListModel *info = [_dataArray objectAtIndex:indexPath.row];
        [NetFm getSongInformationWith:info.song_id completionHandler:^(NSError *error, SongInfo *songInfo) {
            if (songInfo) {
                 AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [SongInfo setCurrentSongIndex:0];
                [SongInfo setCurrentSong:songInfo];
                [delegate.player setContentURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                [delegate.player play];
                [delegate.assistiveTouch upDatePlayButton:YES];
                [delegate.assistiveTouch upDatePlayImage:[SongInfo currentSong].picture];
            }
        }];
        [self.tableView reloadData];
    }
}
@end
