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