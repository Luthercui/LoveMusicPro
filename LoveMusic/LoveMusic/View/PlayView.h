//
//  PlayView.h
//  LoveMusic
//
//  Created by tt on 15/10/19.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayView : UIView
-(void)upDatePlayButton:(BOOL)isPlay;
-(void)upDatePlayImage:(NSString*)imageUrl;
-(void)transformRotatePlayImage;
@end