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




static NSString *CellIdentifier = @"Cell";

@interface MeViewController()<UITableViewDataSource,UITableViewDelegate,SlideDeleteCellDelegate>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray   *dataArray;
@property (nonatomic ,assign) NSInteger currentPlayIndex;
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
}

-(void)viewDidLoad{
    [super viewDidLoad];

    
    _dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    

    
    self.currentPlayIndex = -1;
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
    [SongInfo currentSong].isDownload = NO;
    [model MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [_dataArray removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

@end
