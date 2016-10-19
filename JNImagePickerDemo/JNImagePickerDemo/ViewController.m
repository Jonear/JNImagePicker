//
//  ViewController.m
//  JNImagePickerDemo
//
//  Created by NetEase on 16/10/19.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"

#import "JNImagePickerManager.h"
#import "JNAssetManager.h"
#import "JNIPAssetHelper.h"
#import "HYWPHListViewController.h"
#import "HYWPHImageViewController.h"

@interface ViewController () <HYWPHListViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *bigButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [bigButton setBackgroundColor:[UIColor redColor]];
    [bigButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bigButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)buttonClick:(id)sender {
    [[JNAssetManager sharedManager] clearData];
    JNImagePickerConfig *config = [[JNImagePickerConfig alloc] init];
    config.imagePickerMediaType = kImagePickerMediaTypeAll;
    config.delegate = self;
    config.sendHDImage = YES;
    config.capacity = 1;
    JNImagePickerManager *manager = [[JNImagePickerManager alloc] init];
    [manager showImagePickerInViewController:self imagePickerConfig:config];
}

#pragma mark - PhotoKit HYWPHListViewControllerDelegate
- (void)hywPHListViewController:(HYWPHListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    BOOL isHDImage = [[JNAssetManager sharedManager] isHDImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self sendImagesMessageWithAssetArray:info isHDImage:isHDImage];
}
- (void)hywPHListViewControllerDidCancel:(HYWPHListViewController *)picker {
    picker.plListDelegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)hywPHListViewController:(HYWPHListViewController *)picker didFinishPickingVideo:(PHAsset *)asset {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImagesMessageWithAssetArray:(NSArray *)assets isHDImage:(BOOL)isHDImage {
    [assets enumerateObjectsUsingBlock:^(JNIPAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [JNIPAssetHelper imageWithHYWIPAsset:obj original:isHDImage];
        NSLog(@"%@", image);
    }];
    
}

@end
