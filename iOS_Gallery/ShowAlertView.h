//
//  PromptShowText.h
//  ios
//
//  Created by Administrateur on 19/04/13.
//  Copyright (c) 2013 Ve-hotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShowAlertView : NSObject

- (void) showToast:(NSString *) title message:(NSString *) message;
- (void) showToastInUiThread:(NSArray *) titleAndMessage;

@end
