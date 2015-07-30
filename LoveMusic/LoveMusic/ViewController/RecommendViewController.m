//
//  RecommendViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "RecommendViewController.h"

@implementation RecommendViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"推荐音乐"];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"推荐音乐" image:[UIImage imageNamed:@"icon2"] selectedImage:[UIImage imageNamed:@"icon2"]];
        self.tabBarItem  = tabBarItem;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}
@end
