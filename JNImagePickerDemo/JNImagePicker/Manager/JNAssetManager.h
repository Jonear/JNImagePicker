//
//  HYWAssetManager.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JNIPAsset.h"

@interface JNAssetManager : NSObject

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
