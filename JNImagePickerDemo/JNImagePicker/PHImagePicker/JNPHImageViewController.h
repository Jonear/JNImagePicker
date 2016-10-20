//
//  JNPHImageViewController.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNPageItemView.h"
#import "JNLargeImageView.h"
#import "JNIPAsset.h"

@class JNImagePickerConfig;

#include <Photos/Photos.h>

@class JNPHImageViewController;

@protocol JNPHImageViewControllerDelegate <NSObject>

- (void)JNPHImageViewController:(JNPHImageViewController *)picker didFinishPickingImages:(NSArray *)images;

- (void)JNPHImageViewController:(JNPHImageViewController *)picker didFinishPickingVideo:(PHAsset *)asset;

@end

@interface JNPHImageViewController : UIViewController

@property (nonatomic, strong) JNImagePickerConfig               *imagePickerConfig;
@property (weak, nonatomic) id<JNPHImageViewControllerDelegate> plImageDelegate;

- (instancetype)initWithImagePickerConfig:(JNImagePickerConfig *)imagePickerConfig
                              hywIPAssets:(NSArray *)hywIPAssets
                            objectAtIndex:(NSUInteger)index;

#pragma mark - PhotoKit
// 单独调用，预览一张图片，presentViewController
- (instancetype)initWithPHAsset:(PHAsset *)asset;

@end
