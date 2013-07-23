//
//  CVCell.h
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *mGroupTitle;
@property (weak, nonatomic) IBOutlet UIImageView *mThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *mPictureFrame;

@end
