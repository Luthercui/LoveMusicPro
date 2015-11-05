//
//  DownloadModel+CoreDataProperties.h
//  LoveMusic
//
//  Created by tt on 15/11/5.
//  Copyright © 2015年 xiaocui. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *songId;
@property (nullable, nonatomic, retain) NSNumber *downLoad;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *localUrl;

@end

NS_ASSUME_NONNULL_END
