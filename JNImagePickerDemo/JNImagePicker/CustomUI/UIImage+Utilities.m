//
//  UIImage+Utilities.m
//  yixin_iphone
//
//  Created by zqf on 13-1-18.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "UIImage+Utilities.h"
//#import <vector>
//#import "YixinDevice.h"

//static std::vector<std::vector<CGPoint> > *offsets = 0;
//
//void CalculateBoxStyle(NSArray *images,CGFloat &boxSize,std::vector<CGPoint> **vt)
//{
//    const CGFloat kMutiBoxSize  = 0.54;
//    const CGFloat kOneBoxSize   = 1.0;
//    NSInteger count = [images count];
//    if (count >= 3)
//    {
//        boxSize = kMutiBoxSize;
//    }
//    else
//    {
//        boxSize = kOneBoxSize;
//    }
//    
//    if (offsets == 0)
//    {
//
//        const CGFloat kPadding = 0.01; //防止圆形切边
//        //一张头像的布局
//        std::vector<CGPoint> one;
//        one.push_back(CGPointMake(0,0));
//        
//        //三张图形的布局
//        std::vector<CGPoint> three;
//        three.push_back(CGPointMake(kPadding ,(1-kPadding*2-kMutiBoxSize)));
//        three.push_back(CGPointMake((1-kPadding-kMutiBoxSize),(1-kPadding*2-kMutiBoxSize)));
//        three.push_back(CGPointMake((1-kPadding-kMutiBoxSize)/2,kPadding*3));
//        
//        offsets = new std::vector<std::vector<CGPoint> >();
//        offsets->push_back(one);
//        offsets->push_back(three);
//    }
//    if (images.count == 1) {
//        *vt = &(*offsets)[0];
//    }else{
//        *vt = &(*offsets)[1];
//    }
//}



@implementation UIImage (Util)

- (UIImage *)drawImageWithSize: (CGSize)size
{
    CGSize drawSize = CGSizeMake(floor(size.width), floor(size.height));
    UIGraphicsBeginImageContext(drawSize);
    
    [self drawInRect:CGRectMake(0, 0, drawSize.width, drawSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaleWithMaxPixels: (CGFloat)maxPixels
{
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    if (width * height < maxPixels || maxPixels == 0)
    {
        return self;
    }
    CGFloat ratio = sqrt(width * height / maxPixels);
    if (fabs(ratio - 1) <= 0.01)
    {
        return self;
    }
    CGFloat newSizeWidth = width / ratio;
    CGFloat newSizeHeight= height/ ratio;
    return [self scaleToSize:CGSizeMake(newSizeWidth, newSizeHeight)];
}
//内缩放，一条变等于最长边，另外一条小于等于最长边
- (UIImage *)scaleToSize:(CGSize)newSize
{
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    CGFloat newSizeWidth = newSize.width;
    CGFloat newSizeHeight= newSize.height;
    if (width <= newSizeWidth &&
        height <= newSizeHeight)
    {
        return self;
    }
    
    if (width == 0 || height == 0 || newSizeHeight == 0 || newSizeWidth == 0)
    {
        return nil;
    }
    CGSize size;
    if (width / height > newSizeWidth / newSizeHeight)
    {
        size = CGSizeMake(newSizeWidth, newSizeWidth * height / width);
    }
    else
    {
        size = CGSizeMake(newSizeHeight * width / height, newSizeHeight);
    }
    return [self drawImageWithSize:size];
}

//采用外缩放：一遍等于请求长度，一遍大于等于请求长度
- (UIImage *)externalScaleSize: (CGSize)scaledSize
{
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    CGFloat newSizeWidth = scaledSize.width;
    CGFloat newSizeHeight= scaledSize.height;
    if (width < newSizeWidth || height < newSizeHeight)
    {
        return self;
    }
    if (width == 0 || height == 0)
    {
        return nil;
    }
    CGSize size;
    if (width / height > newSizeWidth / newSizeHeight)
    {
        size = CGSizeMake(newSizeHeight * width / height, newSizeHeight);
    }
    else
    {
        size = CGSizeMake(newSizeWidth, newSizeWidth * height / width);
    }
    return [self drawImageWithSize:size];

}
///**
// * 只为会话界面做的大小
// */
//- (UIImage *)thumbForSession
//{
//    return [self externalScaleSize:CGSizeMake(320, 320)];
//}

- (UIImage *)thumb
{
    /*原来是 150 * 150的*/
    return [self externalScaleSize:CGSizeMake(300, 300)];
}
- (UIImage *)thumbForSocialShare
{
    return [self externalScaleSize:CGSizeMake(150, 150)];
}
- (UIImage *)thumbForSNS: (NSInteger)count
{
    if (count <= 1)
    {
        return [self externalScaleSize:CGSizeMake(400, 400)];
    }
    return [self externalScaleSize:CGSizeMake(200, 200)];
}


- (UIImage *)makeImageRounded
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGRect rect =  CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.size.width*0.5] addClip];
    
    [self drawInRect:rect];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//- (BOOL)saveToFilepath: (NSString *)filepath
//{
//    CGFloat compressQuality = [[YixinDevice currentDevice] compressQuality];
//    NSData *data = UIImageJPEGRepresentation(self, compressQuality);
//    return [data length] && [data writeToFile:filepath atomically:YES];
//}

- (BOOL)saveToFilepathWithFullQuality:(NSString *)filepath
{
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    return [data length] && [data writeToFile:filepath atomically:YES];
}

- (BOOL)saveToFilepathWithPng:(NSString*)filepath
{
    NSData *data = UIImagePNGRepresentation(self);
    return [data length] && [data writeToFile:filepath atomically:YES];
}

#define teamAvatarCount 3
#define defaultTeamAvatarImage [UIImage imageNamed:@"avatar_defaultempty_icon"]
//+ (UIImage *)mergeImagesToBoxStyle: (NSArray *)images
//{
//    CGFloat imageSize = 104;
//    NSInteger count = [images count];
//    NSArray * imageData;
//    switch (count) {
//        case 0:
//            return nil;  //显示默认头像
//            break;
//        case 1:
//            imageData = @[defaultTeamAvatarImage,
//                                     defaultTeamAvatarImage,
//                                     [images objectAtIndex:0]];    //顶部显示头像，两侧显示默认头像
//            break;
//        case 2:
//            imageData = @[[images objectAtIndex:1],
//                                     defaultTeamAvatarImage,
//                                     [images objectAtIndex:0]];   //顶部，左侧显示头像，右侧显示默认头像
//            break;
//        case 3:
//            imageData = images;
//            break;
//        default:
//            return nil;
//    }
//    CGFloat size;
//    std::vector<CGPoint> *vt = 0;
//    CalculateBoxStyle(imageData,size,&vt);
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize),NO,0);
//    [[UIColor clearColor] setFill];
//    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize, imageSize)] fill];
//    for (NSInteger i = 0; i < teamAvatarCount; i++)
//    {
//        CGFloat x       = ((*vt)[i]).x;
//        CGFloat y       = ((*vt)[i]).y;
//        CGFloat width   = size;
//        CGFloat height  = size;
//        CGRect avatarBg = CGRectMake(x * imageSize, y * imageSize,
//                                     width * imageSize, height * imageSize);
//        CGRect avatar     = CGRectInset(avatarBg, 2, 2);
//        UIImage *image  = [imageData objectAtIndex:i];
//        
//        //绘制白色背景
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        
//        
//        CGContextSaveGState(context);
//        CGPathRef  path = [UIBezierPath bezierPathWithRoundedRect:avatarBg
//                                          cornerRadius:CGRectGetWidth(avatarBg) / 2]. CGPath;
//        
//        
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        
//        
////        [[UIColor whiteColor] setFill];
////        CGContextFillRect(context, avatarBg);
//        CGContextClearRect(context, avatarBg);
//        
//        CGContextRestoreGState(context);
//        
//        
//        
//        
//        
//        //绘制头像
//        CGContextSaveGState(context);
//        path = [UIBezierPath bezierPathWithRoundedRect:avatar
//                                                     cornerRadius:CGRectGetWidth(avatar) / 2]. CGPath;
//        CGContextAddPath(context, path);
//        CGContextClip(context);
//        [image drawInRect:avatar];
//        CGContextRestoreGState(context);
//        
//    }
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

/**
 * 获取圆形的图片
 */
- (UIImage *)circleImage
{
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    
    CGContextSetLineWidth(context,1/[UIScreen mainScreen].scale);
    
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width , self.size.height);
    CGRect rect2 = CGRectMake(0, 0, self.size.width , self.size.height );
    
    CGContextAddEllipseInRect(context, rect2);
    
    CGContextClip(context);
    
    
    [self drawInRect:rect];
    CGContextStrokePath(context);

    UIImage *new_image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return new_image;
    
}

- (UIImage *)resizableImageWithCapInsetsForStretch:(UIEdgeInsets)capInsets
{
    return [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}
@end
