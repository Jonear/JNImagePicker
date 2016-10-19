//
//  ALAssetsLibraryAccessor.h
//  yixin_iphone
//
//  Created by huangyaowu on 13-7-2.
//  Copyright (c) 2013年 Netease. All rights reserved.
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
