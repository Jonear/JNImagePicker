//
//  JNIPAssetHelper.h
//  JNImagePicker
//
//  Created by Jonear on 13-9-4.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <Photos/Photos.h>
#import "JNIPAsset.h"

@interface JNIPAssetHelper : NSObject

+ (UIImage *)imageWithIPAsset:(JNIPAsset *)IPAsset original:(BOOL)original;


/**
 *  PhotoKit
 */
+ (UIImage *)imageWithPHAsset:(PHAsset *)asset original:(BOOL)original;


/**
 *  获得原图的数据
 */
+ (NSData *)imageOriginalDataWithIPAsset:(JNIPAsset *)IPAsset;

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
 *  @param IPAsset IPAsset
 *  @param filepath 本地路径
 *
 *  @return BOOL
 */
+ (BOOL)writeIPAsset:(JNIPAsset *)IPAsset toFilepath:(NSString *)filepath;

@end
