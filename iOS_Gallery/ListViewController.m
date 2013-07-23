//
//  ListViewController.m
//  iOS_Gallery
//
//  Created by Charly on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "ListViewController.h"

@implementation ListViewController

@synthesize mAssetsGroup;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    mListTableViewController = [ListTableViewController getListTableViewControllerFromContainer:self.mListTableViewControllercontainer];
    mListTableViewController.mAssetsGroup = mAssetsGroup;
    [mListTableViewController browsePicture];
}

@end
