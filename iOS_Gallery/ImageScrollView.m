#import <Foundation/Foundation.h>

#import "ImageScrollView.h"

#pragma mark -

@interface ImageScrollView () <UIScrollViewDelegate>
{
    UIImageView *_zoomView;
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}

@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = NO;
        self.bounces = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;        
    }
    return self;
}

-(void)setPicture:(UIImage *)picture{
    _picture = picture;
    [self displayImage:picture];
}

-(void)setMHeightBar:(CGFloat)mHeightBar{
    _mHeightBar = mHeightBar;
}

-(void)setMDelegate:(id)mDelegate{
    _mDelegate = mDelegate;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self addGestureRecognizer:tapGesture];
    UILongPressGestureRecognizer* longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    [self addGestureRecognizer:longTapGesture];
}

-(void)handleTapGestureRecognizer:(UITapGestureRecognizer*)sender{
    [_mDelegate onTapOnPage];
}

-(void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        [_mDelegate onLongTapOnPage];
    }
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}

#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;

    _zoomView = [[UIImageView alloc] initWithImage:image];
    _zoomView.contentMode = UIViewContentModeScaleAspectFit;
    if(IS_PORTRAIT){
        CGFloat statutBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat height = [[UIScreen mainScreen] bounds].size.height-_mHeightBar;
        CGFloat width = [[UIScreen mainScreen] bounds].size.width;
        _zoomView.bounds = CGRectMake(0, 0, width*2, (height - statutBarHeight)*2);
    }else{
        CGFloat statutBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.width;
        CGFloat height = [[UIScreen mainScreen] bounds].size.width-_mHeightBar;
        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
        _zoomView.bounds = CGRectMake(0, 0,width*2,(height - statutBarHeight)*2);
    }
    [self addSubview:_zoomView];
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
                
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 2.0 / [[UIScreen mainScreen] scale];

    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
        
    self.maximumZoomScale = 2;
    self.minimumZoomScale = 0.5;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
//    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
//    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    // Step 2: restore center point, first making sure it is within the allowable range.
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];

    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);

    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end
