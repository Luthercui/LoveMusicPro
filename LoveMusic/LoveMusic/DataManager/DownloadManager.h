//
//  DownloadManager.h
//  LoveMusic
//
//  Created by tt on 15/11/5.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManagerDelegate.h"
@interface DownloadManager : NSObject
@property(nonatomic,strong)NSMutableArray *downloadArray;
@property(nonatomic,strong)NSMutableArray *allDownloadArray;
@property(nonatomic,copy)NSString *downloadFileId;
+ (instancetype)shareDownloadManager;
-(void)startDownload;
-(void)setupDownload;
-(DownloadModel*)getDownloadModel:(NSString*)sid;
@end
