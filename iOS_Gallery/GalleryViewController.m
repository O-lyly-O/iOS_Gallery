//
//  GalleryViewController.m
//  Ve-hotech
//
//  Created by Charly Poilane on 27/06/13.
//  Copyright (c) 2013 VHT. All rights reserved.
//

#import "GalleryViewController.h"

@implementation GalleryViewController

@synthesize mThumbnailArray, mPageViewController, mFolderPath, mPictureBegin, mAssetsArray, mFullPictureArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mThumbnailScrollView.delegate = self;
    self.mThumbnailScrollView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    mFullPictureArray = [[NSMutableArray alloc] initWithArray:mThumbnailArray];
    [[[NSThread alloc] initWithTarget:self selector:@selector(browseAssets) object:nil] start];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self createThumbnailScrollView];
    [self updateThumbnailScrollViewPositionWithPage:mPictureBegin animated:NO];
    [self createPageController:mPictureBegin];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if([mThumbnailArray count] != 1){
        [self createThumbnailScrollView];
    }
    [self updateThumbnailScrollViewPositionWithPage:mCurrentPicture animated:YES];
    [self updatePageViewControllerPositionWithPage];
}

/* ---------------------------------- THUMBNAIL SCROLL VIEW ---------------------------------- */

-(void)createThumbnailScrollView{
    if([self.mThumbnailScrollView.subviews count] != 0){
        for (UIView *subview in self.mThumbnailScrollView.subviews) {
            [subview removeFromSuperview];
        }
    }
    [self addThumbnailsToScrollView];
}

-(void)addThumbnailsToScrollView{
    CGFloat screenMiddle = self.view.frame.size.width/2;
    CGFloat scrollViewHeight = self.mThumbnailScrollView.frame.size.height;
    CGSize sizeMiniatureScroll = CGSizeMake(0, scrollViewHeight);
    for (int i=0; i<[mThumbnailArray count]; i++) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[mThumbnailArray objectAtIndex:i]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        if(i == 0){
            CGFloat imageWidth = (scrollViewHeight*image.frame.size.width/image.frame.size.height);
            [image setFrame:CGRectMake(screenMiddle - imageWidth/2, 0, imageWidth, scrollViewHeight)];
            sizeMiniatureScroll.width += (image.frame.origin.x + image.frame.size.width) + MARGIN_BETWEEN_PICTURE;
        }else{
            CGFloat imageWidth = (scrollViewHeight*image.frame.size.width/image.frame.size.height);
            [image setFrame:CGRectMake(sizeMiniatureScroll.width,0,imageWidth,scrollViewHeight)];
            if(i != [mThumbnailArray count] - 1){
                sizeMiniatureScroll.width += image.frame.size.width + MARGIN_BETWEEN_PICTURE;
            }else{
                sizeMiniatureScroll.width += screenMiddle + image.frame.size.width/2;
            }
        }
        image.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(tapOnThumbnail:)];
        tapGesture.delegate = self;
        [image addGestureRecognizer:tapGesture];
        if([[[mAssetsArray objectAtIndex:i] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            UIImageView* play = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playButton.png"]];
            CGFloat x,y,width,height;
            width = image.frame.size.height/3*play.frame.size.width/play.frame.size.height;
            height = image.frame.size.height/3;
            x = image.frame.size.width/2-width/2;
            y = image.frame.size.height/2-height/2;
            [play setFrame:CGRectMake(x, y, width, height)];
            [image addSubview:play];
        }
        [self.mThumbnailScrollView addSubview:image];
    }
    self.mThumbnailScrollView.contentSize = sizeMiniatureScroll;
}

- (void)tapOnThumbnail:(UITapGestureRecognizer *)tapGesture{
    [self updateThumbnailScrollViewPositionWhenTap:self.mThumbnailScrollView point:[tapGesture locationInView:self.mThumbnailScrollView]];  
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateThumbnailScrollViewPosition:scrollView];   
    self.mPageViewController.view.userInteractionEnabled = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self updateThumbnailScrollViewPosition:scrollView];
        self.mPageViewController.view.userInteractionEnabled = YES;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.mPageViewController.view.userInteractionEnabled = NO;
}

-(void)updateThumbnailScrollViewPosition:(UIScrollView*) scrollView{
    BOOL animated = YES;
    if(scrollView == self.mThumbnailScrollView){
        CGFloat center = self.view.frame.size.width/2;
        CGFloat xOffset = self.mThumbnailScrollView.contentOffset.x + center;
        int page = 0;
        for (UIView *subview in self.mThumbnailScrollView.subviews) {
            CGFloat xSubview = subview.frame.origin.x;
            CGFloat widthSubview =subview.frame.size.width;
            if(xOffset >= xSubview - MARGIN_BETWEEN_PICTURE/2 && xOffset <= xSubview + widthSubview + MARGIN_BETWEEN_PICTURE/2){
                [self.mThumbnailScrollView setContentOffset:CGPointMake(xSubview+(widthSubview/2)-center, 0) animated:animated];
                mCurrentPicture = page;
                [self updatePageViewControllerPositionWithPage];
            }
            page++;
        }
    }
}

-(void)updateThumbnailScrollViewPositionWhenTap:(UIScrollView*) scrollView point:(CGPoint)point{
    BOOL animated = YES;
    CGFloat center = self.view.frame.size.width/2;
    CGFloat xPoint = point.x;
    int page = 0;
    for (UIView *subviewMiniatureScrollView in self.mThumbnailScrollView.subviews) {
        CGFloat xSubview = subviewMiniatureScrollView.frame.origin.x;
        CGFloat widthSubview =subviewMiniatureScrollView.frame.size.width;
        if(xPoint >= xSubview - MARGIN_BETWEEN_PICTURE/2 && xPoint <= xSubview + widthSubview + MARGIN_BETWEEN_PICTURE/2){
            [self.mThumbnailScrollView setContentOffset:CGPointMake(xSubview+(widthSubview/2)-center, 0) animated:animated];
            mCurrentPicture = page;
            [self updatePageViewControllerPositionWithPage];
        }
        page++;
    }
}

-(void)updateThumbnailScrollViewPositionWithPage:(int)newPage animated:(BOOL)animated{
    int page = 0;
    for (UIView *subviewMiniatureScrollView in self.mThumbnailScrollView.subviews) {
        if(page == newPage){
            CGFloat center = self.view.frame.size.width/2;
            CGFloat xSubview = subviewMiniatureScrollView.frame.origin.x;
            CGFloat widthSubview =subviewMiniatureScrollView.frame.size.width;
            [self.mThumbnailScrollView setContentOffset:CGPointMake(xSubview+(widthSubview/2)-center, 0) animated:animated];
            mCurrentPicture = page;
        }
        page++;
    }
}

-(void)showHideMiniatureScoll{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [self.mThumbnailScrollView.layer addAnimation:animation forKey:nil];
    self.mThumbnailScrollView.hidden = !self.mThumbnailScrollView.hidden;
}

/* ---------------------------------- PAGE VIEW CONTROLLER ---------------------------------- */
-(void)createPageController:(int)firstPage{
    PhotoViewController* page = [PhotoViewController photoViewControllerForPicture:[mFullPictureArray objectAtIndex:firstPage] delegate:self];
    if (page != nil)
    {
        if([mPageViewController.viewControllers count]>0)
            [[mPageViewController.viewControllers objectAtIndex:0] flushPicture];
        [mPageViewController removeFromParentViewController];
        [mPageViewController.view removeFromSuperview];
         mPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
         mPageViewController.dataSource = self;
         mPageViewController.delegate = self;
        [mPageViewController setViewControllers:[NSArray arrayWithObject:page]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
         mPageViewController.view.frame = self.view.frame;
        [self addChildViewController:mPageViewController];
        [self.view addSubview:mPageViewController.view];
        [self.view addSubview:self.mThumbnailScrollView];
        if([[[mAssetsArray objectAtIndex:firstPage] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            [self addPlayButton];
        }else{
            [mPlayButton removeFromSuperview];
        }
        [mPageViewController didMoveToParentViewController:self];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(PhotoViewController *)vc
{
    NSUInteger index = 0;
    while([mFullPictureArray count]>index) {
        if([mFullPictureArray objectAtIndex:index] == vc.picture || [mFullPictureArray objectAtIndex:index] == vc.picture)
            break;
        index++;
    }
    if(index == 0){return nil;}
    return [PhotoViewController photoViewControllerForPicture:[mFullPictureArray objectAtIndex:index-1] delegate:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = 0;
    while([mFullPictureArray count]>index) {
        if([mFullPictureArray objectAtIndex:index] == vc.picture)
            break;
        index++;
    }
    if(index >= [mFullPictureArray count] - 1){return nil;}
    return [PhotoViewController photoViewControllerForPicture:[mFullPictureArray objectAtIndex:index+1] delegate:self];
}


-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    PhotoViewController* viewController = [previousViewControllers objectAtIndex:0];
    int index=0;
    viewController = [[pageViewController viewControllers]objectAtIndex:0];
    for(UIImage* tmp in mFullPictureArray){
        if(tmp == [viewController picture]){
            mCurrentPicture = index;
            [self updateThumbnailScrollViewPositionWithPage:mCurrentPicture animated:YES];
            if([[[mAssetsArray objectAtIndex:mCurrentPicture] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                [self addPlayButton];
            }else{
                [mPlayButton removeFromSuperview];
            }
        }
        index++;
    }
    self.mThumbnailScrollView.userInteractionEnabled = YES;
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    self.mThumbnailScrollView.userInteractionEnabled = NO;
    [mPlayButton removeFromSuperview];
}

-(void)updatePageViewControllerPositionWithPage{
    if([[[mAssetsArray objectAtIndex:mCurrentPicture] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
        [self addPlayButton];
    }else{
        [mPlayButton removeFromSuperview];
    }
    [mPageViewController setViewControllers:[NSArray arrayWithObject:[PhotoViewController photoViewControllerForPicture:[mFullPictureArray objectAtIndex:mCurrentPicture] delegate:self]] direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:NULL];
}

-(void)onTapOnPage{
    [self showHideMiniatureScoll];
}

-(void)onLongTapOnPage{
    [self showHideBar];
    [self updateThumbnailScrollViewPositionWithPage:mCurrentPicture animated:YES];
    [self updatePageViewControllerPositionWithPage];
}

-(void)showHideBar{
    [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES] ;
}

-(void)browseAssets{
    int position = 0;
    for(ALAsset* asset in mAssetsArray){
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage] scale:[assetRepresentation scale] orientation:(UIImageOrientation)[assetRepresentation orientation]];
        [self refreshThumbnailWithFullScreenImage:position image:fullScreenImage];
        position++;
    }
}

-(void)refreshThumbnailWithFullScreenImage:(int)position image:(UIImage*)image{
    [mFullPictureArray replaceObjectAtIndex:position withObject:image];
    [self updatePageViewControllerPositionWithPage];
}

-(void)addPlayButton{
    [mPlayButton removeFromSuperview];
    UIImageView* play = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playButton.png"]];
    CGFloat x,y,width,height;
    if(IS_PORTRAIT){
        width = self.view.frame.size.width/4;
        height = width*play.frame.size.height/play.frame.size.width;
        x = self.view.frame.size.width/2-width/2;
        y = self.view.frame.size.height/2-height/2;
    }else{
        width = self.view.frame.size.width/8;
        height = width*play.frame.size.height/play.frame.size.width;
        x = self.view.frame.size.width/2-width/2;
        y = self.view.frame.size.height/2-height/2;
    }
    mPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [mPlayButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    [mPlayButton setReversesTitleShadowWhenHighlighted:YES];
    [mPlayButton setShowsTouchWhenHighlighted:YES];
    [mPlayButton addTarget:self action:@selector(tapPlayButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mPlayButton];
}

-(void)tapPlayButton{
    mPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[[[mAssetsArray objectAtIndex:mCurrentPicture] defaultRepresentation] url]];
    [mPlayer setShouldAutoplay:YES];
    [self.view addSubview:mPlayer.view];
    [mPlayer setFullscreen:YES animated:YES];
    [mPlayer play];
}

@end
