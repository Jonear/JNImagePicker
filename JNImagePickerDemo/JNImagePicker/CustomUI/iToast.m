//
//  iToast.m
//  eim_iphone
//
//  Created by zhou jezhee on 11/21/12.
//  Copyright (c) 2012 Netease. All rights reserved.
//

#import "iToast.h"

const NSInteger     kToastMaxWidth          = 170;
const NSInteger     kToastMaxHeight         = 480;
const NSInteger     kToastLabelPadding      = 20;
const NSInteger     kToastPositionPadding   = 10;



@interface iToastManager : NSObject
@property (nonatomic,strong)    iToast  *currentToast;
+ (iToastManager *)sharedManager;
@end

@interface iToast ()
{
    UIView          *_toastView;
    BOOL            _isClosing;
}
@property (nonatomic,assign)    ToastPosition   position;


@end


@implementation iToast


- (id)initWithText:(NSString *)text
{
    self = [super init];
    if (self)
    {
        self.toastText = text;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChanged:)
                                                     name: UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)onDeviceOrientationChanged:(NSNotification *)aNotification
{
    _toastView.transform = [self transformForView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (iToast *)makeToast:(NSString *)text
{
    iToast *toast = [[iToast alloc]initWithText:text];
    return toast;
}


- (void)showAt:(ToastPosition)position duration:(double)duration
{
    [[[iToastManager sharedManager] currentToast] dismiss:NO];
    [[iToastManager sharedManager] setCurrentToast:self];

    _position = position;
    [self initUIComponents:^(UIView *toastView)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];

        CGPoint screenCenter = CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
        CGPoint center = screenCenter;
        if (kToastPositionTop == position)
        {
            center.y = kToastPositionPadding + 64 + toastView.bounds.size.height/2; //位于导航栏下10px处
        }
        else if (kToastPositionBottom == position)
        {
            center.y = screenRect.size.height - toastView.bounds.size.height/2 - kToastPositionPadding;
        }
        [toastView setCenter:center];
        
        toastView.transform = [self transformForView];
        
        toastView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin;
        
    }];
    [NSTimer scheduledTimerWithTimeInterval:duration
                                     target:self
                                   selector:@selector(onBlinkToast:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)showAtCenter:(CGPoint)center duration:(double)duration
{
    [self showAt:kToastPositionCenter
        duration:duration];
}

- (void)onBlinkToast: (NSTimer *)timer
{
    [self dismiss:YES];
}


- (void)dismiss: (BOOL)animated
{
    if (_isClosing)
    {
        return;
    }
    _isClosing = YES;
    typedef void(^CompleteBlock)();
    
    CompleteBlock block = ^(){
        [_toastView removeFromSuperview];
        _isClosing = NO;
        if (self == [[iToastManager sharedManager] currentToast])
        {
             [[iToastManager sharedManager] setCurrentToast:nil];
        }
    };
    
    
    if (animated)
    {
        [UIView animateWithDuration:0.1f animations:^{
            _toastView.alpha = 0;
        } completion:^(BOOL finished)
         {
             block();
         }];
    }
    else
    {
        block();
    }
}

- (void)initUIComponents: (void (^)(UIView *))adjustPositionBlock
{
    UIFont *font   = [UIFont systemFontOfSize:14];
    CGSize textSize= [_toastText boundingRectWithSize:CGSizeMake(kToastMaxWidth, kToastMaxHeight) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width + 2 * kToastLabelPadding,
                                                              textSize.height + 2 * kToastLabelPadding)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
	label.font = font;
	label.text = _toastText;
	label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake(0, 0, textSize.width + 2 * kToastLabelPadding, textSize.height + 2 * kToastLabelPadding);
	label.center = CGPointMake(button.bounds.size.width / 2, button.bounds.size.height / 2);
	[button addSubview:label];
	button.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
	button.layer.cornerRadius = 5;
    _toastView = button;
    
    //逆序拿到第一个显示的window
    UIWindow *window = [self attachedWindow];

    adjustPositionBlock(_toastView);
    [window addSubview:_toastView];
}


- (UIWindow *)attachedWindow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    return window;
}

- (CGAffineTransform)transformForView
{
    //目前只对Center的情况做旋转，其他情况先54
    CGAffineTransform transform = _toastView ? _toastView.transform : CGAffineTransformIdentity;
    if (kToastPositionCenter == _position)
    {
        UIInterfaceOrientation orientation =  [[UIApplication sharedApplication] statusBarOrientation];
        transform = [self rotationForInterfaceOrientation:orientation];
    }
    return transform;
}
// 解决iOS8加载到key-windows上的toastView旋转失效问题http://qiita.com/dokubeko/items/e040696f39f9d1df7d60
- (CGAffineTransform)rotationForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // iOS 8
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)) {
        return CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    }
    
    // iOS 5, 6, 7
    CGFloat __angle[4] = {0, 180.0f, 90.0f, 270.0f};
    NSInteger __index = interfaceOrientation - 1;
    CGAffineTransform __rotation = CGAffineTransformMakeRotation(__angle[__index] * M_PI / 180.0f);
    
    return __rotation;
}
@end


@implementation iToastManager
+ (iToastManager *)sharedManager
{
    static iToastManager *instance = nil;
    if (!instance)
    {
        instance = [[iToastManager alloc]init];
    }
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}
@end
