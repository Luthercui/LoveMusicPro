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
 
 
 
 http://www.zhiyurencai.cn/music/api/category_album/entertainment/1/20
http://www.zhiyurencai.cn/music/api/category_album/comic/1/20
 http://www.zhiyurencai.cn/music/api/category_album/book/1/20
 
 http://www.zhiyurencai.cn/music/api/tracks/236623/1/20
 
 dict[@"icon"] = @"category_default_img14";
 dict[@"title"] = @"车载电台";
 dict[@"tag"] = @"car";
 [_dataArray addObject:dict];
 
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img1";
 dict[@"title"] = @"有声小说";
 dict[@"tag"] = @"book";
 [_dataArray addObject:dict];
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img2";
 dict[@"title"] = @"音乐";
 dict[@"tag"] = @"music";
 [_dataArray addObject:dict];
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img3";
 dict[@"title"] = @"综艺娱乐";
 dict[@"tag"] = @"entertainment";
 [_dataArray addObject:dict];
 
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img4";
 dict[@"title"] = @"相声评书";
 dict[@"tag"] = @"comic";
 [_dataArray addObject:dict];
 
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img13";
 dict[@"tag"] = @"kid";
 dict[@"title"] = @"儿童";
 [_dataArray addObject:dict];
 
 
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img6";
 dict[@"title"] = @"情感生活";
 dict[@"tag"] = @"emotion";
 [_dataArray addObject:dict];
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img7";
 dict[@"title"] = @"历史人文";
 dict[@"tag"] = @"culture";
 [_dataArray addObject:dict];
 
 dict = [NSMutableDictionary new];
 dict[@"icon"] = @"category_default_img8";
 dict[@"title"] = @"收听历史";
 dict[@"tag"] = @"history";
 [_dataArray addObject:dict];
 
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
          withPageSize:(NSInteger)pageSize
            completionHandler:(void (^)(NSError *error, NSArray *songListModelArray))completionHandler;


//////////////////
+(void)getRecommendAlbumCompletionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler;

+(void)getSongAlbumListWithPageSize:(NSInteger)pageSize
                                    withPage:(NSInteger)page
                                    withType:(NSString*)Type
     completionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler;
+(void)getSongTracksWithType:(NSString*)Type
                  completionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler;

@end
