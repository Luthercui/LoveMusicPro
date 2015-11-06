//
//  Tool.h
//  LoveMusic
//
//  Created by le_cui on 15/7/31.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import "SVPullToRefresh.h"
#define WS(s) __weak typeof (self) s = self

#define NetworkError @"亲，您的手机网络不太顺畅喔～"
#define NoMoreData @"亲，您已经看到最后一条了喔～"
#define ClearCacheMsg @"亲，您的缓存已经清理完成了喔～"
#define NotAllowedPlayError @"亲，您还没有允许移动网络播放喔～"

@interface Tool : NSObject
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

+(NSAttributedString *)attributeStringWithTypeName:(NSString *)name message:(NSString *)message time:(NSString*)time;

+(UIColor *)colorWithHexColorString:(NSString *)hexColorString;

+ (NSString *)totalTimeText:(CGFloat)totalTime;
+(void)showNoNetAlrtView;
+(void)toPlaySong;
+(void)nextPlaySong;
+(NSString *)get_downloaded_file_path:(NSString*)media_name;
+(BOOL)remove_downloaded_file_path:(NSString*)media_name;
@end
NSString* PathForDocumentsResource(NSString* relativePath);