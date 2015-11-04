//
//  PlayView.h
//  LoveMusic
//
//  Created by tt on 15/10/19.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PlayTouchDelegate;
@interface PlayView : UIView
@property(nonatomic,unsafe_unretained)id<PlayTouchDelegate> playDelegate;
-(void)upDatePlayButton:(BOOL)isPlay;
-(void)transformRotatePlayImage;
-(void)fireTimer;
-(void)invalidateTimer;
@end

@protocol PlayTouchDelegate <NSObject>
@optional

-(void)playTocuhs;
@end