//
//  PlayerViewController.h
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmtaranBannerAd.h"
@interface PlayerViewController : UIViewController<SmtaranBannerAdDelegate>
@property (nonatomic,strong) SmtaranBannerAd *smtaranBanner;
@end
