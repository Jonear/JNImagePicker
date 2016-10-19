//
//  UIImage+Utilities.h
//  yixin_iphone
//
//  Created by zqf on 13-1-18.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)
- (UIImage *)scaleWithMaxPixels: (CGFloat)maxPixels;

- (UIImage *)scaleToSize:(CGSize)newSize;

- (UIImage *)externalScaleSize: (CGSize)scaledSize;

- (UIImage *)thumb;

- (UIImage *)thumbForSNS: (NSInteger)count;

/**
 *
 *  分享到外部 社会化app 的缩略图size 要严格控制
 *  @return 缩略好的图片
 */
- (UIImage *)thumbForSocialShare;

- (UIImage *)makeImageRounded;

//- (BOOL)saveToFilepath: (NSString *)filepath;   

- (BOOL)saveToFilepathWithFullQuality: (NSString *)filepath; //全质量

- (BOOL)saveToFilepathWithPng:(NSString*)filepath; //png

- (UIImage *)fixOrientation;

//+ (UIImage *)mergeImagesToBoxStyle: (NSArray *)images;

/**
 * 获取圆形的图片
 */
- (UIImage *)circleImage;

/// 不指定resizableImageWithCapInsets第2拉伸参数的时候，用的是平铺模式遇到大图片的拉伸时GPU卡爆，所以构造了本方法
- (UIImage *)resizableImageWithCapInsetsForStretch:(UIEdgeInsets)capInsets;
@end

