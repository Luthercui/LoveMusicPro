//
//  SongListModel.m
//  LoveMusic
//
//  Created by le_cui on 15/9/16.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "SongListModel.h"

@implementation SongListModel

@end
@implementation SongList
-(id)init
{
    if (self = [super init]) {
        self.songLists = [NSMutableArray new];
    }
    return self;
}
@end