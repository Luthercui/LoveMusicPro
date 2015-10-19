//
//  NetFm.h
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

/*
 http://www.zhiyurencai.cn/music/api/recommend
 
 http://www.zhiyurencai.cn/music/api/category
 
 http://www.zhiyurencai.cn/music/api/category_album/music
 
 http://www.zhiyurencai.cn/music/api/tracks/2508
 */

#import <Foundation/Foundation.h>
@class SongInfo;
@class SongListModel;
@interface NetFm : NSObject
+(void)playBillWithChannelId:(NSString *)channelId
                    withType:(NSString *)type
            completionHandler:(void (^)(NSError *error, NSArray *playBills))completionHandler;

+(void)playChannelsChannelId:(NSInteger)cannelIndex
           completionHandler:(void (^)(NSError *error, NSArray *channels))completionHandler;

+(void)getSongInformationWith:(long long)songID
    completionHandler:(void (^)(NSError *error, SongInfo *songInfo))completionHandler;


/*
 type: //1、新歌榜，2、热歌榜，
11、摇滚榜，12、爵士，16、流行
21、欧美金曲榜，22、经典老歌榜，23、情歌对唱榜，24、影视金曲榜，25、网络歌曲榜
 http://www.fddcn.cn/music-api-wang-yi-bai-du.html*/
+(void)getSongListWith:(NSInteger)type
              withPage:(NSInteger)page
            completionHandler:(void (^)(NSError *error, NSArray *songListModelArray))completionHandler;


//////////////////
+(void)getRecommendAlbumCompletionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler;

+(void)getSongRecommendAlbumListWithPageSize:(NSInteger)pageSize
              withPage:(NSInteger)page
     completionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler;

@end
