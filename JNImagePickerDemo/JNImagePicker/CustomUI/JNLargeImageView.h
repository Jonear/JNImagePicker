//
//  LargeImageView.h
//  JNImagePicker
//
//  Created by Jonear on 14/12/24.
//  Copyright (c) 2014年 Jonear. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JNLargeImageView;

static CGFloat kLargeImageGapWidth = 16.0f;

@protocol JNLargeImageViewDelegate <NSObject>
- (void)onTouch:(JNLargeImageView *)cell;
@optional
- (void)onDoubleTap:(JNLargeImageView *)cell;
- (void)onLargeImageViewLongPressed:(JNLargeImageView *)cell;
@end

@interface JNLargeImageView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) id<JNLargeImageViewDelegate> delegate;
@property (assign, nonatomic) NSInteger gapWidth; // 图片预览时的间隔
@property (assign, nonatomic) BOOL      enableDoubleTap;//允许双击，默认为YES

/**
 *  图片为nil的时候显示loading
 */
@property (assign, nonatomic) BOOL showNoImageLoading;

@end
