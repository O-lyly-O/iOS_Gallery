//
//  GalleryCollectionViewController.h
//  iOS_Gallery
//
//  Created by Charly on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShowAlertView.h"
#import "AlbumCell.h"
#import "ListCollectionViewController.h"

@interface AlbumCollectionViewController : UICollectionViewController{
    ALAssetsLibrary *mAssetsLibrary;
    NSMutableArray *mGroups;
}

@end
