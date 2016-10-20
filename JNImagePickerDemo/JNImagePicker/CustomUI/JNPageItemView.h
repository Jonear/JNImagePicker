//
//  JNPageItemView.h
//  JNImagePicker
//  按页展示的UIView，只载入当前页和前后页，保证内存的低占用 (目前只支持横向)
//  Created by amao on 13-5-14.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JNPageItemView;

@protocol PageViewDataSource <NSObject>
- (NSInteger)numberOfPages: (JNPageItemView *)pageView;
- (UIView *)pageView: (JNPageItemView *)pageView viewInPage: (NSInteger)index;
@end

@protocol PageViewDelegate <NSObject>
@optional
- (void)pageViewScrollEnd: (JNPageItemView *)pageView
             currentIndex: (NSInteger)index
               totolPages: (NSInteger)pages;

- (void)pageViewDidScroll: (JNPageItemView *)pageView;
- (BOOL)needScrollAnimation;

- (void)pageView:(JNPageItemView *)pageView didEndDisplayingAtIndex:(NSInteger)index;

@end


@interface JNPageItemView : UIView<UIScrollViewDelegate>
@property (nonatomic,strong)    UIScrollView   *scrollView;
@property (nonatomic,weak)    id<PageViewDataSource>  dataSource;
@property (nonatomic,weak)    id<PageViewDelegate>    pageViewDelegate;
- (void)scrollToPage: (NSInteger)pages;
- (void)reloadData;
- (UIView *)viewAtIndex: (NSInteger)index;
- (NSInteger)currentPage;


//旋转相关方法,这两个方法必须配对调用,否则会有问题
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;
@end
