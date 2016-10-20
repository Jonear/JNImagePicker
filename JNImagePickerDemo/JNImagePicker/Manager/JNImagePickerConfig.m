//
//  JNImagePickerConfig.m
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
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
