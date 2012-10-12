//
//  FacebookEventsDetailView.m
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

#import "FacebookEventsDetailView.h"
#import "FacebookEventsClassAppDelegate.h"
#import "FBConnect.h"
#import "FacebookEventsResultsViewController.h"
#import "FacebookEventsClassViewController.h"

// For re-using table cells
#define TITLE_TAG 1001
#define DESCRIPTION_TAG 1002

@implementation FacebookEventsDetailView


@synthesize savedAPIResult;
@synthesize activityIndicator;
@synthesize messageLabel;
@synthesize messageView;

- (id)initWithIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        childIndex = index;
        savedAPIResult = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc {
    
    [savedAPIResult release];
    [activityIndicator release];
    [messageLabel release];
    [messageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen
                                                  mainScreen].applicationFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    self.view = view;
    [view release];
    
    self.navigationItem.title = @"Facebook Functions";
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    //create the Event button
    eventbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    eventbutton.frame = CGRectMake(115, 138, 84, 44);
    eventbutton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [eventbutton setBackgroundImage:[[UIImage imageNamed:@"MenuButton.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:9]
                           forState:UIControlStateNormal];
    [eventbutton setTitle:@"Events" forState:UIControlStateNormal];
    [eventbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventbutton addTarget:self action:@selector(apiButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eventbutton];
    //eventbutton.hidden = YES;

     // Activity Indicator
    int xPosition = (self.view.bounds.size.width / 2.0) - 15.0;
    int yPosition = (self.view.bounds.size.height / 2.0) - 15.0;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(xPosition, yPosition, 30, 30)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:activityIndicator];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)addEvent: (id)sender {
}

#pragma mark - Private Helper Methods
/*
 * This method is called to store the check-in permissions
 * in the app session after the permissions have been updated.
 */
- (void)updateCheckinPermissions {
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate userPermissions] setObject:@"1" forKey:@"user_checkins"];
    [[delegate userPermissions] setObject:@"1" forKey:@"publish_checkins"];
}

/*
 * This method shows the activity indicator and
 * deactivates the table to avoid user input.
 */
- (void)showActivityIndicator {
    if (![activityIndicator isAnimating]) {
        
        [activityIndicator startAnimating];
    }
}

/*
 * This method hides the activity indicator
 * and enables user interaction once more.
 */
- (void)hideActivityIndicator {
    if ([activityIndicator isAnimating]) {
        [activityIndicator stopAnimating];
        
    }
}

/*
 * This method is used to display API confirmation and
 * error messages to the user.
 */
- (void)showMessage:(NSString *)message {
    CGRect labelFrame = messageView.frame;
    labelFrame.origin.y = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    messageView.frame = labelFrame;
    messageLabel.text = message;
    messageView.hidden = NO;
    
    // Use animation to show the message from the bottom then
    // hide it.
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect labelFrame = messageView.frame;
                         labelFrame.origin.y -= labelFrame.size.height;
                         messageView.frame = labelFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:3.0
                                                 options: UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  CGRect labelFrame = messageView.frame;
                                                  labelFrame.origin.y += messageView.frame.size.height;
                                                  messageView.frame = labelFrame;
                                              }
                                              completion:^(BOOL finished){
                                                  if (finished) {
                                                      messageView.hidden = YES;
                                                      messageLabel.text = @"";
                                                  }
                                              }];
                         }
                     }];
}

/*
 * This method hides the message, only needed if view closed
 * and animation still going on.
 */
- (void)hideMessage {
    messageView.hidden = YES;
    messageLabel.text = @"";
}

/*
 * This method handles any clean up needed if the view
 * is about to disappear.
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Hide the activitiy indicator
    [self hideActivityIndicator];
    // Hide the message.
    [self hideMessage];
}

/**
 * Helper method called when a button is clicked
 */
- (void)apiButtonClicked:(id)sender {
   
    [self getUserEvents];
}

/**
 * Helper method to parse URL query parameters
 */
- (NSDictionary *)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
        
		[params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
    return params;
}

#pragma mark - Facebook API Calls
/*
 * Graph API: Method to get the user's Events.
 */

- (void)apiGraphEvents {
    [self showActivityIndicator];
    // Do not set current API as this is commonly called by other methods
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
  //  NSLog(@"Token String : %@",[delegate facebook].accessToken);
    [[delegate facebook] requestWithGraphPath:@"me/events" andDelegate:self];
    
//        NSMutableDictionary *params2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [delegate facebook].accessToken, @"access_token",
//                                        @"TestFMGEvent", @"name",
//                                        @"2012-10-10", @"start_time",
//                                        nil];
//    
//        [[delegate facebook] requestWithGraphPath:@"me/events"
//                                        andParams:params2
//                                    andHttpMethod:@"POST"
//                                      andDelegate:self];
    
//    // Construct your FQL Query
//    NSString* fql = [NSString stringWithFormat:@"SELECT eid, name, description,venue, location, start_time FROM event WHERE eid IN (SELECT eid from event_member WHERE uid = me())"];
//    
//    // Create a params dictionary
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"query"];
//    
//    // Make the request
//    [[delegate facebook] requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"GET" andDelegate:self];

}

/*
 * --------------------------------------------------------------------------
 * Graph API
 * --------------------------------------------------------------------------
 */
/*
 * Graph API: Get the user's Events
 */
- (void)getUserEvents {
    currentAPICall = kAPIGraphUserEvents;
    [self apiGraphEvents];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    [self hideActivityIndicator];
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    switch (currentAPICall) {
        case kAPIGraphUserEvents:
        {
            NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:1];
            NSArray *resultData = [result objectForKey:@"data"];
            if ([resultData count] > 0) {
                for (NSUInteger i=0; i<[resultData count] && i < 25; i++) {
                    [events addObject:[resultData objectAtIndex:i]];
                }
                // Show the event information in a new view controller
                FacebookEventsResultsViewController *controller = [[FacebookEventsResultsViewController alloc]
                                                        initWithTitle:@"All Events"
                                                        data:events action:@""];
                [self.navigationController pushViewController:controller animated:YES];
                [controller release];
            } else {
                [self showMessage:@"You have no Events."];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Events" message:@"No Events" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
                                      [alert show];
            }
            [events release];
            break;
        }
        default:
            break;
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self hideActivityIndicator];
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    [self showMessage:@"Oops, something went haywire."];
}

@end
