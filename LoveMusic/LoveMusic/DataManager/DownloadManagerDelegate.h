//
//  DownloadManagerDelegate.h
//  LoveMusic
//
//  Created by tt on 15/11/5.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadManagerDelegate <NSObject>
@optional
-(void)downloadManagerCompletion;
@end
