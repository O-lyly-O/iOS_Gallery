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
    NSDictionary* propertiesList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Property List" ofType:@"plist"]];
    mIconName = [NSArray arrayWithArray:[propertiesList objectForKey:@"iconName"]];
    mGalleryName = [NSArray arrayWithArray:[propertiesList objectForKey:@"galleryName"]];
    [self.tableView setBounces:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mGalleryName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.height / [mGalleryName count];
}

@end
