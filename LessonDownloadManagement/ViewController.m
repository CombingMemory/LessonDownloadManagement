//
//  ViewController.m
//  LessonDownloadManagement
//
//  Created by 雨天记忆 on 15/10/21.
//  Copyright (c) 2015年 Rebirth. All rights reserved.
//

#import "ViewController.h"
#import "DownloadManagement.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (strong, nonatomic) Download *download;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.download = [[DownloadManagement shareDownloadManagement] addDownloadingWithURL:@"http://baobab.cdn.wandoujia.com/1445236342564s.mp4"];
    
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] init];
    controller.view.frame = CGRectMake(0, 300, 320, 180);
    [self.view addSubview:controller.view];
    
    Downloading *downloading = [DownloadContext findDownloadingWithURL:@"http://baobab.cdn.wandoujia.com/1445236342564s.mp4"];
    
    self.progress.text = [downloading.progress stringValue];
    
    [self.download didFinishDownload:^(NSString *savePath, NSString *url) {
        controller.contentURL = [NSURL fileURLWithPath:savePath];
        [controller play];
    } downloading:^(long long bytesWritten, float progress) {
        self.progress.text = [NSString stringWithFormat:@"%f",progress];
    }];
}
- (IBAction)resume:(id)sender {
    [self.download resume];
}

- (IBAction)suspend:(id)sender {
    [self.download suspend];
}

@end
