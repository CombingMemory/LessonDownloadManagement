//
//  DownloadContext.h
//  
//
//  Created by 雨天记忆 on 15/10/21.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Finish.h"
#import "Downloading.h"

@interface DownloadContext : NSObject

//返回所有下载完成的对象
+ (NSArray *)allFinish;

//返回所有正在下载的对象
+ (NSArray *)allDownloading;

//根据url返回一个下载完成的对象
+ (Finish *)findFinishWithURL:(NSString *)url;

//根据url返回一个下载中的对象
+ (Downloading *)findDownloadingWithURL:(NSString *)url;

//根据url删除一个下载完成的对象（沙盒文件也一并删除了）
+ (void)deleteFinishWithURL:(NSString *)url;

//根据url删除一个下载中的对象（沙盒中所有相关的信息都删除了）
+ (void)deleteDownloadingWithURL:(NSString *)url;

//添加一个下载完成的对象（内部已经完成了对正在下载的数据删除）
+ (void)addFinishWithURL:(NSString *)url savePath:(NSString *)savePath;

//添加一个正在下载的对象(任务没有开始，就没有添加到数据库中)
+ (void)addDownloadingWithURL:(NSString *)url tmpPath:(NSString *)tmpPath dataString:(NSString *)dataString fileSize:(NSString *)fileSize;

//根据url更新下载的进度
+ (void)updateDownloadingProgress:(NSNumber *)progress withURL:(NSString *)url;

@end
