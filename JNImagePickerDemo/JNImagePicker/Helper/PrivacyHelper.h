//
//  PrivacyHelper.h
//  FengNiao
//
//  Created by 吴孟钦 on 16/5/30.
//  Copyright © 2016年 浙江翼信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 各种系统隐私设置和访问限制的检查（iOS6开始有，iOS7以后追加了一部分）
@interface PrivacyHelper : NSObject
/// 检查照相的隐私设置，参数为是否显示提示
+ (BOOL)checkCameraPrivacy:(BOOL)showTip;

/// 检查相册的隐私设置，参数为是否显示提示
+ (void)checkAlbumPrivacy:(BOOL)showTip onComplete:(void (^)(BOOL haveAuthorization))complete;
@end
