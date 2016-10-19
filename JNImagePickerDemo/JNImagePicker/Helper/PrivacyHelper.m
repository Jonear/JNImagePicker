//
//  PrivacyHelper.m
//  FengNiao
//
//  Created by 吴孟钦 on 16/5/30.
//  Copyright © 2016年 浙江翼信科技有限公司. All rights reserved.
//

#import "PrivacyHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "PSTAlertController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "ALAssetsLibraryAccessor.h"

/// 各种系统隐私设置和访问限制的检查（iOS6开始有，iOS7以后追加了一部分）
@implementation PrivacyHelper
+ (BOOL)checkCameraPrivacy:(BOOL)showTip
{
    // 默认为YES
    __block BOOL haveAuthorization = YES;
    
    // iOS7 上新增对照相机隐私设置的检查
    // 取得认证状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
            haveAuthorization = YES;
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:
             ^(BOOL granted)
             {
                 
                 dispatch_sync(dispatch_get_main_queue(), ^
                               {
                                   haveAuthorization = granted;
                                   if(granted)
                                   {
                                       // 授权了不用做什么？
                                   }
                                   else if (showTip)
                                   {
                                       PSTAlertController *alert = [PSTAlertController alertWithTitle:@"" message:@"请在iPhone的“设置-隐私-相机”选项中，允许易信访问你的相机。"];
                                       [alert addAction:[PSTAlertAction actionWithTitle:@"确定" handler:nil]];
                                       [alert showWithSender:nil controller:nil animated:YES completion:nil];
                                   }
                               });
             }];
            
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            haveAuthorization = NO;
            
            if (showTip)
            {
                PSTAlertController *alert = [PSTAlertController alertWithTitle:@"" message:@"请在iPhone的“设置-通用-访问限制-相机”选项中，关闭相机的限制。"];
                [alert addAction:[PSTAlertAction actionWithTitle:@"确定" handler:nil]];
                [alert showWithSender:nil controller:nil animated:YES completion:nil];
            }
        }
            break;
        case AVAuthorizationStatusDenied:
        {
            haveAuthorization = NO;
            
            if (showTip)
            {
                PSTAlertController *alert = [PSTAlertController alertWithTitle:@"" message:@"请在iPhone的“设置-隐私-相机”选项中，允许易信访问你的相机。"];
                [alert addAction:[PSTAlertAction actionWithTitle:@"确定" handler:nil]];
                [alert showWithSender:nil controller:nil animated:YES completion:nil];
                
            }
            
        }
            break;
            
        default:
            break;
    }
    
    return haveAuthorization;
}

+ (void)checkAlbumPrivacy:(BOOL)showTip onComplete:(void (^)(BOOL haveAuthorization))complete {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusRestricted:
        case ALAuthorizationStatusDenied: {
            if (showTip) {
                
                PSTAlertController *alert = [PSTAlertController alertWithTitle:@"" message:@"请在iPhone的“设置-隐私-照片”选项中，允许易信访问你的相册。"];
                [alert addAction:[PSTAlertAction actionWithTitle:@"确定" handler:nil]];
                [alert showWithSender:nil controller:nil animated:YES completion:nil];
            }
            if(complete) complete(NO);
            
        } break;
        case ALAuthorizationStatusAuthorized: {
            if(complete) complete(YES);
        } break;
        case ALAuthorizationStatusNotDetermined: {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibraryAccessor sharedInstance] assetsLibrary];
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group)
                {
                    if(complete) complete(YES);
                    
                }
            } failureBlock:^(NSError *error) {
                if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                    
                    PSTAlertController *alert = [PSTAlertController alertWithTitle:@"" message:@"请在iPhone的“设置-隐私-照片”选项中，允许易信访问你的相册。"];
                    [alert addAction:[PSTAlertAction actionWithTitle:@"确定" handler:nil]];
                    [alert showWithSender:nil controller:nil animated:YES completion:nil];
                    
                    if(complete) complete(NO);
                }
            }];
            
        } break;
    }
}

@end
