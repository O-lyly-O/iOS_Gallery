#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
{
    id _delegate;
}
@property (nonatomic, assign) UIImage* mPicture;

+ (PhotoViewController *)photoViewControllerForPicture:(UIImage*)picture delegate:(id)delegate;

- (UIImage*)picture;

- (void) flushPicture;

@end
