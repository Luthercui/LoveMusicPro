//
//  AlbumListViewController.h
//  LoveMusic
//
//  Created by tt on 15/11/3.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumListViewController : UIViewController
-(void)requestSongList:(NSString*)sid withImageUrl:(NSString*)url;
@end
