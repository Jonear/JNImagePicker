//
//  PageView.h
//  yixin_iphone
//  按页展示的UIView，只载入当前页和前后页，保证内存的低占用 (目前只支持横向)
//  Created by amao on 13-5-14.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageView;

@protocol PageViewDataSource <NSObject>
- (NSInteger)numberOfPages: (PageView *)pageView;
- (UIView *)pageView: (PageView *)pageView viewInPage: (NSInteger)index;
@end

@protocol PageViewDelegate <NSObject>
@optional
- (void)pageViewScrollEnd: (PageView *)pageView
             currentIndex: (NSInteger)index
               totolPages: (NSInteger)pages;

- (void)pageViewDidScroll: (PageView *)pageView;
- (BOOL)needScrollAnimation;

- (void)pageView:(PageView *)pageView didEndDisplayingAtIndex:(NSInteger)index;

@end


@interface PageView : UIView<UIScrollViewDelegate>
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
