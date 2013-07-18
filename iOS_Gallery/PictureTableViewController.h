//
//  PictureTableViewController.h
//  iOS_Gallery
//
//  Created by Charly Poilane on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShowAlertView.h"
#import "ListTableViewController.h"

@interface PictureTableViewController : UITableViewController{
    ALAssetsLibrary *mAssetsLibrary;
    NSMutableArray *mGroups;
}

@end
