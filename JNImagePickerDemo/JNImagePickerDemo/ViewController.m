//
//  ViewController.m
//  JNImagePickerDemo
//
//  Created by NetEase on 16/10/19.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "ViewController.h"

#import "HYWImagePickerManager.h"
#import "HYWAssetManager.h"
#import "HYWIPAssetHelper.h"
#import "HYWPHListViewController.h"
#import "HYWPHImageViewController.h"

@interface ViewController ()

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
    [[HYWAssetManager sharedManager].selectedAssets removeAllObjects];
    [[HYWAssetManager sharedManager] setIsHDImage:NO];
    
    HYWImagePickerConfig *config = [[HYWImagePickerConfig alloc] init];
    config.imagePickerMediaType = kImagePickerMediaTypePhoto;
    config.delegate = self;
    config.sendHDImage = YES;
    config.capacity = 1;
    HYWImagePickerManager *manager = [[HYWImagePickerManager alloc] init];
    [manager showImagePickerInViewController:self imagePickerConfig:config];
}

#pragma mark - 图片选择器
- (void)hywPHImageViewController:(HYWPHImageViewController *)picker didFinishPickingImages:(NSArray *)images {
    BOOL isHDImage = [[HYWAssetManager sharedManager] isHDImage];
    picker.plImageDelegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self sendImagesMessageWithAssetArray:images isHDImage:isHDImage];
}

- (void)hywPHImageViewController:(HYWPHImageViewController *)picker didFinishPickingVideo:(PHAsset *)asset {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PhotoKit HYWPHListViewControllerDelegate
- (void)hywPHListViewController:(HYWPHListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    BOOL isHDImage = [[HYWAssetManager sharedManager] isHDImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self sendImagesMessageWithAssetArray:info isHDImage:isHDImage];
}
- (void)hywPHListViewControllerDidCancel:(HYWPHListViewController *)picker {
    picker.plListDelegate = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImagesMessageWithAssetArray:(NSArray *)assets isHDImage:(BOOL)isHDImage {
    [assets enumerateObjectsUsingBlock:^(HYWIPAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [HYWIPAssetHelper imageWithHYWIPAsset:obj original:isHDImage];
        NSLog(@"%@", image);
    }];
    
}

@end
