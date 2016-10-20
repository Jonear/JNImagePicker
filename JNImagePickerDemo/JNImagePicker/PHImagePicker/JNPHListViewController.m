//
//  JNPHListViewController.m
//  JNImagePicker
//
//  Created by Jonear on 16/3/11.
//  Copyright © 2016年 Jonear. All rights reserved.
//

#import "JNPHListViewController.h"
#import "JNIPListTableViewCell.h"
#import "JNPHGridViewController.h"
#import "JNAssetManager.h"
#import "PhotoKitAccessor.h"
#import "JNImagePickerHelper.h"

static NSString * const JNIPListTableViewCellReuseIdentifier = @"JNIPListTableViewCellIdentifier";
static CGSize const kAlbumThumbnailSize1 = {50.0f , 50.0f};

@interface JNPHListViewController ()
<PHPhotoLibraryChangeObserver,
UITableViewDataSource,
UITableViewDelegate,
JNPHGridViewControllerDelegate>
{
    PHFetchOptions *onlyImagesOptions;
    JNAssetManager            *assetManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *collectionsFetchResults;


@property (nonatomic, assign) NSInteger              maxCount;
@property (nonatomic, assign) ImagePickerMediaType   mediaType;
@property (nonatomic, strong) JNImagePickerConfig   *imagePickerConfig;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation JNPHListViewController

- (void)dealloc
{
    /**
     *  代理出去之前，我么清理一下Manager
     */
    [JNImagePickerHelper clearAssetManager];
    
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        assetManager        = [JNAssetManager sharedManager];
        self.mediaType      = kImagePickerMediaTypePhoto;
        self.imageManager = [[PhotoKitAccessor sharedInstance] phCachingImageManager];
    }
    return self;
}

- (instancetype)initWithImagePickerConfig:(JNImagePickerConfig *)imagePickerConfig {
    self = [super init];
    if (self) {
        self.imagePickerConfig = imagePickerConfig;
        self.maxCount   = imagePickerConfig.capacity;
        self.mediaType  = imagePickerConfig.imagePickerMediaType;
        
        if (_mediaType == kImagePickerMediaTypePhoto) {
            onlyImagesOptions = [PHFetchOptions new];
            onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
        } else {
            onlyImagesOptions = nil;
        }
        
        self.imageManager = [[PhotoKitAccessor sharedInstance] phCachingImageManager];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"相册", @"");
    
    [self setBarButtonItem];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.rowHeight = [JNIPListTableViewCell cellHeight];
    
    [_tableView registerNib:[UINib nibWithNibName:@"JNIPListTableViewCell" bundle:nil] forCellReuseIdentifier:JNIPListTableViewCellReuseIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)setBarButtonItem
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rightButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}
#pragma mark - Actions
- (void)rightButtonPressed:(id)sender
{
    [self didCancel];
}

- (void)didCancel
{
    /**
     *  代理出去之前，我么清理一下Manager
     */
    [JNImagePickerHelper clearAssetManager];
    
    [self.imageManager stopCachingImagesForAllAssets];
    if (_plListDelegate) {
        if ([_plListDelegate respondsToSelector:@selector(JNPHListViewControllerDidCancel:)]) {
            [_plListDelegate JNPHListViewControllerDidCancel:self];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectionsFetchResultsAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JNIPListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JNIPListTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[indexPath.row];
    NSString *localizedTitle = self.collectionsFetchResultsTitles[indexPath.row];
    cell.localizedTitleLabel.text = localizedTitle;
    
    cell.countLabel.text = [NSString stringWithFormat:@"(%@)", @(fetchResult.count)];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    //Compute the thumbnail pixel size:
    CGSize tableCellThumbnailSize1 = CGSizeMake(kAlbumThumbnailSize1.width*scale, kAlbumThumbnailSize1.height*scale);
    PHAsset *asset = [fetchResult lastObject];
    if (asset) {
        [self.imageManager requestImageForAsset:asset
                                     targetSize:tableCellThumbnailSize1
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info)
         {
             if (cell.tag == currentTag)
             {
                 cell.posterImageView.image = result;
             }
         }];
    } else {
        cell.posterImageView.image = [UIImage imageNamed:@"image_picker_default_poster"];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showGridViewController:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showGridViewController:(NSUInteger)index {
    JNPHGridViewController *assetGridViewController = [[JNPHGridViewController alloc] initWithImagePickerConfig:_imagePickerConfig];
    assetGridViewController.plGridDelegate = self;
    assetGridViewController.isScrollToBottom = YES;
    
    PHFetchResult *result = _collectionsFetchResultsAssets[index];
    if (result && (result.count > 0)) {
        assetGridViewController.assetsFetchResults = result;
        assetGridViewController.navigationItem.title = _collectionsFetchResultsTitles[index];
        
        [JNAssetManager sharedManager].assetsGroupID = _collectionsLocalIdentifier[index];
        [self.navigationController pushViewController:assetGridViewController animated:YES];
    }
}

#pragma mark - JNPHGridViewControllerDelegate
- (void)JNPHGridViewController:(JNPHGridViewController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    if (_plListDelegate) {
        if ([_plListDelegate respondsToSelector:@selector(JNPHListViewController:didFinishPickingMediaWithInfo:)]) {

            [_plListDelegate JNPHListViewController:self didFinishPickingMediaWithInfo:info];
            
            /**
             *  代理出去之后，我么清理一下Manager
             */
            [JNImagePickerHelper clearAssetManager];
        }
    }
}

- (void)JNPHGridViewController:(JNPHGridViewController *)picker didFinishPickingVideo:(PHAsset *)asset
{
    if (_plListDelegate) {
        if ([_plListDelegate respondsToSelector:@selector(JNPHListViewController:didFinishPickingVideo:)]) {
            
            [_plListDelegate JNPHListViewController:self didFinishPickingVideo:asset];
            
            /**
             *  代理出去之后，我么清理一下Manager
             */
            [JNImagePickerHelper clearAssetManager];
        }
    }
}

- (void)JNPHGridViewControllerDidCancel:(JNPHGridViewController *)picker
{
    picker.plGridDelegate = nil;
    [self didCancel];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
            
            // 过滤
            for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
                for (PHCollection *collection in collectionsFetchResult) {
                    if ([collection isKindOfClass:[PHAssetCollection class]]) {
                        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                        if (assetsFetchResult.count > 0) {
                            [_collectionsFetchResultsAssets addObject:collection];
                        }
                    }
                }
            }
            
            [self.tableView reloadData];
        }
        
    });
}

@end
