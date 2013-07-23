#import "PhotoViewController.h"
#import "ImageScrollView.h"

@implementation PhotoViewController

@synthesize mPicture;

+ (PhotoViewController *)photoViewControllerForPicture:(UIImage*)picture delegate:(id)delegate
{
    return [[self alloc] initWithPageIndex:picture delegate:delegate];
}

- (id)initWithPageIndex:(UIImage*)picture delegate:(id)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        mPicture = picture;
        _delegate = delegate;
    }
    return self;
}

-(UIImage*)picture{
    return mPicture;
}

- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    scrollView.mDelegate = _delegate;
    if(self.navigationController.navigationBarHidden){
        scrollView.mHeightBar = 0;
    }else{
        scrollView.mHeightBar = self.navigationController.navigationBar.frame.size.height;
    }
    scrollView.picture = mPicture;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
}

- (void) flushPicture {
    mPicture=nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
