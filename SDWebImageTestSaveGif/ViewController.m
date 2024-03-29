//
//  ViewController.m
//  SDWebImageTestSaveGif
//
//  Created by yuelixing on 2019/9/2.
//  Copyright © 2019 Ylx. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <Photos/Photos.h>
#import "Logger.h"

@interface ViewController ()

@property (nonatomic, copy) NSString * gifURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gifURL = @"http://p5.gexing.com/GSF/biaoqing/20180813/20/4ghr1gkvwhu4e1hhofwi85ywd.jpg@!big.jpg";
    self.gifURL = @"http://p5.gexing.com/GSF/biaoqing/20180709/23/4rkpwbitr690ixues6zlqtbc1.jpg@!big.jpg";
    
    SDAnimatedImageView * customImageView = [[SDAnimatedImageView alloc] initWithFrame:CGRectMake(20.0, 20.0, 100, 100)];
    [self.view addSubview:customImageView];
    
    
    customImageView.clipsToBounds = YES;
    customImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [customImageView sd_setImageWithURL:[NSURL URLWithString:self.gifURL] completed:nil];
    
    UIButton * saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(20, 140, 60, 30);
    [saveButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}

- (void)saveButtonClick {
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.gifURL] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image && finished) {
            [self saveImage:image];
        }
    }];
}

- (void)saveImage:(UIImage *)image {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (PHAuthorizationStatusDenied == status || PHAuthorizationStatusAuthorized == status) {
            __block NSString * assetID = nil;
            NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld_%u.png", (NSInteger)[NSDate date].timeIntervalSince1970, arc4random()%10000]];
            
            NSData * tempData = nil;
            if ([image respondsToSelector:@selector(animatedImageData)]) {
                UIImage<SDAnimatedImage> * aniImage = (UIImage<SDAnimatedImage> *)image;
                tempData = [aniImage animatedImageData];
            } else {
                tempData = [image sd_imageDataAsFormat:[image sd_imageFormat]];
            }
            [tempData writeToFile:filePath atomically:YES];
            
            NSError * error = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                
                assetID = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:filePath]].placeholderForCreatedAsset.localIdentifier;
            } error:&error];
            
            if (error) {
                NSLog(@"%@", error);
                return;
            } else {
                NSLog(@"save success");
            }
            NSLog(@"%@", [[NSFileManager defaultManager] subpathsAtPath:NSTemporaryDirectory()]);
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]; // 保存完成后删除缓存文件
            if (error) {
                NSLog(@"delete file faile %@", error);
            } else {
                NSLog(@"delete success");
            }
            NSLog(@"%@", [[NSFileManager defaultManager] subpathsAtPath:NSTemporaryDirectory()]);
        }
    }];
}




@end
