//
//  JNPHListViewController.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JNImagePickerConfig.h"
#include <Photos/Photos.h>
@class JNPHListViewController;

@protocol JNPHListViewControllerDelegate <NSObject>

- (void)JNPHListViewController:(JNPHListViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)JNPHListViewControllerDidCancel:(JNPHListViewController *)picker;
@optional
- (void)JNPHListViewController:(JNPHListViewController *)picker didFinishPickingVideo:(PHAsset *)asset;

@end

@interface JNPHListViewController : UIViewController

// 相册列表
@property (strong) NSMutableArray *collectionsFetchResultsAssets;
// 相册标题列表
@property (strong) NSMutableArray *collectionsFetchResultsTitles;
// 相册ID
@property (strong) NSArray *collectionsLocalIdentifier;


@property (weak, nonatomic) id<JNPHListViewControllerDelegate> plListDelegate;

- (instancetype)initWithImagePickerConfig:(JNImagePickerConfig *)imagePickerConfig;

@end
