//
//  SongInfo.h
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongInfo : NSObject
@property int index;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *artist;
@property (nonatomic,copy) NSString *picture;
@property (nonatomic,copy) NSString *length;
@property (nonatomic,copy) NSString *like;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *sid;
@property (nonatomic,assign) NSInteger type;//1 fm //2 百度 //3 自己
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isDownload;

@property (nonatomic,strong)NSMutableArray *dataArray;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype) currentSong;
+ (void)setCurrentSong:(SongInfo *)songInfo;

+ (int) currentSongIndex;
+ (void)setCurrentSongIndex:(int)songIndex;

@end
