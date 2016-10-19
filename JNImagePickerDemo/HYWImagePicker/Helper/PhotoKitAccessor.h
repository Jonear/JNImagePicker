//
//  PhotoKitAccessor.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Photos/Photos.h>

@interface PhotoKitAccessor : NSObject

+ (PhotoKitAccessor *)sharedInstance;

- (PHCachingImageManager *)phCachingImageManager;

- (PHImageRequestOptions *)phImageRequestOptions;

@end
