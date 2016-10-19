//
//  HYWPHListViewController.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYWImagePickerConfig.h"
#include <Photos/Photos.h>
@class HYWPHListViewController;

@protocol HYWPHListViewControllerDelegate <NSObject>

- (void)hywPHListViewController:(HYWPHListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)hywPHListViewControllerDidCancel:(HYWPHListViewController *)picker;
@optional
- (void)hywPHListViewController:(HYWPHListViewController *)picker didFinishPickingVideo:(PHAsset *)asset;

@end

@interface HYWPHListViewController : UIViewController

// 相册列表
@property (strong) NSMutableArray *collectionsFetchResultsAssets;
// 相册标题列表
@property (strong) NSMutableArray *collectionsFetchResultsTitles;
// 相册ID
@property (strong) NSArray *collectionsLocalIdentifier;


@property (weak, nonatomic) id<HYWPHListViewControllerDelegate> plListDelegate;

- (instancetype)initWithImagePickerConfig:(HYWImagePickerConfig *)imagePickerConfig;

@end
