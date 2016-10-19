//
//  HYWImagePickerHelper.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNIPAsset.h"
#import "JNImagePickerConfig.h"

@interface JNImagePickerHelper : NSObject

+ (JNIPAsset *)selectedAsset:(JNIPAsset *)hywIPAsset;
+ (NSInteger)indexOfAsset:(JNIPAsset *)hywIPAsset fromAssets:(NSArray *)assets;
+ (void)clearAssetManager;
+ (CGSize)assetGridThumbnailSize;

@end
