//
//  ALAssetsLibraryAccessor.h
//  JNImagePicker
//
//  Created by Jonear on 13-7-2.
//  Copyright (c) 2013年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAssetsLibrary;

@interface ALAssetsLibraryAccessor : NSObject {
    ALAssetsLibrary *assetsLibrary_;
}

+ (ALAssetsLibraryAccessor *)sharedInstance;

- (ALAssetsLibrary *)assetsLibrary;

- (void)refreshAssetsLibrary;

@end
