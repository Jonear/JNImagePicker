//
//  HYWAssetManager.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "JNAssetManager.h"

#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)

@implementation JNAssetManager

+ (instancetype)sharedManager {
    static JNAssetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JNAssetManager alloc]init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _selectedAssets     = [NSMutableArray arrayWithCapacity:0];
        
    }
    return self;
}

- (void)clearData {
    [self.selectedAssets removeAllObjects];
    [self setIsHDImage:NO];
}

//获取相册最后一张图片
+ (void)getLastImagePHAssetFromLibrary:(void (^)(PHAsset *))block {
    // 所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (NSInteger i = 0; i < smartAlbums.count; i++) {
        PHCollection *collection = smartAlbums[i];
        //遍历获取相册
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            if (fetchResult.count != 0) {
                block([fetchResult lastObject]);
            }
        }
    }
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,
                  ^{
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

@end
