//
//  SongInfo.m
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "SongInfo.h"

static SongInfo *currentSong;
static int currentSongIndex;

@implementation SongInfo
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.artist = [dictionary objectForKey:@"artist"];
        self.title = [dictionary objectForKey:@"title"];
        self.url = [dictionary objectForKey:@"url"];
        self.picture = [dictionary objectForKey:@"picture"];
        self.length = [dictionary objectForKey:@"length"];
        self.like = [dictionary objectForKey:@"like"];
        self.sid = [dictionary objectForKey:@"sid"];
    }
    return self;
}

+ (instancetype)currentSong{
    if (!currentSong) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            currentSong = [[SongInfo alloc] init];
        });
    }
    return currentSong;
}

+ (void)setCurrentSong:(SongInfo *)songInfo
{
    currentSong = songInfo;
}

+ (int)currentSongIndex{
    return currentSongIndex;
}

+ (void)setCurrentSongIndex:(int)songIndex{
    currentSongIndex = songIndex;
}
@end