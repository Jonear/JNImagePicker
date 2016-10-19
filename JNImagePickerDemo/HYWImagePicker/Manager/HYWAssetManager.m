//
//  HYWAssetManager.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "HYWAssetManager.h"

#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)

@implementation HYWAssetManager

+ (instancetype)sharedManager {
    static HYWAssetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HYWAssetManager alloc]init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _assetsGroups       = [NSMutableArray arrayWithCapacity:0];
        _selectedAssets     = [NSMutableArray arrayWithCapacity:0];
        _cachedAssets       = [NSMutableDictionary dictionaryWithCapacity:0];
        
    }
    return self;
}

//获取相册的所有图片
- (void)getLastImageAssetFromLibrary:(void (^)(id))block {
    if (IOS8) {
        [self getLastImagePHAssetFromLibrary:block];
    } else {
        [self getLastImageALAssetFromLibrary:block];
    }
}

//获取相册的所有图片
- (void)getLastImagePHAssetFromLibrary:(void (^)(PHAsset *))block {
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

//获取相册的所有图片
- (void)getLastImageALAssetFromLibrary:(void (^)(ALAsset *))block
{
    @autoreleasepool {
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
//            [FNSessionListHelper openSystemSettingWithTitle:@"无法使用照片" message:@"请在iPhone的\"设置-隐私-照片\"选项中，允许企业易信访问你的照片"];
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    block(result);
                }
            }
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group!=nil) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
                NSMutableIndexSet *photoIndexes = [[NSMutableIndexSet alloc] init];
                if (group.numberOfAssets>1) {
                    [photoIndexes addIndex:group.numberOfAssets-1];
                } else if (group.numberOfAssets>0) {
                    [photoIndexes addIndex:0];
                }
                
                if (photoIndexes.count > 0) {
                    [group enumerateAssetsAtIndexes:photoIndexes options:NSEnumerationConcurrent usingBlock:groupEnumerAtion];
                }
            }
            
        };
        
        ALAssetsLibrary* library = [HYWAssetManager defaultAssetsLibrary];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
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
