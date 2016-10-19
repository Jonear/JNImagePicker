//
//  HYWImagePickerManager.m
//  HYWImagePicker
//
//  Created by 黄耀武 on 16/3/14.
//  Copyright © 2016年 huangyaowu. All rights reserved.
//

#import "JNImagePickerManager.h"
#import "UIImagePickerController+Block.h"
#import "HYWPHListViewController.h"
#import "JNAssetManager.h"
#import "HYWPHGridViewController.h"
#import "JNImagePickerHelper.h"
#import "PrivacyHelper.h"

@interface JNImagePickerManager() <UIActionSheetDelegate>

@property (nonatomic, strong) JNImagePickerConfig *imagePickerConfig;

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;
@property (strong) NSMutableArray *collectionsFetchResultsAssets;
@property (strong) NSMutableArray *collectionsFetchResultsTitles;
@property (strong) NSMutableArray *collectionsLocalIdentifier;

@property (assign, nonatomic) BOOL allowsEditing;
@property (strong, nonatomic) UIImagePickerControllerFinishBlock finishBlock;

@end

@implementation JNImagePickerManager

- (void)imagePickerActionSheetInController:(UIViewController *)viewController
                          actionSheetTitle:(NSString *)actionSheetTitle
                               finishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    [self imagePickerActionSheetInController:viewController
                            actionSheetTitle:actionSheetTitle
                               allowsEditing:YES
                                 finishBlock:finishBlock];
}

- (void)imagePickerActionSheetInController:(UIViewController *)viewController
                          actionSheetTitle:(NSString *)actionSheetTitle
                             allowsEditing:(BOOL)allowsEditing
                               finishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    UIActionSheet *sheet = nil;
    if (cameraAvailable) {
        sheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取", nil];
    }
    
    self.allowsEditing = allowsEditing;
    self.finishBlock = finishBlock;
    [sheet showInView:viewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"从相册选取"]) {
        
        [JNImagePickerManager selectImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                           allowsEditing:self.allowsEditing
                                             finishBlock:self.finishBlock];
    } else if ([buttonTitle isEqualToString:@"拍照"]) {
        
        [JNImagePickerManager selectImageWithSourceType:UIImagePickerControllerSourceTypeCamera
                                           allowsEditing:self.allowsEditing
                                             finishBlock:self.finishBlock];
    }
}

#pragma mark - Actions
+ (void)selectImageWithSourceType:(UIImagePickerControllerSourceType)sourceType
                    allowsEditing:(BOOL)allowsEditing
                      finishBlock:(UIImagePickerControllerFinishBlock)finishBlock {
    
    [UIImagePickerController imagePickerWithSourceType:sourceType
                                         allowsEditing:allowsEditing
                                           finishBlock:^(NSDictionary *info) {
                                               if (finishBlock) {
                                                   finishBlock(info);
                                               }
                                           }];
}

#pragma mark - 调用自定义相片选择器
- (void)showImagePickerInViewController:(UIViewController *)viewController
                      imagePickerConfig:(JNImagePickerConfig *)imagePickerConfig {
    [PrivacyHelper checkAlbumPrivacy:YES onComplete:^(BOOL haveAuthorization) {
        if (haveAuthorization) {
            [self showPHAssetListInViewController:viewController imagePickerConfig:imagePickerConfig];
        }
    }];
}

- (void)getAllAlbumsWithOptions:(nullable PHFetchOptions *)options {
    _collectionsFetchResultsAssets = [NSMutableArray array];
    _collectionsFetchResultsTitles = [NSMutableArray array];
    _collectionsLocalIdentifier = [NSMutableArray array];
    
    
    // 列出所有相册智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    // 列出PHAssetCollectionTypeAlbum
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    self.collectionsFetchResults = @[smartAlbums, userAlbums];
    
    [self updateFetchResults:options];
}

- (void)updateFetchResults:(nullable PHFetchOptions *)options {
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchLocalIdentifier = [[NSMutableArray alloc] init];
    
    // Set default values
    NSArray *assetCollectionSubtypes = @[
                                         @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                                         @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
                                         @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                         @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                                         @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                         @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                         @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                         @(PHAssetCollectionSubtypeSmartAlbumScreenshots),
                                         @(PHAssetCollectionSubtypeAlbumSyncedAlbum),
                                         ];
    
    NSMutableArray *assetCollections = [NSMutableArray array];
    
    // Filter albums
    NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:assetCollectionSubtypes.count];
    NSMutableArray *userAlbums = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in self.collectionsFetchResults) {
        [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumRegular) {
                [userAlbums addObject:assetCollection];
            } else if ([assetCollectionSubtypes containsObject:@(assetCollection.assetCollectionSubtype)]) {
                smartAlbums[@(assetCollection.assetCollectionSubtype)] = assetCollection;
            }
        }];
    }
    
    // Fetch smart albums
    for (NSNumber *assetCollectionSubtype in assetCollectionSubtypes) {
        PHAssetCollection *assetCollection = smartAlbums[assetCollectionSubtype];
        
        if (assetCollection) {
            [assetCollections addObject:assetCollection];
        }
    }
    
    // Fetch user albums
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
        [assetCollections addObject:assetCollection];
    }];
    
    for (PHCollection *collection in assetCollections) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (assetsFetchResult.count > 0) {
                [allFetchResultArray addObject:assetsFetchResult];
                [allFetchResultLabel addObject:collection.localizedTitle];
                [allFetchLocalIdentifier addObject:collection.localIdentifier];
            }
        }
    }
    
    [self.collectionsFetchResultsAssets addObjectsFromArray:allFetchResultArray];
    [self.collectionsFetchResultsTitles addObjectsFromArray:allFetchResultLabel];
    [self.collectionsLocalIdentifier addObjectsFromArray:allFetchLocalIdentifier];
}

- (void)showPHAssetListInViewController:(UIViewController *)viewController imagePickerConfig:(JNImagePickerConfig *)imagePickerConfig {
    PHFetchOptions *onlyImagesOptions;
    if (imagePickerConfig.imagePickerMediaType == kImagePickerMediaTypePhoto) {
        onlyImagesOptions = [PHFetchOptions new];
        onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    } else {
        onlyImagesOptions = nil;
    }
    
    
    self.imagePickerConfig = imagePickerConfig;
    
    // config
    id delegate = self.imagePickerConfig.delegate;
    
    
    // 获取相册
    [self getAllAlbumsWithOptions:onlyImagesOptions];
    
    
    HYWPHListViewController *listController = [[HYWPHListViewController alloc] initWithImagePickerConfig:imagePickerConfig];
    listController.collectionsFetchResultsAssets = _collectionsFetchResultsAssets;
    listController.collectionsFetchResultsTitles = _collectionsFetchResultsTitles;
    listController.collectionsLocalIdentifier = _collectionsLocalIdentifier;
    
    listController.plListDelegate = delegate ?: (id<HYWPHListViewControllerDelegate>)viewController;
    
    
    // push album vc
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:listController];
    
    if (_collectionsFetchResultsAssets.count > 0) {
        // 默认显示第一个相册-相机胶卷
//#warning huangyaowu
        NSInteger atIndex = 0;
//        for (NSInteger i = 0; i < _collectionsFetchResultsAssets.count; i++) {
//            NSString *identifier = _collectionsLocalIdentifier[i];
//            if ([identifier isEqualToString:[[ConfigManager sharedManager] assetsGroupID]]) {
//                atIndex = i;
//                break;
//            }
//        }
        
        PHFetchResult *selectedResult = _collectionsFetchResultsAssets[atIndex];
        if (selectedResult.count > 0) {
            NSString *resultTitle = _collectionsFetchResultsTitles[atIndex];
            
            HYWPHGridViewController *gridController = [[HYWPHGridViewController alloc] initWithImagePickerConfig:_imagePickerConfig];
            gridController.plGridDelegate = (id<HYWPHGridViewControllerDelegate>)listController;
            gridController.isScrollToBottom = YES;
            gridController.assetsFetchResults = selectedResult;
            gridController.navigationItem.title = resultTitle;
        
            [JNAssetManager sharedManager].assetsGroupID = _collectionsLocalIdentifier[atIndex];
            
            [nc pushViewController:gridController animated:NO];
        }
    }
    
    
    [viewController presentViewController:nc animated:YES completion:nil];
}

- (BOOL)isDefaultGroupName:(NSString *)name
{
    NSArray *array = [NSArray arrayWithObjects:NSLocalizedString(@"相机胶卷", ""),
                      NSLocalizedString(@"所有照片", ""),
                      NSLocalizedString(@"Camera Roll", ""),
                      NSLocalizedString(@"存储的照片", ""), nil];
    for (NSString *item in array) {
        if ([item isEqualToString:NSLocalizedString(name, @"")]) {
            return YES;
        }
    }
    return NO;
}



@end
