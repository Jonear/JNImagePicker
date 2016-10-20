//
//  JNImagePickerListTableViewCell.h
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JNIPListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *localizedTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

+ (CGFloat)cellHeight;

@end
