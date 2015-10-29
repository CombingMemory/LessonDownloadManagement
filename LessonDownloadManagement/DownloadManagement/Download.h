//
//  Download.h
//  LessonDownload
//
//  Created by 雨天记忆 on 15/10/20.
//  Copyright © 2015年 Rebirth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadContext.h"

//定义下载完成的block
typedef void(^FinishBlock)(NSString *savePath, NSString *url);
//定义下载中的block
typedef void(^DownloadingBlock)(long long bytesWritten, float progress);
//定义一个下载完成的block,主要作用让DownloadManagement删除该下载，释放内存
typedef void(^DownloadComplted)(NSString *url);

@interface Download : NSObject

//返回正在下载的url
@property (strong, nonatomic, readonly) NSString *url;

@property (assign, nonatomic) float progress;//记录当前的下载进度。

@property (readonly) NSURLSessionTaskState state;//返回当前下载类的一个状态

//开始
- (void)resume;

//暂停
- (void)suspend;

//根据url创建一个下载
- (instancetype)initWithURL:(NSString *)url;

//下载状态的和完成后调用的block
- (void)didFinishDownload:(FinishBlock)finish downloading:(DownloadingBlock)downloading;

//下载完成后调用的block，主要作用：让下载管理类删除该下载类，使它不再占用内存（用户使用不到，由我来帮你们完成,用户不要使用此方法，不然对象无法移除，会造成内存泄漏）
- (void)downloadComplted:(DownloadComplted)downloadComplted __deprecated_msg("不要调用该方法，此方法是下载管理器使用的。如果调用该方法会导致该对象无法被移除，从而造成内存泄露");

@end
