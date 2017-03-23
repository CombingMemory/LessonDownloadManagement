//
//  Downloading.h
//  
//
//  Created by 雨天记忆 on 15/10/27.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Downloading : NSManagedObject

@property (nonatomic, retain) NSString * dataString;
@property (nonatomic, retain) NSString * fileSize;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSString * tmpPath;
@property (nonatomic, retain) NSString * url;

//获取下载中文件的路径，还是考虑到版本升级的问题，属性只存储文件名字，完整路径通过这个方法取出
- (NSString *)getTempPath;

@end
