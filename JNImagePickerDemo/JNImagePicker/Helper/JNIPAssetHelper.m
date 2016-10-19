//
//  HYWIPAssetHelper.m
//  yixin_iphone
//
//  Created by huangyaowu on 13-9-4.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "JNIPAssetHelper.h"
#import "PhotoKitAccessor.h"
#import "JNImagePickerHelper.h"

@implementation JNIPAssetHelper

#pragma mark - 获取图片
+ (UIImage *)imageWithHYWIPAsset:(JNIPAsset *)hywIPAsset original:(BOOL)original {
    return [self imageWithPHAsset:hywIPAsset.phAsset original:original];
}

+ (NSData *)imageOriginalDataWithHYWIPAsset:(JNIPAsset *)hywIPAsset {
    __block NSData *data = nil;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageDataForAsset:hywIPAsset.phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        data = imageData;
    }];
    
    return data;
}

+ (UIImage *)imageWithPHAsset:(PHAsset *)asset original:(BOOL)original {
    __block UIImage *resultImage;
    // 取原图，大图，缩略图
    if (original) {
        resultImage = [JNIPAssetHelper getOriginImageFromPHAsset:asset];
        if (!resultImage) {
            resultImage = [JNIPAssetHelper getLargeImageFromPHAsset:asset];
        }
    } else {
        resultImage = [JNIPAssetHelper getLargeImageFromPHAsset:asset];
    }
    
    // 原图取不到的时候，获取一张缩略图。
    if (!resultImage) {
        resultImage = [JNIPAssetHelper thumbnailWithPHAsset:asset];
    }
    
    return resultImage;
}

/**
 *  原图
 *
 *  @param asset PHAsset
 *
 *  @return UIImage
 */
+ (UIImage *)getOriginImageFromPHAsset:(PHAsset *)asset {
    __block UIImage *resultImage;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultImage = result;
    }];
    
    return resultImage;
}
/**
 *  大图
 *
 *  @param asset PHAsset
 *
 *  @return UIImage
 */
+ (UIImage *)getLargeImageFromPHAsset:(PHAsset *)asset {
    __block UIImage *resultImage;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width), ([UIScreen mainScreen].bounds.size.height)) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        resultImage = result;
    }];
    return resultImage;
}
#pragma mark - 缩略图
/**
 *  缩略图
 *
 *  @param asset PHAsset
 *
 *  @return UIImage
 */
+ (UIImage *)thumbnailWithPHAsset:(PHAsset *)asset {
    __block UIImage *resultImage;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    CGSize thumbnailSize = [JNImagePickerHelper assetGridThumbnailSize];
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:thumbnailSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultImage = result;
    }];
    return resultImage;
}

+ (UIImage *)thumbnailWithPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    __block UIImage *resultImage;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultImage = result;
    }];
    return resultImage;
}



#pragma mark - ALAsset保存到本地
+ (BOOL)writeHYWIPAsset:(JNIPAsset *)hywIPAsset toFilepath:(NSString *)filepath {
    __block NSData *dest_data;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    
    [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageDataForAsset:hywIPAsset.phAsset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        dest_data = imageData;
    }];
    
    return [dest_data writeToFile:filepath atomically:YES];;
}

@end
