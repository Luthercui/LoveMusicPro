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


@end
