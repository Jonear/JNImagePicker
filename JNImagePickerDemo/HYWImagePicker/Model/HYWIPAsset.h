//
//  HYWIPAsset.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <Photos/Photos.h>
/**
 *  HYW Image Picker Asset
 */
@interface HYWIPAsset : NSObject

/**
 *  PhotoKit PHAsset
 */
@property (nonatomic, strong) PHAsset       *phAsset;
/**
 *  是否被选择
 */
@property (nonatomic, assign) BOOL          selected;
/**
 *  图片大小，用来缓存
 */
@property (nonatomic, strong) NSString      *dataSize;
/**
 *  图片在列表中的位置
 */
@property (nonatomic, assign) NSInteger     index;
/**
 *  是否在iCloud
 */
@property (assign, nonatomic) BOOL isInTheCloud;
/**
 *  PHAsset 请求ID
 */
@property (assign, nonatomic) PHImageRequestID assetRequestID;


// // // // // // // // // // // // // // // // // // // // // // // // // // //

- (instancetype)initWithPHAsset:(PHAsset *)asset;

- (void)cancelAnyLoading;

@end
