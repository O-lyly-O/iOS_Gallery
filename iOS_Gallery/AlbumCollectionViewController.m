//
//  GalleryCollectionViewController.m
//  iOS_Gallery
//
//  Created by Charly on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "AlbumCollectionViewController.h"

@implementation AlbumCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setBounces:NO];
    [self.collectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"cvCell"];
    [self browseDeviceGallery];
}

-(void)browseDeviceGallery{
    if (!mAssetsLibrary) {
        mAssetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!mGroups) {
        mGroups = [[NSMutableArray alloc] init];
    } else {
        [mGroups removeAllObjects];
    }
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [mGroups addObject:group];
        } else {
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = NSLocalizedString(@"userDeclinedAccess", @"");
                break;
            default:
                errorMessage = NSLocalizedString(@"errorAccessUnknow", @"");
                break;
        }
        ShowAlertView* alertView = [[ShowAlertView alloc]init];
        [alertView showToast:NSLocalizedString(@"accessError", @"") message:errorMessage];
    };
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [mAssetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mGroups count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cvCell";
    
    AlbumCell *cell = (AlbumCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    ALAssetsGroup *groupForCell = [mGroups objectAtIndex:indexPath.row];
    [groupForCell setAssetsFilter:[ALAssetsFilter allAssets]];
    cell.mThumbnail.image = [UIImage imageWithCGImage:[groupForCell posterImage]];
    cell.mGroupTitle.text = [NSString stringWithFormat:@"%@ (%d)", [groupForCell valueForProperty:ALAssetsGroupPropertyName], [groupForCell numberOfAssets]];
    //cell.mPictureFrame.image = [UIImage imageNamed:@""];
    cell.mPictureFrame.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ListCollectionViewController* listCollectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListCollectionViewController"];
    listCollectionViewController.mAssetsGroup = [mGroups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:listCollectionViewController animated:YES];
}

@end
