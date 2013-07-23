//
//  ListCollectionViewController.h
//  iOS_Gallery
//
//  Created by Charly on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GalleryViewController.h"

@interface ListCollectionViewController : UICollectionViewController{
    NSMutableArray *mAssets;
    NSMutableArray* mPictureArray;
    UIActivityIndicatorView* mActivityIndicator;
    BOOL mFinishedBrowseAsset;
}

@property ALAssetsGroup* mAssetsGroup;

@end
