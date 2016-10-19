//
//  UIImagePickerController+DoModal.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "UIImagePickerController+DoModal.h"
#import "AppDelegate.h"
#import "PrivacyHelper.h"

@implementation UIImagePickerController (DoModal)

- (void)doModelAfterCheckPricacy:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self customNavigationBar];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *leafController = delegate.window.rootViewController;
    while (leafController.presentedViewController)
    {
        leafController = leafController.presentedViewController;
    }
    if (leafController)
    {
        if (![self isBeingPresented])
        {
            [leafController presentViewController:self
                                         animated:animated
                                       completion:nil];
        }
    }
    else
    {
        assert(0);
    }
    
}
- (void)doModal: (BOOL)animated
{
    if (self.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [PrivacyHelper checkAlbumPrivacy:YES onComplete:^(BOOL haveAuthorization)
         {
             if(haveAuthorization)
             {
                 [self doModelAfterCheckPricacy:animated];
             }
         }];
    }
    else
    {
        //查看了代码，Camera都是在外面检查，即检查了有权限才doModal,是因为弹窗会影响摄像头吗？
        [self doModelAfterCheckPricacy:animated];
    }
}

- (void)customNavigationBar
{
    [self.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
    
}

@end
