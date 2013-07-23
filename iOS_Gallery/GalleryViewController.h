//
//  GalleryViewController.h
//  Ve-hotech
//
//  Created by Charly Poilane on 27/06/13.
//  Copyright (c) 2013 VHT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PhotoViewController.h"
#import "onTapOnPageDelegate.h"

#define MARGIN_BETWEEN_PICTURE 10

#define IS_PORTRAIT (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


@interface GalleryViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIPageViewControllerDelegate, onTapOnPageDelegate, UIPageViewControllerDataSource>{
    BOOL mEndOfBrowse;
    int mCurrentPicture;
    NSArray * mSelectedFiles;
    UIButton *mPlayButton;
    MPMoviePlayerController* mPlayer;
}


@property int mPictureBegin;
@property (strong, nonatomic) UIPageViewController *mPageViewController;
@property (strong, nonatomic) NSString *mFolderPath;
@property (nonatomic, copy) NSArray* mThumbnailArray;
@property (nonatomic, copy) NSMutableArray* mAssetsArray;
@property (nonatomic, copy) NSMutableArray* mFullPictureArray;
@property (weak, nonatomic) IBOutlet UIScrollView *mThumbnailScrollView;

@end