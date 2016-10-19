//
//  HYWMacro.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#ifndef HYWMacro_h
#define HYWMacro_h

//系统版本枚举除了iOS5外,都是指大于等于当前那个版本,如IOS6表示当前版本号大于等于6.0
//所以在这个基础上，如果要判断当前版本是6.0版本就必须是: (IOS6 && !IOS7)
//但是不推荐这样的做法,大部分的系统判断都可以用responseToSelector替代
//只有在少部分大量用到某个版本以上API的地方才使用
#define IOS9            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0)
#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define IOS8_2          ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.2)
#define IOS7            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
#define IOS7_1          ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.1)

#define UIScreenScale  ([[UIScreen mainScreen] scale])
#define IsLandscape   (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))

#define RETINA          (UIScreenScale >= 2)
// iphone 6以上的scale叫做RETINAHD好了
#define RETINAHD        (UIScreenScale >= 3)
// 当前屏幕的宽度和高度，已经考虑旋转的因素(iOS8上[UIScreen mainScreen].bounds直接就考虑了旋转因素，iOS8以下[UIScreen mainScreen].bounds是不变的值)
#define UIScreenWidth    ((IOS8 || !IsLandscape) ?[UIScreen mainScreen].bounds.size.width:[UIScreen mainScreen].bounds.size.height)
#define UIScreenHeight   ((IOS8 || !IsLandscape) ?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width)

#pragma mark - UIColor宏定义
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]



#define HYW_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;

#define HYW_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;


#endif /* HYWMacro_h */
