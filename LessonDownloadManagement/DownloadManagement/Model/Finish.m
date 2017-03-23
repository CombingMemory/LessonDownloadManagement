//
//  Finish.m
//  
//
//  Created by 雨天记忆 on 15/10/21.
//
//

#import "Finish.h"


@implementation Finish

@dynamic url;
@dynamic savePath;

- (NSString *)getSavePath{
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cache stringByAppendingPathComponent:self.savePath];
}

@end
