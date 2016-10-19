//
//  HYWPHGridViewController.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYWIPAsset.h"
#import "HYWImagePickerConfig.h"
#include <Photos/Photos.h>

@class HYWPHGridViewController;

@protocol HYWPHGridViewControllerDelegate <NSObject>

@optional
- (void)hywPHGridViewController:(HYWPHGridViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)hywPHGridViewController:(HYWPHGridViewController *)picker didFinishPickingVideo:(PHAsset *)asset;
- (void)hywPHGridViewControllerDidCancel:(HYWPHGridViewController *)picker;
@end

@interface HYWPHGridViewController : UIViewController

@property (strong) PHFetchResult *assetsFetchResults;

@property (nonatomic, assign) BOOL                           isScrollToBottom;  // 这个属性在willAppear需要用到（左滑），不要优化掉 hyw
@property (weak, nonatomic) id<HYWPHGridViewControllerDelegate>       plGridDelegate;

- (instancetype)initWithImagePickerConfig:(HYWImagePickerConfig *)imagePickerConfig;

@end
