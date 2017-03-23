//
//  Finish.h
//  
//
//  Created by 雨天记忆 on 15/10/21.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Finish : NSManagedObject

@property (nonatomic, retain) NSString * url;//下载完成文件的原url
@property (nonatomic, retain) NSString * savePath;//下载完成文件保存本地的地址，只存储了文件路径没有添加沙盒路径，取出的时候需要拼接沙盒路径，使用下面的方法取出

//因为考虑到版本升级导致文件
- (NSString *)getSavePath;

@end
