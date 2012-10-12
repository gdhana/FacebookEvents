//
//  FacebookEventsResultsViewController.h
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

//#import <UIKit/UIKit.h>
//
//@interface FacebookEventsResultsViewController : UIViewController
//
//@end

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

typedef enum apiCall1 {
    kAPIGraphUserEvents1,
} apiCall1;

@interface FacebookEventsResultsViewController : UIViewController 
<FBRequestDelegate,
UITableViewDataSource,
UITableViewDelegate,EKEventEditViewDelegate>{
   
    int currentAPICall;
    NSMutableArray *myData;
    NSString *myAction;
    UILabel *messageLabel;
    UIView *messageView;
    UITableView *myTableView;
    
    EKEventStore* _eventStore;
}

@property (nonatomic, retain) NSMutableArray *myData;
@property (nonatomic, retain) NSString *myAction;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIView *messageView;
@property (nonatomic, retain) UITableView *myTableView;

@property (nonatomic, retain) NSArray* _events;
@property (nonatomic, retain) EKEventStore* _eventStore;

- (id)initWithTitle:(NSString *)title data:(NSArray *)data action:(NSString *)action;

- (void)addEvent: (id)sender;

@end
