//
//  FacebookEventsDetailView.h
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

//#import <UIKit/UIKit.h>
//
//@interface FacebookEventsDetailView : UIViewController
//
//@end

#import <UIKit/UIKit.h>
#import "FBConnect.h"

typedef enum apiCall {
    kAPIGraphUserEvents,
} apiCall;

@interface FacebookEventsDetailView : UIViewController
<FBRequestDelegate,
FBDialogDelegate>{
    int currentAPICall;
    NSUInteger childIndex;
    NSMutableArray *savedAPIResult;
    UIActivityIndicatorView *activityIndicator;
    UILabel *messageLabel;
    UIView *messageView;
    UIButton *eventbutton;
}


@property (nonatomic, retain) NSMutableArray *savedAPIResult;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIView *messageView;

- (id)initWithIndex:(NSUInteger)index;

- (void)userDidGrantPermission;

- (void)userDidNotGrantPermission;

@end
