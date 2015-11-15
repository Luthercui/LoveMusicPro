//
//  MeViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "MeViewController.h"
#import "AboutViewController.h"
#import "SlideDeleteCell.h"
#import "HFStretchableTableHeaderView.h"
#import "SmtaranBannerAd.h"



static NSString *CellIdentifier = @"Cell";

@interface MeViewController()<UITableViewDataSource,UITableViewDelegate,SlideDeleteCellDelegate,SmtaranBannerAdDelegate>
@property (nonatomic,strong) SmtaranBannerAd *smtaranBanner;
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
@property (nonatomic, strong) HFStretchableTableHeaderView* stretchableTableHeaderView;
@end

@implementation MeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"设置"];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"icon3"] selectedImage:[UIImage imageNamed:@"icon3"]];
        self.tabBarItem  = tabBarItem;
        
        
    }
    return self;
}
-(void)resetTableViewDataSource{

   [_dataArray removeAllObjects];
   [_dataArray addObjectsFromArray:[DownloadModel MR_findAll]];
   [self.tableView reloadData];
   [self sdkAdRequestBannerAction];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"就是爱音乐" auditFlag:MS_Audit_Flag];
    
    _dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    

    
    self.currentPlayIndex = -1;
    [self addConstraints];
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 400*XA)];
    header.image = [UIImage imageNamed:@"player_backimage1"];
    _stretchableTableHeaderView = [HFStretchableTableHeaderView new];
    [_stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:header];

    
    
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
}

- (void)viewDidLayoutSubviews
{
    [_stretchableTableHeaderView resizeView];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SlideDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SlideDeleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    DownloadModel *model = _dataArray[indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DownloadModel *model = _dataArray[indexPath.row];
    if (![model.songId isEqualToString:[SongInfo currentSong].sid]) {
        SongInfo  * song = [SongInfo new];
        song.url = model.url;
        song.title = model.title;
        song.picture = model.imageUrl;
        song.sid = model.songId;
        song.type = 4;
        song.dataArray = self.dataArray;
        [SongInfo setCurrentSongIndex:0];
        [SongInfo setCurrentSong:song];
        [Tool toPlaySong];
    }
    
}

-(void)slideToDeleteCell:(SlideDeleteCell *)slideDeleteCell{
    NSIndexPath *indexPath = [_tableView indexPathForCell:slideDeleteCell];
    DownloadModel *model = _dataArray[indexPath.row];
    [Tool remove_downloaded_file_path:model.songId];
    [model MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [_dataArray removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//创建Smtaran横幅广告
-(void)sdkAdRequestBannerAction
{
    if (self.smtaranBanner) {
        self.smtaranBanner.delegate = nil;
        [self.smtaranBanner removeFromSuperview];
        self.smtaranBanner = nil;
    }
    // 设置delegate ,type  slotToken
    // 确保初始化banner前已设置过 publisherID
    
    //SmtaranBannerAdSizeNormal  iPhone 320X50  iPhone6 375*50 iPhone6 Plus 414*50  iPad 728X90
    self.smtaranBanner = [[SmtaranBannerAd alloc] initBannerAdSize:SmtaranBannerAdSizeNormal delegate:self slotToken:MS_shezhi_Banner];
    
    //轮播周期
    /*
     SmtaranBannerAdRefreshTimeNone,         //不刷新
     SmtaranBannerAdRefreshTimeHalfMinute,   //30秒刷新
     SmtaranBannerAdRefreshTimeOneMinute,    //60秒刷新
     */
    [self.smtaranBanner  setBannerAdRefreshTime:SmtaranBannerAdRefreshTimeHalfMinute];
    //轮播动画
    /*
     SmtaranBannerAdAnimationTypeNone    = -1,   //无动画
     SmtaranBannerAdAnimationTypeRandom  = 1,    //随机动画
     SmtaranBannerAdAnimationTypeFade    = 2,    //渐隐渐现
     SmtaranBannerAdAnimationTypeCubeT2B = 3,    //立体翻转从左到右
     SmtaranBannerAdAnimationTypeCubeL2R = 4,    //立体翻转从上到下
     */
    [self.smtaranBanner  setBannerAdAnimeType:SmtaranBannerAdAnimationTypeFade];
    
    self.smtaranBanner.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);//此处的width和height可以是SDK返回的数据
    
    
    [self.view addSubview:self.smtaranBanner];
}
#pragma mark - SmtaranBannerAdDelegate
#pragma mark

//横幅广告被点击时,触发此回调方法,用于统计广告点击数
- (void)smtaranBannerAdClick:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerAdClick");
}

//横幅广告成功展示时,触发此回调方法,用于统计广告展示数
- (void)smtaranBannerAdSuccessToShowAd:(SmtaranBannerAd *)adBanner
{
    NSLog(@"smtaranBannerAdSuccessToShowAd");
}

//横幅广告展示失败时,触发此回调方法
- (void)smtaranBannerAdFaildToShowAd:(SmtaranBannerAd *)adBanner withError:(NSError *)error
{
    NSLog(@"smtaranBannerAdFaildToShowAd, error = %@", [error description]);
}

//横幅广告点击后,打开 LandingSite 时,触发此回调方法,请勿释放横幅广告
- (void)smtaranBannerLandingPageShowed:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageShowed");
}

//关闭 LandingSite 回到应用界面时,触发此回调方法
- (void)smtaranBannerLandingPageHided:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageHided");
}
@end
