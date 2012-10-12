//
//  FacebookEventsClassAppDelegate.h
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class FacebookEventsClassViewController;

@interface FacebookEventsClassAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    Facebook *facebook;
    NSMutableDictionary *userPermissions;
    UINavigationController *navigationController;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FacebookEventsClassViewController *viewController;

@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) NSMutableDictionary *userPermissions;

@end
