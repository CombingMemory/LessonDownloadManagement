//
//  DownloadManagement.m
//  LessonDownload
//
//  Created by 雨天记忆 on 15/10/20.
//  Copyright © 2015年 Rebirth. All rights reserved.
//

#import "DownloadManagement.h"
#import "DownloadContext.h"

@interface DownloadManagement ()

//创建一个字典。用来保存当前存在的下载。使单例持有它，从而不会被销毁
@property (strong, nonatomic) NSMutableDictionary *dic;

@end

@implementation DownloadManagement

//懒加载。
- (NSMutableDictionary *)dic{
    if (!_dic) {
        self.dic = [NSMutableDictionary dictionary];
    }
    return _dic;
}

//创建一个单例
+ (instancetype)shareDownloadManagement{
    static DownloadManagement *downloadManagement = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManagement = [[DownloadManagement alloc] init];
        //先把数据库中的对象添加到单例里面，防止程序退出，从新进入的时候。下载器里面没有对象
        NSArray *array = [DownloadContext allDownloading];
        for (Downloading *downloading in array) {
            [downloadManagement addDownloadingWithURL:downloading.url];
        }

    });
    return downloadManagement;
}

//根据URL添加一个下载
- (Download *)addDownloadingWithURL:(NSString *)url{
    //判断是否已经有这个下载了。如果有了，从字典中取出我们的下载
    //如果没有，创建一个新的，并添加到字典里面.
    Download *download = self.dic[url];
    if (!download) {
        download = [[Download alloc] initWithURL:url];
        [self.dic setValue:download forKey:url];
    }
    [download downloadComplted:^(NSString *url) {
        //下载完成后 从我们的字典中移除该对象。让单例不在持有它
        [self.dic removeObjectForKey:url];
    }];
    return download;
}

//根据URL找到一个下载
- (Download *)findDownloadingWithURL:(NSString *)url{
    return self.dic[url];
}

//返回所有的下载
- (NSArray *)allDownloading{
    return [self.dic allValues];
}

@end
