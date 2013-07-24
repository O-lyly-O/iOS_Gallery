//
//  GalleryViewController.m
//  Ve-hotech
//
//  Created by Charly Poilane on 27/06/13.
//  Copyright (c) 2013 VHT. All rights reserved.
//

#import "GalleryViewController.h"

@implementation GalleryViewController

@synthesize mPictureArray, mPageViewController, mFolderPath, mPictureBegin, mAssetsArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mThumbnailScrollView.delegate = self;
    self.mThumbnailScrollView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    NSArray * assets = [self prepareAssetsToBrowseFullPicture:mPictureBegin];
    mCurrentPicture = mPictureBegin;
    [self startBrowsePicture:assets onFullPictureBrowsedDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self createThumbnailScrollView];
    [self updateThumbnailScrollViewPositionWithPage:mPictureBegin animated:NO];
    [self createPageController:mPictureBegin];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if([mPictureArray count] != 1){
        [self createThumbnailScrollView];
    }
    [self updateThumbnailScrollViewPositionWithPage:mCurrentPicture animated:YES];
    [self updatePageViewControllerPositionWithPage];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(CGSize)getNewSize:(CGSize)size{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    
    if((size.width - screenWidth) < 0 || (size.height - screenHeight) < 0){
        return CGSizeMake(size.width, size.height);
    }else{
        if((size.width - screenWidth) < (size.height - screenHeight)){
            return CGSizeMake((size.width*screenHeight/size.height)*3, screenHeight*3);
        }else{
            return CGSizeMake(screenWidth*3, (size.height*screenWidth/size.width)*3);
        }
    }
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
    for (int i=0; i<[mPictureArray count]; i++) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[[mPictureArray objectAtIndex:i] getThumbnail]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        if(i == 0){
            CGFloat imageWidth = (scrollViewHeight*image.frame.size.width/image.frame.size.height);
            [image setFrame:CGRectMake(screenMiddle - imageWidth/2, 0, imageWidth, scrollViewHeight)];
            sizeMiniatureScroll.width += (image.frame.origin.x + image.frame.size.width) + MARGIN_BETWEEN_PICTURE;
        }else{
            CGFloat imageWidth = (scrollViewHeight*image.frame.size.width/image.frame.size.height);
            [image setFrame:CGRectMake(sizeMiniatureScroll.width,0,imageWidth,scrollViewHeight)];
            if(i != [mPictureArray count] - 1){
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
    NSArray * assets = [self prepareAssetsToBrowseFullPicture:mCurrentPicture];
    [self startBrowsePicture:assets onFullPictureBrowsedDelegate:self];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self updateThumbnailScrollViewPosition:scrollView];   
    self.mPageViewController.view.userInteractionEnabled = YES;
    NSArray * assets = [self prepareAssetsToBrowseFullPicture:mCurrentPicture];
    [self startBrowsePicture:assets onFullPictureBrowsedDelegate:self];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self updateThumbnailScrollViewPosition:scrollView];
        self.mPageViewController.view.userInteractionEnabled = YES;
        NSArray * assets = [self prepareAssetsToBrowseFullPicture:mCurrentPicture];
        [self startBrowsePicture:assets onFullPictureBrowsedDelegate:self];
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
    PhotoViewController* page = [PhotoViewController photoViewControllerForPicture:[[mPictureArray objectAtIndex:firstPage] getHdThumbnail] delegate:self];
    if (page != nil)
    {
        if([mPageViewController.viewControllers count]>0){
            [[mPageViewController.viewControllers objectAtIndex:0] flushPicture];
        }
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
    while([mPictureArray count]>index) {
        if([[mPictureArray objectAtIndex:index] getThumbnail] == vc.picture || [[mPictureArray objectAtIndex:index] getHdThumbnail] == vc.picture)
            break;
        index++;
    }
    if(index == 0){return nil;}
    return [PhotoViewController photoViewControllerForPicture:[[mPictureArray objectAtIndex:index-1] getHdThumbnail] delegate:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(PhotoViewController *)vc
{
    NSUInteger index = 0;
    while([mPictureArray count]>index) {
        if([[mPictureArray objectAtIndex:index] getThumbnail] == vc.picture || [[mPictureArray objectAtIndex:index] getHdThumbnail] == vc.picture)
            break;
        index++;
    }
    if(index >= [mPictureArray count] - 1){return nil;}
    return [PhotoViewController photoViewControllerForPicture:[[mPictureArray objectAtIndex:index+1] getHdThumbnail] delegate:self];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    PhotoViewController* viewController = [previousViewControllers objectAtIndex:0];
    int index=0;
    viewController = [[pageViewController viewControllers]objectAtIndex:0];
    for(Picture* tmp in mPictureArray){
        if([tmp getHdThumbnail] == [viewController picture] || [tmp getThumbnail] == [viewController picture]){
            mCurrentPicture = index;            
            NSArray * assets = [self prepareAssetsToBrowseFullPicture:mCurrentPicture];
            [self startBrowsePicture:assets onFullPictureBrowsedDelegate:self];
            if([[[mAssetsArray objectAtIndex:mCurrentPicture] valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                [self addPlayButton];
            }else{
                [mPlayButton removeFromSuperview];
            }
            [self updateThumbnailScrollViewPositionWithPage:mCurrentPicture animated:YES];
            break;
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
    if([mPageViewController.viewControllers count]>0 && [[mPageViewController.viewControllers objectAtIndex:0] class] == [PhotoViewController class])
        [[mPageViewController.viewControllers objectAtIndex:0] flushPicture];
    [mPageViewController setViewControllers:[NSArray arrayWithObject:[PhotoViewController photoViewControllerForPicture:[[mPictureArray objectAtIndex:mCurrentPicture] getHdThumbnail] delegate:self]] direction:UIPageViewControllerNavigationDirectionForward
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

-(NSArray*)prepareAssetsToBrowseFullPicture:(NSInteger) pos {
    NSMutableArray * assetsForBrowse = [[NSMutableArray alloc]init];
    int tmpPos = 0;
    for(Picture* tmp in mPictureArray) {
        if((tmpPos<pos-1||tmpPos>pos+1) && [tmp isInBrowseHdThumbnail]){
            [tmp flushHdThumbnail];
        }
        tmpPos++;
    }
    if(![[mPictureArray objectAtIndex:pos] isInBrowseHdThumbnail]) {
        [assetsForBrowse addObject:[mAssetsArray objectAtIndex:pos]];
        [[mPictureArray objectAtIndex:pos] setInBrowseHdThumbnail:true];
    }
    if(pos<([mPictureArray count]-1) && ![[mPictureArray objectAtIndex:(pos+1)] isInBrowseHdThumbnail]) {
        [assetsForBrowse addObject:[mAssetsArray objectAtIndex:pos+1]];
        [[mPictureArray objectAtIndex:pos+1] setInBrowseHdThumbnail:true];
    }
    if(pos>0 && ![[mPictureArray objectAtIndex:(pos-1)] isInBrowseHdThumbnail]) {
        [assetsForBrowse addObject:[mAssetsArray objectAtIndex:pos-1]];
        [[mPictureArray objectAtIndex:pos-1] setInBrowseHdThumbnail:true];
    }
    return [[NSArray alloc] initWithArray:assetsForBrowse];
}

-(void)startBrowsePicture:(NSArray *)assets onFullPictureBrowsedDelegate:(id<OnFullPictureBrowsedDelegate>) onFullPictureBrowsedDelegate {
    NSArray * params = [[NSArray alloc] initWithObjects:assets, onFullPictureBrowsedDelegate, nil];
    [[[NSThread alloc] initWithTarget:self selector:@selector(browseFullPicture:) object:params] start];
}

-(void)browseFullPicture:(NSArray *)params{
    NSArray* assets = [params objectAtIndex:0];
    id<OnFullPictureBrowsedDelegate> onFullPictureBrowsedDelegate = [params objectAtIndex:1];
    for(int i=0; i<[assets count]; i++){
        ALAssetRepresentation *assetRepresentation = [[assets objectAtIndex:i] defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:0];
        [onFullPictureBrowsedDelegate onFullPictureBrowsedDelegate:[mAssetsArray indexOfObject:[assets objectAtIndex:i]] image:fullScreenImage];
    }
}

-(void)onFullPictureBrowsedDelegate:(NSInteger)position image:(UIImage *)image{
    if(position >= mCurrentPicture-1 && position <= mCurrentPicture+1){
        NSArray * params = [[NSMutableArray alloc]initWithObjects:image,[NSNumber numberWithInt:position], nil];
        [self performSelectorOnMainThread:@selector(updateThumbnailOnMainThread:)
                               withObject:params
                            waitUntilDone:NO];
    }
}

/*
 * params[0] = image
 * params[1] = position
 */
-(void)updateThumbnailOnMainThread:(NSArray *)params
{
    UIImage * image = [params objectAtIndex:0];
    int position = [[params objectAtIndex:1] intValue];
    [[mPictureArray objectAtIndex:position] setHdThumbnail:image];
    [self updatePageViewControllerPositionWithPage];
}

@end
