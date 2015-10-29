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

@end
