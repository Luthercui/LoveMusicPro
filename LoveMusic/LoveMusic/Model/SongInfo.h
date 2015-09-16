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
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *picture;
@property (nonatomic) NSString *length;
@property (nonatomic) NSString *like;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *sid;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

+ (instancetype) currentSong;
+ (void)setCurrentSong:(SongInfo *)songInfo;

+ (int) currentSongIndex;
+ (void)setCurrentSongIndex:(int)songIndex;

@end
