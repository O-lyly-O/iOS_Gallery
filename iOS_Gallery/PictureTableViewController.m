//
//  PictureTableViewController.m
//  iOS_Gallery
//
//  Created by Charly Poilane on 18/07/13.
//  Copyright (c) 2013 CharlyPoilane. All rights reserved.
//

#import "PictureTableViewController.h"

@implementation PictureTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self browseDeviceGallery];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

-(void)browseDeviceGallery{
    if (!mAssetsLibrary) {
        mAssetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!mGroups) {
        mGroups = [[NSMutableArray alloc] init];
    } else {
        [mGroups removeAllObjects];
    }
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [mGroups addObject:group];
        } else {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = NSLocalizedString(@"userDeclinedAccess", @"");
                break;
            default:
                errorMessage = NSLocalizedString(@"errorAccessUnknow", @"");
                break;
        }
        ShowAlertView* alertView = [[ShowAlertView alloc]init];
        [alertView showToast:NSLocalizedString(@"accessError", @"") message:errorMessage];
    };
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [mAssetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:20]];
        [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
    }
    ALAssetsGroup *groupForCell = [mGroups objectAtIndex:indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell.imageView.image = posterImage;
    cell.textLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ListTableViewController* listTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ListTableViewController"];
    listTableViewController.mAssetsGroup = [mGroups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:listTableViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height / [mGroups count];
}

@end
