//
//  iToast.h
//  eim_iphone
//
//  Created by zhou jezhee on 11/21/12.
//  Copyright (c) 2012 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    kToastPositionTop,
    kToastPositionCenter,
    kToastPositionBottom,
} ToastPosition;


@interface iToast : NSObject
@property (strong, nonatomic) NSString  *toastText;

- (id)initWithText: (NSString *)text;
- (void)showAt:(ToastPosition)position duration:(double)duration;
- (void)showAtCenter:(CGPoint)center duration:(double)duration;
+ (iToast *)makeToast: (NSString *)text;

@end

