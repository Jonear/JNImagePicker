//
//  HYWAssetManager.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYWIPAsset.h"

@interface HYWAssetManager : NSObject

@property (nonatomic, strong) ALAssetsGroup     *assetsGroup;   //其中一个Group
@property (nonatomic, strong) NSMutableArray    *assetsGroups;  // 所有Group
/**
 *  所有选择的Asset
 */
@property (nonatomic, strong) NSMutableArray    *selectedAssets;
/**
 *  相册ID
 */
@property (nonatomic, strong) NSString          *assetsGroupID;
/**
 *  是否发布原图
 */
@property (nonatomic, assign) BOOL              isHDImage;

// cachedAssets, Key:groupID, Val:groupAssets
// groupAssets也是个Dic, Key:index, Val:hywIPAsset
@property (nonatomic, strong) NSMutableDictionary *cachedAssets;

+ (instancetype)sharedManager;

- (void)getLastImageAssetFromLibrary:(void (^)(id))block;

@end
