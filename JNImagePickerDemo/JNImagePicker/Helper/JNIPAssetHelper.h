//
//  JNIPAssetHelper.h
//  yixin_iphone
//
//  Created by huangyaowu on 13-9-4.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <Photos/Photos.h>
#import "JNIPAsset.h"

@interface JNIPAssetHelper : NSObject

+ (UIImage *)imageWithHYWIPAsset:(JNIPAsset *)hywIPAsset original:(BOOL)original;


/**
 *  PhotoKit
 */
+ (UIImage *)imageWithPHAsset:(PHAsset *)asset original:(BOOL)original;


/**
 *  获得原图的数据
 */
+ (NSData *)imageOriginalDataWithHYWIPAsset:(JNIPAsset *)hywIPAsset;

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
+ (BOOL)writeHYWIPAsset:(JNIPAsset *)hywIPAsset toFilepath:(NSString *)filepath;

@end
