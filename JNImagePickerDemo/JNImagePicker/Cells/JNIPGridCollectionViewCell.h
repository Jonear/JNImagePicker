//
//  JNIPGridCollectionViewCell.h
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/11.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Photos/Photos.h>
#import "JNIPAsset.h"
#import "JNImagePickerConfig.h"

@protocol JNIPGridCollectionViewCellDelegate <NSObject>

- (void)overlayButtonPressed:(UIButton *)button withHYWIPAsset:(JNIPAsset *)hywIPAsset;

@end

@interface JNIPGridCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *overlayButton;
@property (strong, nonatomic) IBOutlet UIView *videoMetaView;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) JNIPAsset              *hywIPAsset;
@property (weak, nonatomic) id<JNIPGridCollectionViewCellDelegate> cellDelegate;

@property (strong) PHCachingImageManager *imageManager;

- (void)drawViewWithHYWIPAsset:(JNIPAsset *)hywIPAsset
                   mediaType:(ImagePickerMediaType)mediaType;

@end
