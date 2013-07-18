//
//  PromptShowText.m
//  ios
//
//  Created by Administrateur on 19/04/13.
//  Copyright (c) 2013 Ve-hotech. All rights reserved.
//

#import "ShowAlertView.h"

@implementation ShowAlertView

- (void) showToast:(NSString *)title message:(NSString *)message;
{
    NSArray * titleAndMessage = [[NSArray alloc]initWithObjects:title, message, nil];
    [self performSelectorOnMainThread:@selector(showToastInUiThread:) withObject:titleAndMessage  waitUntilDone:NO];
}


- (void) showToastInUiThread:(NSArray *) titleAndMessage
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[titleAndMessage objectAtIndex:0]
                                                        message:[titleAndMessage objectAtIndex:1]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok",@"")
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
