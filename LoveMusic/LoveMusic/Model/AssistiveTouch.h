//
//  AssistiveTouch.h
//  navTest
//
//
//  Created by le_cui on 15/7/30.
//  Copyright (c) 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AssistiveTouchDelegate;
@interface AssistiveTouch : UIWindow
{
    UIView *_imageView;
    UIButton *_playButton;
    BOOL  _isPaly;
    UIImageView *_palyImageView;
}
@property(nonatomic,assign)BOOL isShowMenu;
@property(nonatomic,unsafe_unretained)id<AssistiveTouchDelegate> assistiveDelegate;
-(id)initWithFrame:(CGRect)frame;
-(void)upDatePlayButton:(BOOL)isPlay;
-(void)upDatePlayImage:(NSString*)imageUrl;
-(void)transformRotatePlayImage;
@end

@protocol AssistiveTouchDelegate <NSObject>
@optional

-(void)assistiveTocuhs;
-(void)musicToPlay;
-(void)musicToPause;
-(void)musicToNext;
@end
