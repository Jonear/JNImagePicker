//
//  JNIPAsset.m
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import "JNIPAsset.h"

@implementation JNIPAsset

- (instancetype)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        _phAsset = asset;
        _selected = NO;
    }
    
    return self;
}

- (void)cancelAnyLoading {
    if (_assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetRequestID];
        _assetRequestID = PHInvalidImageRequestID;
    }
}

@end
