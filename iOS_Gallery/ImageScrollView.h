#import <UIKit/UIKit.h>
#import "onTapOnPageDelegate.h"

#define IS_PORTRAIT (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface ImageScrollView: UIScrollView{
    UILongPressGestureRecognizer* mLongTapGesture;
}

@property (nonatomic) CGFloat mHeightBar;
@property (nonatomic) UIImage* picture;
@property (nonatomic) id<onTapOnPageDelegate> mDelegate;

@end
