//
//  JNIPGridCollectionViewCell.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Photos/Photos.h>
#import "JNIPAsset.h"
#import "JNImagePickerConfig.h"

@protocol JNIPGridCollectionViewCellDelegate <NSObject>

- (void)overlayButtonPressed:(UIButton *)button withIPAsset:(JNIPAsset *)IPAsset;

@end

@interface JNIPGridCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *overlayButton;
@property (strong, nonatomic) IBOutlet UIView *videoMetaView;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) JNIPAsset              *IPAsset;
@property (weak, nonatomic) id<JNIPGridCollectionViewCellDelegate> cellDelegate;

@property (strong) PHCachingImageManager *imageManager;

- (void)drawViewWithIPAsset:(JNIPAsset *)IPAsset
                   mediaType:(JNImagePickerMediaType)mediaType;

@end
