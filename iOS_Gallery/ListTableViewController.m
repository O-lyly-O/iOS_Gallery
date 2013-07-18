//
//  ListTableViewController.m
//  iOS_Gallery
//
//  Created by Charly Poilane on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "ListTableViewController.h"

@implementation ListTableViewController

@synthesize mAssetsGroup;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self browsePicture];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

-(void)browsePicture{
    [self.navigationController setTitle:[mAssetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    
    if (!mAssets) {
        mAssets = [[NSMutableArray alloc] init];
    } else {
        [mAssets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [mAssets addObject:result];
        } else {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [mAssetsGroup setAssetsFilter:onlyPhotosFilter];
    [mAssetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mAssets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ALAsset *asset = [mAssets objectAtIndex:indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    cell.imageView.image = [UIImage imageWithCGImage:thumbnailImageRef];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height / [mAssets count];
}

@end
