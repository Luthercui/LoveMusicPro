//
//  AppDelegate.h
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayView.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,BABAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) NSMutableArray *playList;
@property(nonatomic,strong) PlayView *playView;
@end

