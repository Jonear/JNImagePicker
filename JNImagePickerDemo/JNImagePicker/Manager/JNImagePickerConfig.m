//
//  JNImagePickerConfig.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "JNImagePickerConfig.h"

@implementation JNImagePickerConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imagePickerMediaType  = kImagePickerMediaTypePhoto;
        self.capacity       = 9;
        self.sendHDImage    = NO;
        self.tip            = @"";
    }
    return self;
}

@end
