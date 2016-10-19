//
//  HYWImagePickerConfig.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    kImagePickerMediaTypeAll,       // 包括相片和视频
    kImagePickerMediaTypePhoto      // 包括相片
} ImagePickerMediaType;

@interface HYWImagePickerConfig : NSObject

@property (nonatomic, assign) ImagePickerMediaType  imagePickerMediaType;
@property (nonatomic, assign) NSInteger             capacity;
@property (nonatomic, strong) NSString              *tip;       // 超过capacity时的提示文案
@property (nonatomic,   weak) id                    delegate;
@property (nonatomic, assign) NSUInteger            groupIndex;
@property (nonatomic, assign) BOOL                  sendHDImage;// 是否有发送原图功能
@property (nonatomic, strong) NSString              *sendTitle; // 发送按钮文案

@end