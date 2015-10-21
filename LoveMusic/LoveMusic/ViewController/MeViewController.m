//
//  MeViewController.m
//  LoveMusic
//
//  Created by le_cui on 15/7/23.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "MeViewController.h"
#import "AboutViewController.h"

@implementation MeViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"设置"];
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"icon3"] selectedImage:[UIImage imageNamed:@"icon3"]];
        self.tabBarItem  = tabBarItem;
        
        
    }
    return self;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    CFSettingSwitchItem *itemPlay =[CFSettingSwitchItem itemWithIcon:@"" title:@"是否允许3G播放"];
    itemPlay.defaultOn = NO;
    itemPlay.opration_switch = ^(BOOL isON){
        CFLog(@"UISwitch状态改变 %d",isON);
    };
    CFSettingSwitchItem *itemDown =[CFSettingSwitchItem itemWithIcon:@"" title:@"是否允许3G下载"];
    itemDown.defaultOn = NO;
    itemDown.opration_switch = ^(BOOL isON){
        CFLog(@"UISwitch状态改变 %d",isON);
    };
    CFSettingGroup *group1 = [[CFSettingGroup alloc] init];
    group1.items = @[ itemPlay,itemDown];
    
    
    CFSettingIconArrowItem *itemAbout =[CFSettingIconArrowItem itemWithIcon:@"" title:@"关于" destVcClass:[AboutViewController class]];
    CFSettingGroup *group2 = [[CFSettingGroup alloc] init];
    group2.items = @[ itemAbout];
    
    group2.headerHeight = 30;
    group2.footerHeight = 30;
    

    [self.dataList addObject:group1];
    [self.dataList addObject:group2];
    
}

@end
