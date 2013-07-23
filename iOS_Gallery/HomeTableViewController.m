//
//  HomeTableViewController.m
//  iOS_Gallery
//
//  Created by Charly Poilane on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "HomeTableViewController.h"

@implementation HomeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBounces:NO];
    NSDictionary* propertiesList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Property List" ofType:@"plist"]];
    mIconName = [NSArray arrayWithArray:[propertiesList objectForKey:@"iconName"]];
    mGalleryName = [NSArray arrayWithArray:[propertiesList objectForKey:@"galleryName"]];
    mGalleryIdentifier = [NSArray arrayWithArray:[propertiesList objectForKey:@"galleryIdentifier"]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mGalleryName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:25]];
        [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
    }
    cell.imageView.image = [UIImage imageNamed:[mIconName objectAtIndex:indexPath.row]];
    cell.textLabel.text = NSLocalizedString([mGalleryName objectAtIndex:indexPath.row], @"");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewController* tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:[mGalleryIdentifier objectAtIndex:indexPath.row]];
//    [self.navigationController pushViewController:tableViewController animated:YES];
    AlbumCollectionViewController* galleryCollectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AlbumCollectionViewController"];
    [self.navigationController pushViewController:galleryCollectionViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height / [mGalleryName count];
}

@end
