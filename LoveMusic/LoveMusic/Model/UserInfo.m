//
//  UserInfo.m
//  LoveMusic
//
//  Created by le_cui on 15/8/1.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "UserInfo.h"
static UserInfo *currentUser;
@implementation UserInfo

+ (instancetype)currentUser{
    if (!currentUser) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            currentUser = [[UserInfo alloc] init];
        });
    }
    return currentUser;
}
@end
