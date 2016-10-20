//
//  JNImagePickerHelper.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNIPAsset.h"
#import "JNImagePickerConfig.h"

@interface JNImagePickerHelper : NSObject

+ (JNIPAsset *)selectedAsset:(JNIPAsset *)IPAsset;
+ (NSInteger)indexOfAsset:(JNIPAsset *)IPAsset fromAssets:(NSArray *)assets;
+ (void)clearAssetManager;
+ (CGSize)assetGridThumbnailSize;

@end
