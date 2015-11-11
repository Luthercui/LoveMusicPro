//
//  DownloadManager.m
//  LoveMusic
//
//  Created by tt on 15/11/5.
//  Copyright © 2015年 xiaocui. All rights reserved.
//

#import "DownloadManager.h"
static DownloadManager *downLoad;
@implementation DownloadManager
+ (instancetype)shareDownloadManager{
    if (!downLoad) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            downLoad = [[DownloadManager alloc] init];
            downLoad.downloadArray = [[NSMutableArray alloc] init];
            downLoad.downloadFileId = nil;
            [downLoad creatMediaDir:@"download"];
        });
    }
    return downLoad;
}
-(DownloadModel*)getWithAllDownloadModel:(NSString*)sid{
    NSArray *downloadArray = [DownloadModel MR_findAll];
    for (DownloadModel *model in downloadArray) {
        if ([model.songId isEqualToString:sid]) {
            return model;
        }
    }
    return nil;
}
-(DownloadModel*)getDownloadModel:(NSString*)sid{
    for (DownloadModel *model in self.downloadArray) {
        if ([model.songId isEqualToString:sid]) {
            return model;
        }
    }
    return nil;
}
-(void)startDownload{
    if (self.downloadArray.count > 0) {
        DownloadModel *model = [self.downloadArray objectAtIndex:0];
        model.downLoad = [NSNumber numberWithInt:2];
        self.downloadFileId = model.songId;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        }];
        [self downloadFile:model.url];
    }
}
-(void)addDownloadModel{
    DownloadModel *model = [DownloadModel MR_createEntity];
    model.url = [SongInfo currentSong].url;
    model.title = [SongInfo currentSong].title;
    model.songId = [SongInfo currentSong].sid;
    model.downLoad = [NSNumber numberWithInt:0];
    model.imageUrl = [SongInfo currentSong].picture;
    [self.downloadArray addObject:model];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (nil == self.downloadFileId) {
            [self startDownload];
        }
    }];
}

-(void)setupDownload{
    [self.downloadArray removeAllObjects];
    NSArray *personsAgeEuqals2   = [DownloadModel MR_findByAttribute:@"downLoad" withValue:[NSNumber numberWithInt:2]];
    [self.downloadArray addObjectsFromArray:personsAgeEuqals2];
    
}

-(void)removeDownloadModel:(NSString*)sid{
    NSArray *downloadArray = [DownloadModel MR_findAll];
    if (downloadArray) {
        for (DownloadModel *model in downloadArray) {
            if ([model.songId isEqualToString:sid]) {
                [model MR_deleteEntity];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                break;
            }
        }
    }
}

-(NSString*)creatMediaDir:(NSString*)relativePath {
    
    
    NSFileManager * fileManager=[NSFileManager defaultManager];
    
    //NSString * path=[NSString stringWithFormat:@"%@%@",DownloadBashPath,MP4Path];
    NSString * path=PathForDocumentsResource(relativePath);
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        
        NSError *   error;
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            // QY_RELEASE_SAFELY(mp4Path);
            NSLog(@"Create Download directory[%@] error[%@]",path,[error localizedDescription]);
            return nil;
        }
        
    }
    return  path;
    
}

- (void)downloadFile:(NSString*)file
{
    if (nil == file) {
        return;
    }
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:file] cachePolicy:1 timeoutInterval:6];
    [[manger downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *filePath = [Tool get_downloaded_file_path:self.downloadFileId];

        NSURL *url = [NSURL fileURLWithPath:filePath];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (nil == error) {
            DownloadModel *model = [self.downloadArray objectAtIndex:0];
            model.downLoad = [NSNumber numberWithInt:1];
            NSString *filePath = [Tool get_downloaded_file_path:self.downloadFileId];
            model.localUrl = filePath;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                [self.downloadArray removeObject:model];
                self.downloadFileId = nil;
                [self startDownload];
            }];
            if (self.delegate) {
                [self.delegate downloadManagerCompletion];
            }
        }
    }] resume];
}

@end
