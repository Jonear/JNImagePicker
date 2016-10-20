//
//  AVAssetExportHelper.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVAssetExportHelper : NSObject

+ (void)sessionWithInputURL:(NSURL*)inputURL
                  outputURL:(NSURL*)outputURL
               blockHandler:(void (^)(AVAssetExportSession*))handler;

+ (void)sessionWithAVURLAsset:(AVAsset *)asset
                    outputURL:(NSURL *)outputURL
                 blockHandler:(void (^)(AVAssetExportSession*))handler;

@end


