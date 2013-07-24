//
//  ListCollectionViewController.m
//  iOS_Gallery
//
//  Created by Charly on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "ListCollectionViewController.h"

@implementation ListCollectionViewController

@synthesize mAssetsGroup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setBounces:NO];
    self.navigationItem.title = [mAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [self browsePicture];
}

-(void)browsePicture{
    if (!mAssets) {
        mAssets = [[NSMutableArray alloc] init];
    } else {
        [mAssets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [mAssets addObject:result];
        } else {
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allAssets];
    [mAssetsGroup setAssetsFilter:onlyPhotosFilter];
    [mAssetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mAssets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    ALAsset *asset = [mAssets objectAtIndex:indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [UIImage imageWithCGImage:thumbnailImageRef];
    //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView* playButton = (UIImageView*)[cell viewWithTag:50];
    if([[[mAssets objectAtIndex:indexPath.row] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
        playButton.hidden = NO;
    }else{
        playButton.hidden = YES;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* pictureArray = [[NSMutableArray alloc] init];
    for(ALAsset* tmp in mAssets){
        [pictureArray addObject:[[Picture alloc] initPictureWithThumbnail:[UIImage imageWithCGImage:[tmp thumbnail]]]];
    }
    GalleryViewController* galleryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
    galleryViewController.mPictureBegin = indexPath.row;
    galleryViewController.mPictureArray = pictureArray;
    galleryViewController.mAssetsArray = mAssets;
    [self.navigationController pushViewController:galleryViewController animated:YES];
}

@end
