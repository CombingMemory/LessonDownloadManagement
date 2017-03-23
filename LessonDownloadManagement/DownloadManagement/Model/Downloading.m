//
//  Downloading.m
//  
//
//  Created by 雨天记忆 on 15/10/27.
//
//

#import "Downloading.h"


@implementation Downloading

@dynamic dataString;
@dynamic fileSize;
@dynamic progress;
@dynamic tmpPath;
@dynamic url;

- (NSString *)getTempPath{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:self.tmpPath];
}

@end
