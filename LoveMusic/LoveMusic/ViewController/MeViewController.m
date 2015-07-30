//
//  MeViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "MeViewController.h"

@implementation MeViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"我的"];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"icon3"] selectedImage:[UIImage imageNamed:@"icon3"]];
        self.tabBarItem  = tabBarItem;
        
        
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
}

@end
