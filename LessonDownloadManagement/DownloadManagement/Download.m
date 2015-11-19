//
//  Download.m
//  LessonDownload
//
//  Created by 雨天记忆 on 15/10/20.
//  Copyright © 2015年 Rebirth. All rights reserved.
//

#import "Download.h"

@interface Download ()<NSURLSessionDownloadDelegate>

@property (copy, nonatomic) FinishBlock finish;
@property (copy, nonatomic) DownloadingBlock downloading;
@property (copy, nonatomic) DownloadComplted downloadComplted;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;//暂停下载，和继续下载
@property (strong, nonatomic) NSURLSession *session;//根据session生成一个task

@end

@implementation Download

- (instancetype)initWithURL:(NSString *)url{
    if ([super init]) {
        _url = url;
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue currentQueue]];
        //在数据库中判断是否已经下载过了，如果已经下载过了，执行断点下载
        if ([self isDownloadingWithURL:url]) {
            [self.task cancel];
            NSData *data = [self getDataFromDatabaseWithURL:url];
            self.task = [self.session downloadTaskWithResumeData:data];
        }else{
            self.task = [self.session downloadTaskWithURL:[NSURL URLWithString:url]];
        }
        //给一个默认值
        _state = DownloadSuspend;
    }
    return self;
}

//下载完成调用的代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //获取沙河路径
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *fm = [NSFileManager defaultManager];
    //把下载好的文件转移走
    [fm moveItemAtPath:location.path toPath:savePath error:nil];
    
    _state = DownloadFinished;
    
    self.downloadComplted(self.url);//让下载管理类不再持有它
    if (self.finish) {
        self.finish(savePath,self.url);
    }
    [DownloadContext addFinishWithURL:self.url savePath:savePath];
    [session invalidateAndCancel];
}

//下载中调用的代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //在刚开始下载的时候获取到下载的一些相关信息
    if (![self isDownloadingWithURL:self.url]) {
        [self saveDataString];
    }
    //算出当前进度
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    self.progress = progress * 100.0;
    //更新下载中对象的进度
    [DownloadContext updateDownloadingProgress:[NSNumber numberWithFloat:self.progress] withURL:self.url];
    //调用block
    if (self.downloading) {
        self.downloading(bytesWritten,self.progress);
    }
}

//开始
- (void)resume{
    //因为有时候暂停的时间长的时候，task会变成一个完成的状态。这个时候需要我们重新开始下载
    if (self.task.state == NSURLSessionTaskStateCompleted && [DownloadContext findFinishWithURL:_url] == nil) {
        self.task = nil;
        NSData *data = [self getDataFromDatabaseWithURL:_url];
        self.task = [self.session downloadTaskWithResumeData:data];
    }
    if (self.state == DownloadSuspend) {
        [self.task resume];
    }
    _state = DownloadResume;
}

//暂停
- (void)suspend{
    if (self.state == DownloadResume) {
        [self.task suspend];
    }
    _state = DownloadSuspend;
}

//在根据url在数据库中取出data
- (NSData *)getDataFromDatabaseWithURL:(NSString *)url{
    Downloading *downloading = [DownloadContext findDownloadingWithURL:url];
    NSString *dataString = downloading.dataString;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *fileSize = [NSString stringWithFormat:@"%llu",[[fm attributesOfItemAtPath:downloading.tmpPath error:nil] fileSize]];
    dataString = [dataString stringByReplacingOccurrencesOfString:downloading.fileSize withString:fileSize];
    
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}

//根据url确定一个对象的dataPath是否已经存储过了
- (BOOL)isDownloadingWithURL:(NSString *)url{
    if ([DownloadContext findDownloadingWithURL:url].dataString) {
        return YES;
    }else{
        return NO;
    }
}

- (void)didFinishDownload:(FinishBlock)finish downloading:(DownloadingBlock)downloading{
    //对block赋值
    self.finish = finish;
    self.downloading = downloading;
}

//保存下载的相关信息
- (void)saveDataString{
    __weak typeof(self) vc = self;
    [vc.task cancelByProducingResumeData:^(NSData *resumeData) {
        //解析resumeData并且归档
        [vc parsingResumeData:resumeData];
        vc.task = nil;
        //保存完信息后继续开始下载
        vc.task = [self.session downloadTaskWithResumeData:resumeData];
        [vc.task resume];
    }];
}

//解析resumeData数据，得到下载的地址大小等数据
- (void)parsingResumeData:(NSData *)resumeData{
    NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    NSString *integerStr = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"].lastObject;
    NSString *fileSize = [integerStr componentsSeparatedByString:@"</integer>"].firstObject;
    
    NSString *tmpPath = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoLocalPath</key>\n\t<string>"].lastObject;
    tmpPath = [tmpPath componentsSeparatedByString:@"</string>"].firstObject;
    
    //因为sdk和编译器不一样的问题，造成Xcode6和Xcode7下，解析结果不一样，如果找不到该文件，换一种解析方式
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:tmpPath]) {
        tmpPath = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
        tmpPath = [tmpPath componentsSeparatedByString:@"</string>"].firstObject;
        NSString *tmp = NSTemporaryDirectory();
        tmpPath = [tmp stringByAppendingPathComponent:tmpPath];
    }
    
    //添加一条下载中的信息
    [DownloadContext addDownloadingWithURL:self.url tmpPath:tmpPath dataString:dataString fileSize:fileSize];
}

- (void)downloadComplted:(DownloadComplted)downloadComplted{
    
    //对block赋值
    self.downloadComplted = downloadComplted;
}

@end
