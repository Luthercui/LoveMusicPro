//
//  Tool.m
//  LoveMusic
//
//  Created by le_cui on 15/7/31.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+(UIColor *)colorWithHexColorString:(NSString *)hexColorString{
    if ([hexColorString length] <6){//长度不合法
        return [UIColor blackColor];
    }
    NSString *tempString=[hexColorString lowercaseString];
    if ([tempString hasPrefix:@"0x"]){//检查开头是0x
        tempString = [tempString substringFromIndex:2];
    }else if ([tempString hasPrefix:@"#"]){//检查开头是#
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] !=6){
        return [UIColor blackColor];
    }
    //分解三种颜色的值
    NSRange range;
    range.location =0;
    range.length =2;
    NSString *rString = [tempString substringWithRange:range];
    range.location =2;
    NSString *gString = [tempString substringWithRange:range];
    range.location =4;
    NSString *bString = [tempString substringWithRange:range];
    //取三种颜色值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString]scanHexInt:&r];
    [[NSScanner scannerWithString:gString]scanHexInt:&g];
    [[NSScanner scannerWithString:bString]scanHexInt:&b];
    return [UIColor colorWithRed:((float) r /255.0f)
                           green:((float) g /255.0f)
                            blue:((float) b /255.0f)
                           alpha:1.0f];
}
+ (NSString *)totalTimeText:(CGFloat)totalTime{
    
    int time = (int)floor(totalTime);
    int munites = time %3600 /60;
    int second = time%3600%60;
    
    return [NSString stringWithFormat:@"%02d:%02d", munites, second];
}

+(void)ImageHandleWithImageView:(UIImageView *)imageView andImageName:(NSString *)imageName
{
    [imageView setImage:[UIImage imageNamed:imageName]];
    imageView.layer.cornerRadius=90;
    imageView.layer.borderWidth=10.0;
    imageView.layer.borderColor=[UIColor  blackColor].CGColor;
    imageView.clipsToBounds=YES;
}
+(UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}
+(NSAttributedString *)attributeStringWithTypeName:(NSString *)name message:(NSString *)message time:(NSString*)time {
    NSMutableAttributedString *logging = [[NSMutableAttributedString alloc] initWithString:name attributes: @{NSForegroundColorAttributeName: [UIColor blueColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:10.f]}];
    NSString *extra = [NSString stringWithFormat:@"[%@]-%@\n", message, time];
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:extra attributes: @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName : [UIFont italicSystemFontOfSize:10.f]}];
    [logging appendAttributedString:attributedMessage];
    return logging;
}
+(void)showNoNetAlrtView{
    UIAlertView *arertView = [[UIAlertView alloc] initWithTitle:@"" message:@"无网络连接，请检查网络" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [arertView show];
}
+(void)toPlaySong{
    [[BABAudioPlayer sharedPlayer] stop];
    BABAudioItem *item = [[BABAudioItem alloc] initWithURL:[NSURL URLWithString:[SongInfo currentSong].url]];
    item.title = [SongInfo currentSong].title;
    [[BABAudioPlayer sharedPlayer] queueItem:item];
    [[BABAudioPlayer sharedPlayer] play];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //歌曲名称
    [dict setObject:[SongInfo currentSong].title forKey:MPMediaItemPropertyTitle];
    //设置锁屏状态下屏幕显示播放音乐信息
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

+(void)nextPlaySong{
    switch ([SongInfo currentSong].type) {
        case 1:
        {
            ChannelInfo *info = [ChannelInfo currentChannel];
            if (info) {
                [NetFm playBillWithChannelId:info.ID withType:@"n" completionHandler:^(NSError *error, NSArray *playBills) {
                    if (playBills) {
                        if ([playBills count] != 0) {
                            [SongInfo setCurrentSongIndex:0];
                            [SongInfo setCurrentSong:[playBills objectAtIndex:[SongInfo currentSongIndex]]];
                            [Tool toPlaySong];
                            dispatch_async(dispatch_get_main_queue(), ^{
            
                                [Tool toPlaySong];
                                
                            });
                        }
                    }
                }];
            }
            
        }
            break;
        case 2:
        {
            for (int i = 0 ; i < [SongInfo currentSong].dataArray.count; i++) {
                SongListModel *info = [[SongInfo currentSong].dataArray objectAtIndex:i];
                if ([[SongInfo currentSong].sid isEqualToString:[NSString stringWithFormat:@"%lld",info.song_id]]) {
                    SongListModel *infoDic = nil;
                    if (i+1 == [SongInfo currentSong].dataArray.count) {
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:0];
                    }else{
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:i+1];
                    }
                    [NetFm getSongInformationWith:infoDic.song_id completionHandler:^(NSError *error, SongInfo *songInfo) {
                        if (songInfo) {
                            [SongInfo setCurrentSongIndex:0];
                            [SongInfo setCurrentSong:songInfo];
                            [Tool toPlaySong];
                        }
                    }];
                    break;
                }
            }
            
        }
            break;
        case 3:
        {
            for (int i = 0 ; i < [SongInfo currentSong].dataArray.count; i++) {
                NSDictionary *dic = [[SongInfo currentSong].dataArray objectAtIndex:i];
                if ([[SongInfo currentSong].sid isEqualToString:dic[@"id"]]) {
                    NSDictionary *infoDic = nil;
                    if (i+1 == [SongInfo currentSong].dataArray.count) {
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:0];
                    }else{
                        infoDic = [[SongInfo currentSong].dataArray objectAtIndex:i+1];
                    }
                    SongInfo  * song = [SongInfo new];
                    song.url = [infoDic objectForKey:@"play_path_64"];
                    song.title = [infoDic objectForKey:@"title"];
                    song.length = [infoDic objectForKey:@"duration"];
                    song.artist = [infoDic objectForKey:@"nickname"];
                    song.sid = [infoDic objectForKey:@"id"];
                    song.picture = [SongInfo currentSong].picture;
                    song.type = 3;
                    song.dataArray = [SongInfo currentSong].dataArray;
                    [SongInfo setCurrentSongIndex:0];
                    [SongInfo setCurrentSong:song];
                    BABAudioItem *item = [[BABAudioItem alloc] initWithURL:[NSURL URLWithString:[SongInfo currentSong].url]];
                    item.title = [SongInfo currentSong].title;
                    [Tool toPlaySong];
                    
                    break;
                }
            }
            
            
        }
            break;
        default:
            break;
    }
}

@end
