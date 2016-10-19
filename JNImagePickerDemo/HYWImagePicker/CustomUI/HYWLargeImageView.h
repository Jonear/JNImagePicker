//
//  HYWLargeImageView.h
//  yixin_iphone
//
//  Created by 黄耀武 on 14/12/24.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HYWLargeImageView;

static CGFloat kHYWLargeImageGapWidth = 16.0f;

@protocol HYWLargeImageViewDelegate <NSObject>
- (void)onTouch:(HYWLargeImageView *)cell;
@optional
- (void)onDoubleTap:(HYWLargeImageView *)cell;
- (void)onLargeImageViewLongPressed:(HYWLargeImageView *)cell;
@end

@interface HYWLargeImageView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) id<HYWLargeImageViewDelegate> delegate;
@property (assign, nonatomic) NSInteger gapWidth; // 图片预览时的间隔
@property (assign, nonatomic) BOOL      enableDoubleTap;//允许双击，默认为YES

/**
 *  图片为nil的时候显示loading
 */
@property (assign, nonatomic) BOOL showNoImageLoading;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;

@end
