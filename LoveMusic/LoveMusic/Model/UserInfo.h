//
//  UserInfo.h
//  LoveMusic
//
//  Created by le_cui on 15/8/1.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *userIcon;

+ (instancetype)currentUser;
@end
