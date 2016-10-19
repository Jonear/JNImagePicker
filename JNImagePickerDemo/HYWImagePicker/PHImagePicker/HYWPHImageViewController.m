//
//  HYWPHImageViewController.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "HYWPHImageViewController.h"
#import "HYWAssetManager.h"
#import "iToast.h"
#import "HYWImagePickerHelper.h"
#import "PhotoKitAccessor.h"
#import "HYWMacro.h"
#import "HYWIPAssetHelper.h"
#import "HYWImagePickerConfig.h"

#define MAX_IMAGE_COUNT 9

static CGSize AssetGridThumbnailSize;

@interface HYWPHImageViewController ()
<PageViewDataSource,
PageViewDelegate,
UIGestureRecognizerDelegate,
UIActionSheetDelegate,
HYWLargeImageViewDelegate>
{
    UIButton			*rightButton;
    NSInteger			_currentIndex;
    BOOL				_isFullScreen;
    BOOL                _isBeginTask;
    HYWAssetManager		*assetManager;
    BOOL                _isShowSingleImage;
    HYWLargeImageView *_currentLargeImageViewCell;
}

@property (strong, nonatomic) NSArray               *hywIPAssets;
@property (nonatomic, assign) UIStatusBarStyle      statusBarStyle;
@property (nonatomic, assign) BOOL                  isNavigationBarTranslucent;
@property (nonatomic, strong) NSArray               *photoAssets;   // 用来缓存要更新的Assets

@property (strong, nonatomic) IBOutlet PageView                 *largeHorizontalTableView;
@property (strong, nonatomic) IBOutlet UIView                   *footerView;
@property (strong, nonatomic) IBOutlet UIButton                 *hdImageButton;
@property (strong, nonatomic) IBOutlet UIButton                 *sendButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *hdImageIndicator;

@property (strong) AVPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, strong) NSString  *outFilepath;


@property (weak, nonatomic) IBOutlet UIView *sendCountView;
@property (weak, nonatomic) IBOutlet UILabel *sendCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sendCountImageView;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UIView *iCloudView;
@property (weak, nonatomic) IBOutlet UILabel *iCloudLabel;

@end


@implementation HYWPHImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUIComponent];
    [self reloadImageTableView];
    
    AssetGridThumbnailSize = [HYWImagePickerHelper assetGridThumbnailSize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (instancetype)initWithImagePickerConfig:(HYWImagePickerConfig *)imagePickerConfig
                              hywIPAssets:(NSArray *)hywIPAssets
                            objectAtIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _hywIPAssets      = [NSArray arrayWithArray:hywIPAssets];
        _currentIndex   = index;
        
        assetManager    = [HYWAssetManager sharedManager];
        _photoAssets    = [NSArray array];
        _isShowSingleImage = NO;
        _imagePickerConfig = imagePickerConfig;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        HYWIPAsset *hywIPAsset = [[HYWIPAsset alloc] initWithPHAsset:asset];
        hywIPAsset.selected = YES;
        assetManager    = [HYWAssetManager sharedManager];
        assetManager.selectedAssets = [NSMutableArray arrayWithArray:_hywIPAssets];
        
        _hywIPAssets      = @[hywIPAsset];
        _currentIndex   = 0;
        
        _photoAssets    = [NSArray array];
        _isShowSingleImage  = YES;
        HYWImagePickerConfig *config = [[HYWImagePickerConfig alloc] init];
        config.capacity = 1;
        _imagePickerConfig = config;
    }
    return self;
}

- (void)dealloc {
    for (HYWIPAsset *hywIPAsset in _hywIPAssets) {
        [self cancelAssetRequest:hywIPAsset];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _largeHorizontalTableView.dataSource = nil;
    _largeHorizontalTableView.pageViewDelegate = nil;
}

#pragma mark - 初始化
- (void)initUIComponent {
    [self setBarButtonItem];
    
    // HD Image Button
    _hdImageButton.hidden = !_imagePickerConfig.sendHDImage;
    
    
    _playButton.hidden = YES;
    
    _largeHorizontalTableView.dataSource = self;
    _largeHorizontalTableView.pageViewDelegate = self;
    
    [self freshSendButtonTitle];
    [self freshHDImageButtonTitle];
    
    if (_imagePickerConfig.sendTitle.length > 0) {
        [_sendButton setTitle:_imagePickerConfig.sendTitle forState:UIControlStateNormal];
    }
}

- (void)reloadImageTableView
{
    [_largeHorizontalTableView scrollToPage:_currentIndex];
}

- (UIButton *)rightBarButton {
    if (_isShowSingleImage) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0, 0, 46, 40)];
        return button;
    } else {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"image_picker_uncheck"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"image_picker_checked"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"image_picker_checked"] forState:UIControlStateSelected];
        [button setFrame:CGRectMake(0, 0, 46, 40)];
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        
        return button;
    }
}

- (void)setBarButtonItem
{
    // custom navigation bar
    // 这个页面是图片预览，设置不要自动加入ViewInsets
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (_hywIPAssets.count <= 0) {
        return;
    }
    
    // right button
    rightButton = [self rightBarButton];
    [rightButton addTarget:self
                    action:@selector(rightButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark - Actions
- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPressed:(UIButton *)button {
    if (self.largeHorizontalTableView.scrollView.decelerating) {
        return;
    }
    if (_isShowSingleImage) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self resetUIWhenSelected:YES];
    }
}

- (IBAction)sendButtonPressed:(UIButton *)button {
    if (self.largeHorizontalTableView.scrollView.decelerating) {
        return;
    }
    
    if (_hywIPAssets.count <= 0) {
        return;
    }
    
    HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:_currentIndex];
    
    if (hywIPAsset.phAsset.mediaType == PHAssetMediaTypeVideo) {
        
        if (self.playerLayer) {
            [self.playerLayer.player pause];
            [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        }
        
        
        [self saveAssetGroupID];
        
        if (_plImageDelegate && [_plImageDelegate respondsToSelector:@selector(hywPHImageViewController:didFinishPickingImages:)]) {
            [_plImageDelegate hywPHImageViewController:self didFinishPickingVideo:hywIPAsset.phAsset];
        }
        
        
    } else if (hywIPAsset.phAsset.mediaType == PHAssetMediaTypeImage) {
        if ([assetManager.selectedAssets count] <= 0) { // 一张不选直接发送，发送当前图片
            [self resetUIWhenSelected:YES];
        }
        if (_plImageDelegate && [_plImageDelegate respondsToSelector:@selector(hywPHImageViewController:didFinishPickingImages:)]) {
            NSArray *selectedImages = [NSArray arrayWithArray:assetManager.selectedAssets];
            [_plImageDelegate hywPHImageViewController:self didFinishPickingImages:selectedImages];
        }
    }
}



- (IBAction)hdImageButtonPressed:(UIButton *)button {
    if (self.largeHorizontalTableView.scrollView.decelerating) {
        return;
    }
    
    assetManager.isHDImage = !assetManager.isHDImage;
    
    HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:_currentIndex];
    if (!hywIPAsset.selected) {
        [self resetUIWhenSelected:assetManager.isHDImage];
    }
    [self freshHDImageButtonTitle];
}


- (IBAction)playButtonPressed:(id)sender {
    if (self.largeHorizontalTableView.scrollView.decelerating) {
        return;
    }
    
    if (!self.playerLayer) {
        HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:_currentIndex];
        
        
        // 先停止上次的请求
        [self cancelAssetRequest:hywIPAsset];
        
        
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.iCloudLabel.text = [NSString stringWithFormat:@"iCloud同步中 (%.0f%%)", progress*100];
                self.iCloudView.hidden = (progress < 0.0 || progress >= 1.0);
            });
        };
        
        
        hywIPAsset.assetRequestID = [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestAVAssetForVideo:hywIPAsset.phAsset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *error = [info objectForKey:PHImageErrorKey];
                if (error) {
                    self.iCloudLabel.text = @"iCloud无法同步";
                    self.iCloudView.hidden = NO;
                } else if (avAsset) {
                    if (!self.playerLayer) {
                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avAsset];
                        playerItem.audioMix = audioMix;
                        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                        
                        // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
                        
                        
                        UIView *view = [self.largeHorizontalTableView viewAtIndex:_currentIndex];
                        
                        if ([view isKindOfClass:[HYWLargeImageView class]]) {
                            HYWLargeImageView *largeImageViewCell = (HYWLargeImageView *)view;
                            [largeImageViewCell.imageView.layer addSublayer:playerLayer];
                            
                            CALayer *layer = largeImageViewCell.imageView.layer;
                            [playerLayer setFrame:layer.bounds];
                            
                            [player play];
                            
                            [_playButton setTitle:@"暂停" forState:UIControlStateNormal];
                            self.playerLayer = playerLayer;
                        }
                        
                        _isFullScreen = !_isFullScreen;
                        [self showAndHideBar:_isFullScreen];
                    }
                }
            });
        }];
        
    } else {
        if (self.playerLayer.player.rate == 1.0) {
            [self.playerLayer.player pause];
            [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        } else {
            [self.playerLayer.player play];
            [_playButton setTitle:@"暂停" forState:UIControlStateNormal];
            
            _isFullScreen = !_isFullScreen;
            [self showAndHideBar:_isFullScreen];
        }
    }
}

#pragma mark - 视频播放结束通知
- (void)itemDidFinishPlaying:(NSNotification *)notification {
    // Will be called when AVPlayer finishes playing playerItem
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
    [_playButton setTitle:@"播放" forState:UIControlStateNormal];
    
    _isFullScreen = NO;
    [self showAndHideBar:_isFullScreen];
}


#pragma mark - Private Methods


- (void)saveAssetGroupID {
//#warning huangyaowu
//    [[ConfigManager sharedManager] setAssetsGroupID:assetManager.assetsGroupID];
}
- (void)renderSendView:(NSInteger)count {
    _sendCountView.hidden = count == 0;
    if (count > 0) {
        _sendCountLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    }
}

- (void)resetUIWhenSelected:(BOOL)selected {
    if (selected) {
        HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:_currentIndex];
        if (!hywIPAsset.selected) {
            if ([assetManager.selectedAssets count] >= _imagePickerConfig.capacity) {
                [_hdImageIndicator stopAnimating];
                NSString *tip = nil;
                if (self.imagePickerConfig.tip.length > 0) {
                    tip = self.imagePickerConfig.tip;
                } else {
                    tip = [NSString stringWithFormat:@"你最多只能选择%@张相片", @(_imagePickerConfig.capacity)];
                }
                
                iToast *toast = [iToast makeToast:NSLocalizedString(tip, nil)];
                [toast showAt:kToastPositionCenter duration:1.5];
                return;
            }
        }
        
        if ([assetManager.selectedAssets count] == 0) {
            hywIPAsset.selected = YES;
            [assetManager.selectedAssets addObject:hywIPAsset];
        } else {
            HYWIPAsset *item = [HYWImagePickerHelper selectedAsset:hywIPAsset];
            if (item) {
                hywIPAsset.selected = NO;
                [assetManager.selectedAssets removeObject:item];
            } else {
                hywIPAsset.selected = YES;
                [assetManager.selectedAssets addObject:hywIPAsset];
            }
        }
        
        [rightButton setSelected:hywIPAsset.selected];
        
        
        [self freshSendButtonTitle];
    }
}

- (void)freshSendButtonTitle {
    if (_isShowSingleImage) {
        return;
    }
    NSInteger count = [assetManager.selectedAssets count];
    [self renderSendView:count];
}

- (void)freshHDImageButtonTitle {
    [_hdImageIndicator stopAnimating];
    
    if (_currentIndex >= [self.hywIPAssets count]) {
        _hdImageButton.hidden = YES;
        return;
    }
    
    HYWIPAsset *hywIPAsset = [self.hywIPAssets objectAtIndex:_currentIndex];
    
    [_hdImageButton setSelected:assetManager.isHDImage];
    if (assetManager.isHDImage) {
        if (hywIPAsset.dataSize.length > 0) {
            [_hdImageButton setTitle:hywIPAsset.dataSize forState:UIControlStateNormal];
            [_hdImageButton setTitle:hywIPAsset.dataSize forState:UIControlStateSelected];
        }
        else {
            [_hdImageButton setTitle:@" 原图" forState:UIControlStateNormal];
            [_hdImageButton setTitle:@" 原图" forState:UIControlStateSelected];
            [_hdImageButton setUserInteractionEnabled:NO];
            [_hdImageIndicator startAnimating];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageDataForAsset:hywIPAsset.phAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    //Get bytes size of image
                    long long imageSize = imageData.length;
                    
                    float totalSize = imageSize/1024;
                    NSString *title = nil;
                    if (totalSize > 1024) {
                        title = [NSString stringWithFormat:@" 原图(%.1fM)", totalSize/1024];
                    }
                    else {
                        title = [NSString stringWithFormat:@" 原图(%.fKB)", totalSize];
                    }
                    hywIPAsset.dataSize = title;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_hdImageButton setTitle:title forState:UIControlStateNormal];
                        [_hdImageButton setTitle:title forState:UIControlStateSelected];
                        [_hdImageButton setUserInteractionEnabled:YES];
                        [_hdImageIndicator stopAnimating];
                    });
                }];
            });
        }
    } else {
        [_hdImageButton setTitle:@" 原图" forState:UIControlStateNormal];
        [_hdImageButton setTitle:@" 原图" forState:UIControlStateSelected];
        [_hdImageIndicator stopAnimating];
    }
}

- (void)cancelAssetRequest:(HYWIPAsset *)hywIPAsset {
    if (!hywIPAsset) {
        return;
    }
    if (hywIPAsset.assetRequestID != PHInvalidImageRequestID) {
        [[[PhotoKitAccessor sharedInstance] phCachingImageManager] cancelImageRequest:hywIPAsset.assetRequestID];
        hywIPAsset.assetRequestID = PHInvalidImageRequestID;
    }
}

#pragma mark - PageViewDatasource
- (NSInteger)numberOfPages: (PageView *)pageView {
    return [_hywIPAssets count];
}

- (UIView *)pageView:(PageView *)pageView viewInPage:(NSInteger)index {
    HYWLargeImageView *largeImageViewCell = [[HYWLargeImageView alloc] initWithFrame:pageView.bounds];
    largeImageViewCell.gapWidth = kHYWLargeImageGapWidth;
    largeImageViewCell.delegate = self;
    
    HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:index];
    
    if (hywIPAsset != nil) {
        [self loadBigImage:hywIPAsset imageView:largeImageViewCell];
    }
    
    return largeImageViewCell;
}

#pragma mark - PageViewDelegate
- (void)pageViewScrollEnd:(PageView *)pageView
             currentIndex:(NSInteger)index
               totolPages:(NSInteger)pages {
    if (_hywIPAssets.count <= 0) {
        return;
    }
    
    _currentIndex = index;
    
    [self freshHDImageButtonTitle];
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    
    
    HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:index];
    
    if (!hywIPAsset) {
        return;
    }
    
    [rightButton setSelected:hywIPAsset.selected];
    
    
    if (hywIPAsset.phAsset.mediaType == PHAssetMediaTypeVideo) {
        _hdImageButton.hidden = YES;
        
        rightButton.hidden = YES;
        
        _playButton.hidden = NO;
        
        self.navigationItem.title = NSLocalizedString(@"视频预览", @"");
        
        _sendView.hidden = NO;
        
        [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestAVAssetForVideo:hywIPAsset.phAsset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            if (!avAsset) {
                _sendView.hidden = YES;
            }
        }];
        
        
    } else if (hywIPAsset.phAsset.mediaType == PHAssetMediaTypeImage) {
        
        _playButton.hidden = YES;
        self.navigationItem.title = @"";
        
        
        UIView *view = [pageView viewAtIndex:index];
        if ([view isKindOfClass:[HYWLargeImageView class]]) {
            HYWLargeImageView *cell = (HYWLargeImageView *)view;
            if (cell.imageView.image) {
                rightButton.hidden = NO;
                _hdImageButton.hidden = !_imagePickerConfig.sendHDImage;
                
                
                _sendView.hidden = NO;
            } else {
                rightButton.hidden = YES;
                _hdImageButton.hidden = YES;
                
                
                _sendView.hidden = YES;
            }
        }
    }
    
}

- (void)loadBigImage:(HYWIPAsset *)hywIPAsset imageView:(HYWLargeImageView *)view {
    if (!hywIPAsset) {
        return;
    }
    
    /**
     *  先假装一个小图，这个小图在相片列表页请求过。
     *  这主要是为了解决加载同步到iCloud上的相片，需要下载大图，一般比较慢，比较模糊。
     */
    UIImage *resultImage = [HYWIPAssetHelper thumbnailWithPHAsset:hywIPAsset.phAsset];
    if (resultImage) {
        view.imageView.image = resultImage;
    }
    /**
     *  异步下载大图
     *  这个优化在显示本地图片的时候有用，不要采用同步的方式。
     */
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    hywIPAsset.assetRequestID = [[[PhotoKitAccessor sharedInstance] phCachingImageManager] requestImageForAsset:hywIPAsset.phAsset targetSize:CGSizeMake(UIScreenWidth*1.5, UIScreenHeight*1.5) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (result && ![info[PHImageResultIsDegradedKey] boolValue]) {
            view.imageView.image = result;
            /**
             *  大图加载到的时候取消改图的请求
             */
            [self cancelAssetRequest:hywIPAsset];
        }
    }];
}

- (void)pageView:(PageView *)pageView didEndDisplayingAtIndex:(NSInteger)index {
    HYWIPAsset *hywIPAsset = [_hywIPAssets objectAtIndex:index];
    [self cancelAssetRequest:hywIPAsset];
}


#pragma mark - LargeImageViewDelegate
- (void)onTouch:(HYWLargeImageView *)cell {
    _isFullScreen = !_isFullScreen;
    [self showAndHideBar:_isFullScreen];
}

- (void)showAndHideBar:(BOOL)state {
    [[UIApplication sharedApplication] setStatusBarHidden:state];
    _footerView.hidden = state;
    self.navigationController.navigationBar.hidden = state;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return _isFullScreen;
}

#pragma mark - UIViewController override
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
