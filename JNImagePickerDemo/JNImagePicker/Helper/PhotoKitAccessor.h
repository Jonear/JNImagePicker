//
//  PhotoKitAccessor.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/14.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Photos/Photos.h>

@interface PhotoKitAccessor : NSObject

+ (PhotoKitAccessor *)sharedInstance;

- (PHCachingImageManager *)phCachingImageManager;

- (PHImageRequestOptions *)phImageRequestOptions;

@end
