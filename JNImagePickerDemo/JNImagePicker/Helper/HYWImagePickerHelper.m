//
//  HYWImagePickerHelper.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "HYWImagePickerHelper.h"
#import "HYWAssetManager.h"

@implementation HYWImagePickerHelper


+ (HYWIPAsset *)selectedAsset:(HYWIPAsset *)hywIPAsset {
    HYWIPAsset *item = nil;
    HYWAssetManager *assetManager = [HYWAssetManager sharedManager];
    if ([assetManager.selectedAssets count] == 0) {
        return item;
    }
    
    NSString *identifier = hywIPAsset.phAsset.localIdentifier;
    for (HYWIPAsset *asset in assetManager.selectedAssets) {
        if ([asset.phAsset.localIdentifier isEqualToString:identifier]) {
            item = asset;
            break;
        }
    }
    
    return item;
}

+ (NSInteger)indexOfAsset:(HYWIPAsset *)hywIPAsset fromAssets:(NSArray *)assets {
    HYWIPAsset *item = nil;
    
    NSString *identifier = hywIPAsset.phAsset.localIdentifier;
    for (HYWIPAsset *asset in assets) {
        if ([asset.phAsset.localIdentifier isEqualToString:identifier]) {
            item = asset;
            break;
        }
    }
    
    return item ? [assets indexOfObject:item] : 0;
}

+ (void)clearAssetManager {
    [[HYWAssetManager sharedManager] clearData];
}

static NSUInteger const MINIMUM_SPACING     = 2.0f;
static NSUInteger const GRID_COUNT_PER_ROW  = 4.0f;

+ (CGSize)assetGridThumbnailSize {
    static CGSize staticThumbnailSize;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat thumbnailSize = floorf(([UIScreen mainScreen].bounds.size.width - MINIMUM_SPACING * (GRID_COUNT_PER_ROW - 1)) / GRID_COUNT_PER_ROW);
        CGFloat scale = [UIScreen mainScreen].scale;
        staticThumbnailSize = CGSizeMake(thumbnailSize * scale, thumbnailSize * scale);
    });
    return staticThumbnailSize;
}

@end
