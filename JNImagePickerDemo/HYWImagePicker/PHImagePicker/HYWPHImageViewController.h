//
//  HYWPHImageViewController.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"
#import "HYWLargeImageView.h"
#import "HYWIPAsset.h"

@class HYWImagePickerConfig;

#include <Photos/Photos.h>

@class HYWPHImageViewController;

@protocol HYWPHImageViewControllerDelegate <NSObject>

- (void)hywPHImageViewController:(HYWPHImageViewController *)picker didFinishPickingImages:(NSArray *)images;

- (void)hywPHImageViewController:(HYWPHImageViewController *)picker didFinishPickingVideo:(PHAsset *)asset;

@end

@interface HYWPHImageViewController : UIViewController

@property (nonatomic, strong) HYWImagePickerConfig               *imagePickerConfig;
@property (weak, nonatomic) id<HYWPHImageViewControllerDelegate> plImageDelegate;

- (instancetype)initWithImagePickerConfig:(HYWImagePickerConfig *)imagePickerConfig
                              hywIPAssets:(NSArray *)hywIPAssets
                            objectAtIndex:(NSUInteger)index;

#pragma mark - PhotoKit
// 单独调用，预览一张图片，presentViewController
- (instancetype)initWithPHAsset:(PHAsset *)asset;

@end
