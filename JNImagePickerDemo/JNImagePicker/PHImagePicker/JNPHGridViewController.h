//
//  JNPHGridViewController.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNIPAsset.h"
#import "JNImagePickerConfig.h"
#include <Photos/Photos.h>

@class JNPHGridViewController;


@protocol JNPHGridViewControllerDelegate <NSObject>

@optional
- (void)JNPHGridViewController:(JNPHGridViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)JNPHGridViewController:(JNPHGridViewController *)picker didFinishPickingVideo:(PHAsset *)asset;
- (void)JNPHGridViewControllerDidCancel:(JNPHGridViewController *)picker;
@end

@interface JNPHGridViewController : UIViewController

@property (strong) PHFetchResult *assetsFetchResults;

@property (nonatomic, assign) BOOL                           isScrollToBottom;  // 这个属性在willAppear需要用到（左滑），不要优化掉 hyw
@property (weak, nonatomic) id<JNPHGridViewControllerDelegate>       plGridDelegate;


- (instancetype)initWithImagePickerConfig:(JNImagePickerConfig *)imagePickerConfig;

@end
