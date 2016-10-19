//
//  HYWIPGridCollectionViewCell.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "HYWIPGridCollectionViewCell.h"
#import "HYWImagePickerHelper.h"
#import "PhotoKitAccessor.h"

@implementation HYWIPGridCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [_overlayButton addTarget:self action:@selector(overlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)drawViewWithHYWIPAsset:(HYWIPAsset *)hywIPAsset
                   mediaType:(ImagePickerMediaType)mediaType {
    
    self.hywIPAsset = hywIPAsset;
    
    if (mediaType == kImagePickerMediaTypeAll) {
        
        PHAsset *asset = hywIPAsset.phAsset;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            [self.videoMetaView setHidden:NO];
            [self.overlayButton setHidden:YES];
            
            NSInteger duration = round(asset.duration);
            int min = (int)(duration/60);
            int seconds = (int)(duration - 60*min);
            self.durationLabel.text = [NSString stringWithFormat:@"%i:%02i", min, seconds];
        } else {
            [self.videoMetaView setHidden:YES];
            [self.overlayButton setHidden:NO];
            self.durationLabel.text = nil;
        }
    }
    else {
        [self.videoMetaView setHidden:YES];
        [self.overlayButton setHidden:NO];
    }
    
    
    PHImageManager *imageManager = [[PhotoKitAccessor sharedInstance] phCachingImageManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    
    CGSize targetSize = [HYWImagePickerHelper assetGridThumbnailSize];
    hywIPAsset.assetRequestID = [imageManager requestImageForAsset:hywIPAsset.phAsset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                hywIPAsset.isInTheCloud = NO;
            } else {
                hywIPAsset.isInTheCloud = YES;
            }
            
            [self.imageView setImage:result];
        });
    }];
    
    [self.overlayButton setSelected:hywIPAsset.selected];
}

- (void)overlayButtonPressed:(UIButton *)button {
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(overlayButtonPressed:withHYWIPAsset:)]) {
        [self.cellDelegate overlayButtonPressed:button withHYWIPAsset:self.hywIPAsset];
    }
}

@end
