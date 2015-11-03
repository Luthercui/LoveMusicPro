//
//  NetFm.m
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "NetFm.h"
#import <AFNetworking/AFNetworking.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SongInfo.h"
#import "ChannelInfo.h"
#import "SongListModel.h"
#define PLAYLISTURLFORMATSTRING @"http://douban.fm/j/mine/playlist?type=%@&sid=%@&pt=%f&channel=%@&from=mainsite"
#define LOGINURLSTRING @"http://douban.fm/partner/logout"
#define LOGOUTURLSTRING @"http://douban.fm/partner/logout"
#define CAPTCHAIDURLSTRING @"http://douban.fm/j/new_captcha"
#define CAPTCHAIMGURLFORMATSTRING @"http://douban.fm/misc/captcha?size=m&id=%@"
@implementation NetFm


//获取播放列表信息
//type
//n : None. Used for get a song list only.
//e : Ended a song normally.
//u : Unlike a hearted song.
//r : Like a song.
//s : Skip a song.
//b : Trash a song.
//p : Use to get a song list when the song in playlist was all played.
//sid : the song's id
+(void)playBillWithChannelId:(NSString *)channelId
            withType:(NSString *)type
           completionHandler:(void (^)(NSError *error, NSArray *playBills))completionHandler{
    
    NSString *playlistURLString = [NSString stringWithFormat:PLAYLISTURLFORMATSTRING, type, @"", 0.0,channelId];
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:playlistURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *songDictionary = responseObject;
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSDictionary *song in [songDictionary objectForKey:@"song"]) {
            //subtype=T为广告标识位，如果是T，则不加入播放列表(去广告)
            if ([[song objectForKey:@"subtype"] isEqualToString:@"T"]) {
                continue;
            }
            SongInfo *tempSong = [[SongInfo alloc] initWithDictionary:song];
            tempSong.type = 1;
            [dataArray addObject:tempSong];
        }
        if (completionHandler && dataArray.count > 0) {
            completionHandler(nil,dataArray);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(error,nil);
    }];
    
}
+(void)playChannelsChannelId:(NSInteger)cannelIndex
           completionHandler:(void (^)(NSError *error, NSArray *channels))completionHandler{
    NSString *urlWithString = nil;
    if (cannelIndex == 1) {
        urlWithString = @"http://douban.fm/j/explore/get_recommend_chl";
    }
    if (cannelIndex == 2) {
        urlWithString = @"http://douban.fm/j/explore/up_trending_channels";
    }
    if (cannelIndex == 3) {
       urlWithString = @"http://douban.fm/j/explore/hot_channels";
    }
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager GET:urlWithString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *channelsDictionary = responseObject;
        NSDictionary *tempChannel = [channelsDictionary objectForKey:@"data"];
         NSMutableArray *dataArray = [NSMutableArray array];
        if (cannelIndex != 1) {
            for (NSDictionary *channels in [tempChannel objectForKey:@"channels"]) {
                ChannelInfo *channelInfo = [[ChannelInfo alloc]initWithDictionary:channels];
                [dataArray addObject:channelInfo];
            }
        }
        else{

        }
        if (completionHandler&& dataArray.count >0) {
            completionHandler(nil,dataArray);
        }else{
            completionHandler(nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(error,nil);
    }];
}
+(void)getSongInformationWith:(long long)songID
            completionHandler:(void (^)(NSError *error, SongInfo *songInfo))completionHandler{
    NSString *urlWithString = [NSString stringWithFormat:@"http://music.baidu.com/data/music/links?songIds=%lld",songID];
  
    NSURL *url = [NSURL URLWithString:urlWithString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
    
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *vodtask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            completionHandler(error,nil);
        }else{
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
 
            switch ([httpResponse statusCode]) {
                case 200:
                {
                    SongInfo  * song = [SongInfo new];
                    NSDictionary * dictionary = dict;
                    if ([[dictionary allKeys] count]>1) {
                        NSDictionary * data = [dictionary objectForKey:@"data"];
                        NSArray * songList = [data objectForKey:@"songList"];
                        for (NSDictionary * sub in songList) {
                            song.url = [sub objectForKey:@"showLink"];
                            song.title = [sub objectForKey:@"songName"];
                            song.picture = [sub objectForKey:@"songPicBig"];
                            song.length = [[sub objectForKey:@"time"] stringValue];
                            song.artist = [sub objectForKey:@"artistName"];
                            song.sid = [[sub objectForKey:@"songId"]stringValue];
                            song.type = 2;
                        }
                    }else{
                        int errorcode = [[dictionary objectForKey:@"error_code"] intValue];
                        NSLog(@"%d",errorcode);
                    }
                    if (completionHandler&&song.url) {
                        completionHandler(nil,song);
                    }else{
                        completionHandler(nil,nil);
                    }
            
                }
                    break;
                default:{
                    
                    completionHandler(error,nil);
                }
                    break;
            }
        }
    }];
    [vodtask resume];
    
    
    
    
}
+(void)getSongListWith:(NSInteger)type
              withPage:(NSInteger)page
              withPageSize:(NSInteger)pageSize
     completionHandler:(void (^)(NSError *error, NSArray *songListModelArray))completionHandler{
    
    NSString *urlWithString = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?from=ios&version=2.4.0&method=baidu.ting.billboard.billList&format=json&type=%ld&offset=%ld&limits=%ld",(long)type,(long)page,(long)pageSize];
    
    AFHTTPRequestOperationManager *manager =  [AFHTTPRequestOperationManager manager];
    [manager GET:urlWithString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * dictionary = responseObject;
        NSMutableArray *array = [NSMutableArray array];
        if ([[dictionary allKeys] count]>1) {
            NSArray * temp = [dictionary objectForKey:@"song_list"];
            for (NSDictionary * dict in temp) {
                SongListModel * model = [SongListModel new];
                model.artist_id = [[dict objectForKey:@"artist_id"] intValue];
                model.all_artist_ting_uid = [[dict objectForKey:@"all_artist_ting_uid"] intValue];
                model.all_artist_id = [[dict objectForKey:@"all_artist_id"] intValue];
                model.language = [dict objectForKey:@"language"];
                model.publishtime = [dict objectForKey:@"publishtime"];
                model.album_no = [[dict objectForKey:@"album_no"] intValue];
                model.pic_big = [dict objectForKey:@"pic_big"];
                model.pic_small = [dict objectForKey:@"pic_small"];
                model.country = [dict objectForKey:@"country"];
                model.area = [[dict objectForKey:@"area"] intValue];
                model.lrclink = [dict objectForKey:@"lrclink"];
                model.hot = [[dict objectForKey:@"hot"] intValue];
                model.file_duration = [[dict objectForKey:@"file_duration"] intValue];
                model.del_status = [[dict objectForKey:@"del_status"] intValue];
                model.resource_type = [[dict objectForKey:@"resource_type"] intValue];
                model.copy_type = [[dict objectForKey:@"copy_type"] intValue];
                model.relate_status = [[dict objectForKey:@"relate_status"] intValue];
                model.all_rate = [[dict objectForKey:@"all_rate"] intValue];
                model.has_mv_mobile = [[dict objectForKey:@"has_mv_mobile"] intValue];
                model.toneid = [[dict objectForKey:@"toneid"] longLongValue];
                model.song_id = [[dict objectForKey:@"song_id"] longLongValue];
                model.title = [dict objectForKey:@"title"];
                model.ting_uid = [[dict objectForKey:@"ting_uid"] longLongValue];
                model.author = [dict objectForKey:@"author"];
                model.album_id = [[dict objectForKey:@"album_id"] longLongValue];
                model.album_title = [dict objectForKey:@"album_title"];
                model.is_first_publish = [[dict objectForKey:@"is_first_publish"] intValue];
                model.havehigh = [[dict objectForKey:@"havehigh"] intValue];
                model.charge = [[dict objectForKey:@"charge"] intValue];
                model.has_mv = [[dict objectForKey:@"has_mv"] intValue];
                model.learn = [[dict objectForKey:@"learn"] intValue];
                model.piao_id = [[dict objectForKey:@"piao_id"] intValue];
                model.listen_total = [[dict objectForKey:@"listen_total"] longLongValue];
                [array addObject:model];
            }
        }
        if (completionHandler&&array.count>0) {
            completionHandler(nil,array);
        }else{
            completionHandler(nil,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(error,nil);
    }];
}

+(void)getRecommendAlbumCompletionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler{

    NSURL *url = [NSURL URLWithString:@"http://www.zhiyurencai.cn/music/api/recommend"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *vodtask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completionHandler(error,nil);
        }else{
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            switch ([httpResponse statusCode]) {
                case 200:
                {
                    if ([[dict allKeys] count]>1) {
                        NSDictionary * dataArray = dict[@"data"];
                        if (dataArray && [dataArray isKindOfClass:[NSArray class]]) {
                            NSMutableArray *array = [NSMutableArray array];
                            for (NSDictionary * dict in dataArray) {
                                [array addObject:dict];
                            }
                            if (completionHandler&&array.count>0) {
                                completionHandler(nil,array);
                            }else{
                                completionHandler(nil,nil);
                            }
                        }else{
                            completionHandler(nil,nil);
                        }
                    }else{
                         completionHandler(nil,nil);
                    }
        
                    
                }
                    break;
                default:{
                    
                    completionHandler(error,nil);
                }
                    break;
            }
        }
    }];
    [vodtask resume];
}
// http://www.zhiyurencai.cn/music/api/category_album/book/1/20
+(void)getSongAlbumListWithPageSize:(NSInteger)pageSize
                           withPage:(NSInteger)page
                           withType:(NSString*)Type
                  completionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.zhiyurencai.cn/music/api/category_album/%@/%ld/%ld",Type,(long)page,(long)pageSize]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *vodtask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completionHandler(error,nil);
        }else{
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            switch ([httpResponse statusCode]) {
                case 200:
                {
                    if ([[dict allKeys] count]>1) {
                        NSDictionary * dataArray = dict[@"data"];
                        if (dataArray && [dataArray isKindOfClass:[NSArray class]]) {
                            NSMutableArray *array = [NSMutableArray array];
                            for (NSDictionary * dict in dataArray) {
                                [array addObject:dict];
                            }
                            if (completionHandler&&array.count>0) {
                                completionHandler(nil,array);
                            }else{
                                completionHandler(nil,nil);
                            }
                        }else{
                            completionHandler(nil,nil);
                        }
                    }else{
                        completionHandler(nil,nil);
                    }
                    
                    
                }
                    break;
                default:{
                    
                    completionHandler(error,nil);
                }
                    break;
            }
        }
    }];
    [vodtask resume];
}
+(void)getSongTracksWithType:(NSString*)Type
           completionHandler:(void (^)(NSError *error, NSArray *songDicArray))completionHandler{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.zhiyurencai.cn/music/api/tracks/%@/1/100",Type]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0f];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *vodtask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            completionHandler(error,nil);
        }else{
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            switch ([httpResponse statusCode]) {
                case 200:
                {
                    if ([[dict allKeys] count]>1) {
                        NSDictionary * dataArray = dict[@"data"];
                        if (dataArray && [dataArray isKindOfClass:[NSArray class]]) {
                            NSMutableArray *array = [NSMutableArray array];
                            for (NSDictionary * dict in dataArray) {
                                [array addObject:dict];
                            }
                            if (completionHandler&&array.count>0) {
                                completionHandler(nil,array);
                            }else{
                                completionHandler(nil,nil);
                            }
                        }else{
                            completionHandler(nil,nil);
                        }
                    }else{
                        completionHandler(nil,nil);
                    }
                    
                    
                }
                    break;
                default:{
                    
                    completionHandler(error,nil);
                }
                    break;
            }
        }
    }];
    [vodtask resume];
}
@end
