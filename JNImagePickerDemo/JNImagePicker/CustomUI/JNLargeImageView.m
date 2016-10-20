//
//  HYWLargeImageView.m
//  JNImagePicker
//
//  Created by Jonear on 14/12/24.
//  Copyright (c) 2014年 Jonear. All rights reserved.
//

#import "JNLargeImageView.h"

#define kScrollDefaultSize  100.0   // 阀值
#define kZoomScale          3.0     // 默认放大倍数

@interface JNLargeImageView () {
    CGFloat _maxScaleFactor;
    CGPoint _contentOffset;
    BOOL _isPresented;
    BOOL _isMoving;
}

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@end

@implementation JNLargeImageView {
    CGSize _oldAnimationViewSize;
    UIImageView *_animationViewShadowView;
}

- (instancetype)init {
    CGRect frame = [UIScreen mainScreen].bounds;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI:frame];
        _enableDoubleTap = YES;
        _isPresented = YES;
        
    }
    return self;
}

#pragma mark -
- (void)dealloc {
    self.imageScrollView.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutImageView];
}

#pragma mark - 初始化UI
- (void)initUI:(CGRect)aFrame {
    // UIScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.backgroundColor = [UIColor clearColor];
    self.imageScrollView = scrollView;
    self.imageScrollView.delegate = self;
    [self addSubview:scrollView];
    
    // UIImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.backgroundColor = [UIColor clearColor];
    self.imageView = imageView;
    [scrollView addSubview:imageView];
    
    // 添加手势
    [self addGestures];
    
    // 其他属性设置
    [_imageScrollView setDecelerationRate:0.4]; // 0.4或者使用UIScrollViewDecelerationRateNormal/2
    [_imageScrollView setShowsHorizontalScrollIndicator:NO];
    [_imageScrollView setShowsVerticalScrollIndicator:NO];
    
    
    // loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:activityIndicator];
    self.indicatorView = activityIndicator;
    self.indicatorView.hidden = YES;
}

#pragma mark Layout
- (void)layoutImageView {
    if (_showNoImageLoading) {
        self.indicatorView.center = CGPointMake(CGRectGetWidth(self.frame)/2.0,
                                                CGRectGetHeight(self.frame)/2.0);
    }
    
    if (_imageView.image) {
        if (_showNoImageLoading) {
            self.indicatorView.hidden = YES;
            [self.indicatorView stopAnimating];
        }
        
        if (!self.gapWidth) {
            self.gapWidth = 0;
        }
        
        _imageScrollView.frame = CGRectMake(self.gapWidth, 0,
                                            CGRectGetWidth(self.frame)-2*self.gapWidth,
                                            CGRectGetHeight(self.frame));
        _imageView.frame = CGRectMake(0, 0,
                                      CGRectGetWidth(_imageScrollView.frame),
                                      CGRectGetHeight(_imageScrollView.frame));
        
        CGRect bounds = _imageScrollView.bounds;
        CGSize newImageSize = [self newImageSize:_imageView];
        
        _imageView.bounds = CGRectMake(0, 0, newImageSize.width, newImageSize.height);
        _imageScrollView.contentSize = CGSizeMake(MAX(CGRectGetWidth(_imageView.bounds), CGRectGetWidth(bounds)),
                                                  MAX(CGRectGetHeight(_imageView.bounds), CGRectGetHeight(bounds)));
        _imageView.center = CGPointMake(_imageScrollView.contentSize.width/2.0,
                                        _imageScrollView.contentSize.height/2.0);
        
        _maxScaleFactor = [self scaleFactorWithImageView:_imageView];
        _imageScrollView.maximumZoomScale = _maxScaleFactor;
        
        
    } else {
        if (_showNoImageLoading) {
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
        }
    }
}

#pragma mark - Actions
- (void)doubleTapToScale:(UIGestureRecognizer *)recognizer {
    if (_enableDoubleTap)
    {
        CGPoint p = [recognizer locationInView:_imageView];
        
        CGFloat scale = fabs([_imageScrollView zoomScale] - 1.0f) <= 0.00001 ? _maxScaleFactor : 1.0f;
        
        
        _contentOffset = CGPointMake((p.x)*scale - CGRectGetWidth(_imageScrollView.bounds)/2,
                                     (p.y)*scale - CGRectGetHeight(_imageScrollView.bounds)/2);
        
        if (_contentOffset.x + CGRectGetWidth(_imageScrollView.bounds) > CGRectGetWidth(_imageView.bounds)*scale) {
            _contentOffset.x = CGRectGetWidth(_imageView.bounds)*scale - CGRectGetWidth(_imageScrollView.bounds);
        }
        
        if (_contentOffset.x < 0) {
            _contentOffset.x = 0;
        }
        
        if (_contentOffset.y + CGRectGetHeight(_imageScrollView.bounds) > CGRectGetHeight(_imageView.bounds)*scale) {
            _contentOffset.y = CGRectGetHeight(_imageView.bounds)*scale - CGRectGetHeight(_imageScrollView.bounds);
        }
        
        if (_contentOffset.y < 0) {
            _contentOffset.y = 0;
        }
        
        CGRect zoomRect = [self zoomRectForScale:scale withCenter:p];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onDoubleTap:)]) {
            [_delegate onDoubleTap:self];
        }
    }
    
}

- (void)singleTap:(UIGestureRecognizer *)recognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(onTouch:)]) {
        [_delegate onTouch:self];
    }
}

- (void)onLongPressed:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(onLargeImageViewLongPressed:)]) {
            [_delegate onLargeImageViewLongPressed:self];
        }
    }
}

#pragma mark - Private Methods
- (void)addGestures {
    // 单击
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tapRecognizer];
    
    
    // 双击
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(doubleTapToScale:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapRecognizer];
    
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    
    
    // 长按
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                                     action:@selector(onLongPressed:)];
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)reset {
    if (_imageScrollView.zoomScale != 1.f) {
        CGRect zoomRect = [self zoomRectForScale:1.f withCenter:self.center];
        [_imageScrollView zoomToRect:zoomRect animated:NO];
    }
}

/// 缩放系数
- (CGFloat)scaleFactorWithImageView:(UIImageView *)imageView {
    CGFloat imageWidth = MAX(self.imageView.image.size.width, 1);
    CGFloat imageHeight= MAX(self.imageView.image.size.height, 1);
    CGSize scrollViewSize = self.imageScrollView.bounds.size;
    CGFloat ratio = kZoomScale;
    
    if (imageWidth / imageHeight >= scrollViewSize.width / scrollViewSize.height) {
        if (imageHeight * kZoomScale < scrollViewSize.height + kScrollDefaultSize) {
            ratio = scrollViewSize.height / imageHeight;
        }
    } else {
        if (imageWidth * kZoomScale < scrollViewSize.width + kScrollDefaultSize) {
            ratio = scrollViewSize.width / imageWidth;
        }
    }
    return ratio;
}

/// 更具显示规则，设置新的Size
- (CGSize)newImageSize:(UIImageView *)imageView {
    CGSize scrollViewSize = [_imageScrollView bounds].size;
    CGSize imgSize = imageView.image.size;
    CGFloat fixWidth = MAX(imgSize.width, 1.0f);    // 避免做除以0操作
    CGFloat fixHeight = MAX(imgSize.height, 1.0f);  // 避免做除以0操作
    
    UIImageOrientation imageOrientation=imageView.image.imageOrientation;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // h < w || 2w < h 填充宽
        if (fixHeight < fixWidth ||
            fixHeight >= 2 * fixWidth) {
            return CGSizeMake(scrollViewSize.width, scrollViewSize.width * fixHeight / fixWidth);
        } else {   // w <= h <= 2w 填充高
            return CGSizeMake(scrollViewSize.height * fixWidth / fixHeight, scrollViewSize.height);
        }
    } else if(imageOrientation!=UIImageOrientationUp) {
        return CGSizeMake(scrollViewSize.width, scrollViewSize.width * fixWidth / fixHeight);
    } else {
        return CGSizeMake(scrollViewSize.width, scrollViewSize.width * fixHeight / fixWidth);
    }
}

#pragma mark - UIScrollViewDelegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
    
    if (!CGPointEqualToPoint(_contentOffset, CGPointZero)) {
        scrollView.contentOffset = _contentOffset;
        _contentOffset = CGPointZero;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale {
    //
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [_imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (_isPresented == NO || _isMoving) {
        return NO;
    }
    return YES;
}
@end
