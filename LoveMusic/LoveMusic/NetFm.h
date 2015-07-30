//
//  NetFm.h
//  LoveMusic
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetFm : NSObject
+(void)playBillWithChannelId:(NSString *)channelId
                    withType:(NSString *)type
            completionHandler:(void (^)(NSError *error, NSArray *playBills))completionHandler;

+(void)playChannelsChannelId:(NSInteger)cannelIndex
           completionHandler:(void (^)(NSError *error, NSArray *channels))completionHandler;
@end
