//
//  UIImagePickerController+Block.m
//  JNImagePicker
//
//  Created by Jonear on 15/1/9.
//  Copyright (c) 2015年 Jonear. All rights reserved.
//

#import "UIImagePickerController+Block.h"
#import "UIImagePickerController+DoModal.h"
#import "PrivacyHelper.h"

typedef void(^UIImagePickerManagerBlock)(NSDictionary *info);
typedef void(^UIImagePickerManagerCancelBlock)();

@interface UIImagePickerManager : NSObject
<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, copy) UIImagePickerManagerBlock managerBlock;
@property (nonatomic, copy) UIImagePickerManagerCancelBlock managerCancelBlock;

@end

@implementation UIImagePickerManager

+ (id)sharedCenter {
    static UIImagePickerManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UIImagePickerManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    _managerBlock = nil;
    _managerCancelBlock = nil;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
    UIImagePickerManagerBlock block = manager.managerBlock;
    manager.managerBlock = nil;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (block) {
            block(info);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
    UIImagePickerManagerCancelBlock block = manager.managerCancelBlock;
    manager.managerCancelBlock = nil;
    
    [[UIImagePickerManager sharedCenter] setManagerBlock:nil];
    
    //http://stackoverflow.com/questions/26844432/how-to-find-out-what-causes-a-didhidezoomslider-error-on-ios-8/29959695#29959695
    // ios 8上面拍照,如果进行缩放界面拍照，会导致崩溃的问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            if (block) {
                block();
            }
        }];
    });


}

@end




@implementation UIImagePickerController (Block)

+ (void)imagePickerWithFinishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    
    [UIImagePickerController imagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera
                                         allowsEditing:NO
                                           finishBlock:finishBlock];
}

+ (void)imagePickerWithFinishBlock:(UIImagePickerControllerFinishBlock)finishBlock useFrontCamera:(BOOL)useFrontCamera
{
    BOOL isSourceTypeCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL haveAuthorization  = [PrivacyHelper checkCameraPrivacy:YES];
    
    if (isSourceTypeCamera && haveAuthorization) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType       = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing    = NO;
        picker.cameraDevice = (useFrontCamera && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
        
        UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
        UIImagePickerControllerFinishBlock block = [finishBlock copy];
        finishBlock = nil;
        manager.managerBlock = block;
        picker.delegate = manager;
        
        [picker doModal:YES];
    
    }
}

+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    
    [UIImagePickerController imagePickerWithSourceType:sourceType
                                         allowsEditing:NO
                                           finishBlock:finishBlock];
}

+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                    allowsEditing:(BOOL)allowsEditing
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        BOOL isSourceTypeCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        BOOL haveAuthorization  = [PrivacyHelper checkCameraPrivacy:YES];
        
        if (isSourceTypeCamera && haveAuthorization) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType       = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing    = allowsEditing;
            
            UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
            UIImagePickerControllerFinishBlock block = [finishBlock copy];
            finishBlock = nil;
            manager.managerBlock = block;
            picker.delegate = manager;
            
            [picker doModal:YES];
            
            
        }
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing    = allowsEditing;
        
        UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
        UIImagePickerControllerFinishBlock block = [finishBlock copy];
        finishBlock = nil;
        manager.managerBlock = block;
        picker.delegate = manager;
        
        [picker doModal:YES];
        
      
    }
}

+ (void)imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                    allowsEditing:(BOOL)allowsEditing
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock
                      cancelBlock:(UIImagePickerControllerCancelBlock) cancelBlock {
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        BOOL isSourceTypeCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        BOOL haveAuthorization  = [PrivacyHelper checkCameraPrivacy:YES];
        
        if (isSourceTypeCamera && haveAuthorization) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType       = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing    = allowsEditing;
            
            UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
            UIImagePickerControllerFinishBlock block = [finishBlock copy];
            UIImagePickerControllerFinishBlock cblock = [cancelBlock copy];
            finishBlock = nil;
            cancelBlock = nil;
            manager.managerBlock = block;
            manager.managerCancelBlock = cblock;
            picker.delegate = manager;
            
            [picker doModal:YES];
            
            
        }
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing    = allowsEditing;
        
        UIImagePickerManager *manager = [UIImagePickerManager sharedCenter];
        UIImagePickerControllerFinishBlock block = [finishBlock copy];
        UIImagePickerControllerFinishBlock cblock = [cancelBlock copy];
        finishBlock = nil;
        cancelBlock = nil;
        manager.managerBlock = block;
        manager.managerCancelBlock = cblock;
        picker.delegate = manager;
        
        [picker doModal:YES];
    }
}




@end
