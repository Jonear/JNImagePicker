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

/**
 *  所有选择的Asset
 */
@property (nonatomic, strong) NSMutableArray    *selectedAssets;
/**
 *  相册ID
 */
@property (nonatomic, strong) NSString          *assetsGroupID;
/**
 *  是否发布原图模式
 */
@property (nonatomic, assign) BOOL              isHDImage;


+ (instancetype)sharedManager;

+ (void)getLastImagePHAssetFromLibrary:(void (^)(PHAsset *))block;


/**
 *  清理数据
 */
- (void)clearData;

@end
