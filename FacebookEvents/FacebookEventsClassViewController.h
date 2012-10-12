//
//  FacebookEventsClassViewController.h
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FacebookEventsDetailView.h"

@interface FacebookEventsClassViewController : UIViewController
<FBRequestDelegate,
FBDialogDelegate,
FBSessionDelegate,
UITableViewDataSource,
UITableViewDelegate>{
    NSArray *permissions;
    
    //UIImageView *backgroundImageView;
    UIButton *loginButton;
    UILabel *nameLabel;
    UIImageView *profilePhotoImageView;
    UIButton *eventbutton;
    
    FacebookEventsDetailView *pendingApiCallsController;
}

@property (nonatomic, retain) NSArray *permissions;
//@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIImageView *profilePhotoImageView;
@property (nonatomic, retain) UIButton *eventbutton;


@end
