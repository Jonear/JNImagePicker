//
//  HYWImagePickerHelper.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYWIPAsset.h"
#import "HYWImagePickerConfig.h"

@interface HYWImagePickerHelper : NSObject

+ (HYWIPAsset *)selectedAsset:(HYWIPAsset *)hywIPAsset;
+ (NSInteger)indexOfAsset:(HYWIPAsset *)hywIPAsset fromAssets:(NSArray *)assets;
+ (void)clearAssetManager;
+ (CGSize)assetGridThumbnailSize;

@end
