//
//  UIImagePickerController+Block.h
//  yixin_iphone
//
//  Created by 黄耀武 on 15/1/9.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIImagePickerControllerFinishBlock)(NSDictionary *info);
typedef void(^UIImagePickerControllerCancelBlock)();
@interface UIImagePickerController (Block)

/// 系统拍照功能，不能编辑
+ (void)imagePickerWithFinishBlock:(UIImagePickerControllerFinishBlock)finishBlock;

+ (void)imagePickerWithFinishBlock:(UIImagePickerControllerFinishBlock)finishBlock useFrontCamera:(BOOL)useFrontCamera;

/// 系统相册或拍照功能，不能编辑
+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock;
/// 系统相册或拍照功能
+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                    allowsEditing:(BOOL)allowsEditing
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock;

+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                    allowsEditing:(BOOL)allowsEditing
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock
                      cancelBlock:(UIImagePickerControllerCancelBlock) cancelBlock;
@end
