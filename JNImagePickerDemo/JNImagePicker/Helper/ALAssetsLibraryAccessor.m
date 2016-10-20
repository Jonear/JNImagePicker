//
//  ALAssetsLibraryAccessor.m
//  JNImagePicker
//
//  Created by Jonear on 13-7-2.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import "ALAssetsLibraryAccessor.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ALAssetsLibraryAccessor

- (id)init {
    self = [super init];
    if (self) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
    }
    
    return  self;
}

+ (ALAssetsLibraryAccessor *)sharedInstance
{
    static ALAssetsLibraryAccessor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALAssetsLibraryAccessor alloc] init];
    });
    return sharedInstance;
}

- (ALAssetsLibrary *)assetsLibrary {
    return assetsLibrary_;
}

- (void)refreshAssetsLibrary {
    assetsLibrary_ = nil;
    assetsLibrary_ = [[ALAssetsLibrary alloc] init];
}

@end
