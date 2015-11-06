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
@property(nonatomic,assign)id<DownloadManagerDelegate>delegate;
+ (instancetype)shareDownloadManager;
-(void)startDownload;
-(void)setupDownload;
-(void)addDownloadModel;
-(DownloadModel*)getDownloadModel:(NSString*)sid;
-(DownloadModel*)getWithAllDownloadModel:(NSString*)sid;
@end
