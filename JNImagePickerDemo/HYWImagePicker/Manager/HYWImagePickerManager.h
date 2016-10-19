//
//  HYWImagePickerManager.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//
//  提示：
//  1、调用系统相册和拍照的ActionSheet
//  2、调用自定义相片选择器
//  3、单独调用系统相册或拍照功能，使用扩展类UIImagePickerController+Block.h
//

#import <Foundation/Foundation.h>
#import "HYWIPAsset.h"
#import "HYWImagePickerConfig.h"

typedef void(^UIImagePickerControllerFinishBlock)(NSDictionary *info);

@interface HYWImagePickerManager : NSObject

/// 调用系统相册和拍照功能的ActionSheet
- (void)imagePickerActionSheetInController:(UIViewController *)viewController
                          actionSheetTitle:(NSString *)actionSheetTitle
                               finishBlock:(UIImagePickerControllerFinishBlock)finishBlock;

- (void)imagePickerActionSheetInController:(UIViewController *)viewController
                          actionSheetTitle:(NSString *)actionSheetTitle
                             allowsEditing:(BOOL)allowsEditing
                               finishBlock:(UIImagePickerControllerFinishBlock)finishBlock;

- (void)showImagePickerInViewController:(UIViewController *)viewController
                      imagePickerConfig:(HYWImagePickerConfig *)imagePickerConfig;

@end
