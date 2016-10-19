//
//  HYWIPAssetHelper.h
//  yixin_iphone
//
//  Created by huangyaowu on 13-9-4.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <Photos/Photos.h>
#import "HYWIPAsset.h"

@interface HYWIPAssetHelper : NSObject

+ (UIImage *)imageWithHYWIPAsset:(HYWIPAsset *)hywIPAsset original:(BOOL)original;
/**
 *  AssetsLibrary
 */
+ (UIImage *)imageWithALAsset:(ALAsset *)asset original:(BOOL)original;
/**
 *  PhotoKit
 */
+ (UIImage *)imageWithPHAsset:(PHAsset *)asset original:(BOOL)original;


/**
 *  获得原图的数据
 */
+ (NSData *)imageOriginalDataWithHYWIPAsset:(HYWIPAsset *)hywIPAsset;

/**
 *  缩略图
 *
 *  @param asset PHAsset
 *
 *  @return UIImage
 */
+ (UIImage *)thumbnailWithPHAsset:(PHAsset *)asset;
+ (UIImage *)thumbnailWithPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;


/**
 *  保存asset到本地
 *
 *  @param hywIPAsset HYWIPAsset
 *  @param filepath 本地路径
 *
 *  @return BOOL
 */
+ (BOOL)writeHYWIPAsset:(HYWIPAsset *)hywIPAsset toFilepath:(NSString *)filepath;

@end
