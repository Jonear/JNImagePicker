//
//  PhotoKitAccessor.m
//  JNImagePicker
//
//  Created by Jonear on 16/3/14.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import "PhotoKitAccessor.h"

@interface PhotoKitAccessor() {
    PHCachingImageManager *_manager;
    PHImageRequestOptions *_options;
}
@end

@implementation PhotoKitAccessor

- (id)init {
    self = [super init];
    if (self) {
        _manager = [[PHCachingImageManager alloc] init];
        _options = [PHImageRequestOptions new];
    }
    
    return  self;
}

+ (PhotoKitAccessor *)sharedInstance {
    static PhotoKitAccessor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhotoKitAccessor alloc] init];
    });
    return sharedInstance;
}

- (PHCachingImageManager *)phCachingImageManager {
    return _manager;
}

- (PHImageRequestOptions *)phImageRequestOptions {
    return _options;
}

@end
