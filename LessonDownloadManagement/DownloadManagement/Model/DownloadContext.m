//
//  DownloadContext.m
//  
//
//  Created by 雨天记忆 on 15/10/21.
//
//

#import "DownloadContext.h"

@implementation DownloadContext

+ (NSManagedObjectContext *)downloadContext{
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] init];
        
        //CoreData文件路径
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DownloadManagement" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        //获取沙盒文件目录
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqlPath = [doc stringByAppendingPathComponent:@"DownloadManagement.sqlite"];
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:nil];
        
        context.persistentStoreCoordinator = store;
    });
    return context;
}

//返回所有下载完成的对象
+ (NSArray *)allFinish{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Finish"];
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    return array;
}

//返回所有正在下载的对象
+ (NSArray *)allDownloading{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Downloading"];
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    return array;
}

//根据url返回一个下载完成的对象
+ (Finish *)findFinishWithURL:(NSString *)url{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Finish"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count == 0) {
        return nil;
    }
    return [array firstObject];
}

//根据url返回一个下载中的对象
+ (Downloading *)findDownloadingWithURL:(NSString *)url{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Downloading"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count == 0) {
        return nil;
    }
    return [array firstObject];
}

//根据url删除一个下载完成的对象（沙盒文件也一并删除了）
+ (void)deleteFinishWithURL:(NSString *)url{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Finish"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count != 0) {
        for (Finish *finish in array) {
            //删除沙盒里面的数据
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:finish.savePath error:nil];
            //删除数据
            [context deleteObject:finish];
        }
    }
    [context save:nil];
}

//根据url删除一个下载中的对象（沙盒中所有相关的信息都删除了）
+ (void)deleteDownloadingWithURL:(NSString *)url{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Downloading"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count != 0) {
        for (Downloading *downloading in array) {
            //删除沙盒里面的数据
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:downloading.dataString error:nil];
            //删除数据
            [context deleteObject:downloading];
        }
    }
    [context save:nil];
}

//添加一个下载完成的对象（内部已经完成了对正在下载的数据删除）
+ (void)addFinishWithURL:(NSString *)url savePath:(NSString *)savePath{
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    Finish *finish = [NSEntityDescription insertNewObjectForEntityForName:@"Finish" inManagedObjectContext:context];
    finish.url = url;
    finish.savePath = savePath;
    [context save:nil];
    //删除正在下载的数据
    [DownloadContext deleteDownloadingWithURL:url];
}

//添加一个正在下载的对象
+ (void)addDownloadingWithURL:(NSString *)url tmpPath:(NSString *)tmpPath dataString:(NSString *)dataString fileSize:(NSString *)fileSize{
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    Downloading *downloading = [NSEntityDescription insertNewObjectForEntityForName:@"Downloading" inManagedObjectContext:context];
    downloading.url = url;
    downloading.dataString = dataString;
    downloading.fileSize = fileSize;
    downloading.tmpPath = tmpPath;
    [context save:nil];
}

//根据url更新下载的进度
+ (void)updateDownloadingProgress:(NSNumber *)progress withURL:(NSString *)url{
    NSManagedObjectContext *context = [DownloadContext downloadContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Downloading"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count != 0) {
        for (Downloading *downloading in array) {
            downloading.progress = progress;
        }
        [context save:nil];
    }
}


@end
