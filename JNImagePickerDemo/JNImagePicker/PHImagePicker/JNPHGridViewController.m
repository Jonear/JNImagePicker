//
//  JNPHGridViewController.m
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import "JNPHGridViewController.h"
#import "JNIPGridCollectionViewCell.h"
#import "JNPHImageViewController.h"
#import "iToast.h"
#import "JNImagePickerHelper.h"
#import "JNPHListViewController.h"
#import "JNAssetManager.h"
#import "PhotoKitAccessor.h"

static NSString * const JNIPGridCollectionViewCellReuseIdentifier = @"JNIPGridCollectionViewCelldentifier";
static NSUInteger const minimumSpacing = 2.0f;
static NSUInteger const VIEW_COUNT_PER_CELL = 4.0f;
static CGSize AssetGridThumbnailSize;

//Helper methods
@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end
@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@interface JNPHGridViewController () <PHPhotoLibraryChangeObserver,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
JNIPGridCollectionViewCellDelegate,
JNPHImageViewControllerDelegate>
{
    JNAssetManager *assetManager;
    BOOL _didAppear;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIButton     *previewButton;
@property (strong, nonatomic) IBOutlet UIButton     *sendButton;

@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;

@property (nonatomic, strong) JNImagePickerConfig   *imagePickerConfig;
@property (strong, nonatomic) ALAssetsGroup         *assetsGroup;

@property (strong, nonatomic) NSMutableArray *photoAssets;
@property (weak, nonatomic) IBOutlet UIView *sendCountView;
@property (weak, nonatomic) IBOutlet UILabel *sendCountLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIImageView *sendCountImageView;

@end

@implementation JNPHGridViewController

- (instancetype)initWithImagePickerConfig:(JNImagePickerConfig *)imagePickerConfig
{
    self = [super init];
    if (self) {
        self.imagePickerConfig = imagePickerConfig;
        AssetGridThumbnailSize = [JNImagePickerHelper assetGridThumbnailSize];
        
        _photoAssets = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    assetManager = [JNAssetManager sharedManager];
    
    self.imageManager = [[PhotoKitAccessor sharedInstance] phCachingImageManager];
    [self resetCachedAssets];
    
    [self initUIComponent];
    
    for (NSInteger i = 0; i < self.assetsFetchResults.count; i++) {
        PHAsset *asset = self.assetsFetchResults[i];
        JNIPAsset *IPAsset = [[JNIPAsset alloc] initWithPHAsset:asset];
        [_photoAssets addObject:IPAsset];
    }
    //    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
    if (!_isScrollToBottom) {
        return;
    }
    _isScrollToBottom = !_isScrollToBottom;
    
    
    NSInteger section = [_collectionView numberOfSections] - 1;
    NSInteger item = [_collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _didAppear = YES;
    [self updateCachedAssets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_collectionView reloadData];
    [self freshSendButtonTitle];
}

- (void)freshSendButtonTitle {
    NSInteger count = [assetManager.selectedAssets count];
    [self renderSendView:count];
    
    [_sendButton setEnabled:count > 0];
    [_previewButton setEnabled:count > 0];
}

- (void)dealloc
{
    [self resetCachedAssets];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化
- (void)initUIComponent {
    [self initContentView];
    [self setBarButtonItem];
    [self setButtonOfFooterView];
    
    if (_imagePickerConfig.sendTitle.length > 0) {
        [_sendButton setTitle:_imagePickerConfig.sendTitle forState:UIControlStateNormal];
    }
}


- (void)initContentView {
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = minimumSpacing;
    flowLayout.minimumLineSpacing = minimumSpacing;
    
    _collectionView.collectionViewLayout = flowLayout;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = YES;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"JNIPGridCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:JNIPGridCollectionViewCellReuseIdentifier];
    
}
- (void)setBarButtonItem
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}
- (void)setButtonOfFooterView {
    [_previewButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [_previewButton setTitleColor:[[UIColor greenColor] colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
}

#pragma mark - Actions
- (void)cancelButtonPressed:(id)sender
{
    if (_plGridDelegate) {
        if ([_plGridDelegate respondsToSelector:@selector(JNPHGridViewControllerDidCancel:)]) {
            [_plGridDelegate JNPHGridViewControllerDidCancel:self];
        }
    }
}

- (IBAction)previewButtonPressed:(id)sender
{
    if ([assetManager.selectedAssets count] <= 0) {
        return;
    }
    
    JNPHImageViewController *imageViewController = [[JNPHImageViewController alloc] initWithImagePickerConfig:_imagePickerConfig IPAssets:assetManager.selectedAssets objectAtIndex:0];
    imageViewController.plImageDelegate = self;
    
    [self.navigationController pushViewController:imageViewController animated:YES];
}
- (IBAction)sendButtonPressed:(id)sender
{
    [self handelImagesForSend];
}

#pragma mark - Private Methods
- (void)showICloudAlertWithIPAsset:(JNIPAsset *)IPAsset {
    if (IPAsset.phAsset.mediaType == PHAssetMediaTypeImage) {
//        [YixinUtil showAlert:@"" content:@"正在从iCloud同步照片"];
    } else if (IPAsset.phAsset.mediaType == PHAssetMediaTypeVideo) {
//        [YixinUtil showAlert:@"" content:@"正在从iCloud同步视频"];
    } else {
//        [YixinUtil showAlert:@"" content:@"正在从iCloud同步"];
    }
}
- (void)renderSendView:(NSInteger)count {
    _sendCountView.hidden = count == 0;
    _sendCountLabel.text = [NSString stringWithFormat:@"%@", @(count)];
}
- (void)saveAssetGroupID
{
//#warning Jonear
//    [[ConfigManager sharedManager] setAssetsGroupID:assetManager.assetsGroupID];
}
- (void)handelImagesForSend
{
    if ([assetManager.selectedAssets count] <= 0) {
        return;
    }
    
    if (_plGridDelegate && [_plGridDelegate respondsToSelector:@selector(JNPHGridViewController:
                                                                         didFinishPickingMediaWithInfo:)]) {
        [_plGridDelegate JNPHGridViewController:self didFinishPickingMediaWithInfo:[assetManager.selectedAssets copy]];
    }
}


#pragma mark - Private Methods
- (void)previewVideo:(JNIPAsset *)IPAsset {
    if ([assetManager.selectedAssets count] > 0) {
        iToast *toast = [iToast makeToast:NSLocalizedString(@"选择相片时不能选择视频", nil)];
        [toast showAt:kToastPositionCenter duration:1.5];
        return;
    }
    
    JNPHImageViewController *imageViewController = [[JNPHImageViewController alloc]
                                                         initWithImagePickerConfig:_imagePickerConfig
                                                         IPAssets:@[IPAsset]
                                                         objectAtIndex:0];
    imageViewController.plImageDelegate = self;
    
    [self.navigationController pushViewController:imageViewController animated:YES];
}

- (void)previewPhoto:(JNIPAsset *)IPAsset {
    // 过滤视频
    NSMutableArray *filterVideoAssets = [NSMutableArray array];
    [filterVideoAssets addObjectsFromArray:_photoAssets];
    
    [filterVideoAssets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JNIPAsset *IPAsset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (IPAsset.phAsset.mediaType == PHAssetMediaTypeVideo) {
            [filterVideoAssets removeObject:IPAsset];
        }
    }];
    
    NSUInteger _currentIndex = [JNImagePickerHelper indexOfAsset:IPAsset fromAssets:filterVideoAssets];
    
    JNPHImageViewController *imageViewController = [[JNPHImageViewController alloc]
                                                         initWithImagePickerConfig:_imagePickerConfig
                                                         IPAssets:filterVideoAssets
                                                         objectAtIndex:_currentIndex];
    imageViewController.plImageDelegate = self;
    
    [self.navigationController pushViewController:imageViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && ([[self view] window] != nil) && _didAppear;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JNIPGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:JNIPGridCollectionViewCellReuseIdentifier
                                                                                      forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    JNIPAsset *IPAsset = _photoAssets[indexPath.item];
    for (JNIPAsset *item in assetManager.selectedAssets) {
        if ([item.phAsset.localIdentifier isEqualToString:IPAsset.phAsset.localIdentifier]) {
            IPAsset.selected = YES;
        }
    }
    
    if (cell.tag == currentTag) {
        cell.cellDelegate = self;
        
        [cell drawViewWithIPAsset:IPAsset mediaType:kImagePickerMediaTypeAll];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [((JNIPGridCollectionViewCell *)cell).IPAsset cancelAnyLoading];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 重新计算当前index
    JNIPAsset *currentIPAsset = _photoAssets[indexPath.item];
    if (currentIPAsset.isInTheCloud) {
        [self showICloudAlertWithIPAsset:currentIPAsset];
        return;
    }
    
    if (currentIPAsset.phAsset.mediaType == PHAssetMediaTypeVideo) {
        [self previewVideo:currentIPAsset];
    }
    else {
        [self previewPhoto:currentIPAsset];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellSize = floorf(([UIScreen mainScreen].bounds.size.width-minimumSpacing*(VIEW_COUNT_PER_CELL-1))/VIEW_COUNT_PER_CELL);
    return CGSizeMake(cellSize, cellSize);    // 设置cell的尺寸
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 0, 4, 0);    // 设置其边界
}

#pragma mark - JNPHImageViewControllerDelegate
- (void)JNPHImageViewController:(JNPHImageViewController *)picker didFinishPickingImages:(NSArray *)images {
    picker.plImageDelegate = nil;
    [self handelImagesForSend];
}
- (void)JNPHImageViewController:(JNPHImageViewController *)picker didFinishPickingVideo:(PHAsset *)asset {
    if (_plGridDelegate && [_plGridDelegate respondsToSelector:@selector(JNPHGridViewController:
                                                                         didFinishPickingVideo:)]) {
        [_plGridDelegate JNPHGridViewController:self didFinishPickingVideo:asset];
    }
}
#pragma mark - JNIPGridCollectionViewCellDelegate
- (void)overlayButtonPressed:(UIButton *)button withIPAsset:(JNIPAsset *)IPAsset {
    if (IPAsset.isInTheCloud) {
        [self showICloudAlertWithIPAsset:IPAsset];
        return;
    }
    if (!IPAsset.selected) {
        if ([assetManager.selectedAssets count] >= _imagePickerConfig.capacity) {
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
        IPAsset.selected = YES;
        [assetManager.selectedAssets addObject:IPAsset];
    } else {
        JNIPAsset *item = [JNImagePickerHelper selectedAsset:IPAsset];
        if (item) {
            IPAsset.selected = NO;
            [assetManager.selectedAssets removeObject:item];
        } else {
            IPAsset.selected = YES;
            [assetManager.selectedAssets addObject:IPAsset];
        }
    }
    
    [button setSelected:IPAsset.selected];
    
    [self freshSendButtonTitle];
}

@end
