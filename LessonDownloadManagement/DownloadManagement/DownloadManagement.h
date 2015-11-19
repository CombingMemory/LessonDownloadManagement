//
//  DownloadManagement.h
//  LessonDownload
//
//  Created by 雨天记忆 on 15/10/20.
//  Copyright © 2015年 Rebirth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"

@interface DownloadManagement : NSObject

//单例方法
+ (instancetype)shareDownloadManagement;

//根据URL添加一个下载
- (Download *)addDownloadingWithURL:(NSString *)url;

//根据URL找到一个下载
- (Download *)findDownloadingWithURL:(NSString *)url;

//返回所有的下载
- (NSArray *)allDownloading;

@end
