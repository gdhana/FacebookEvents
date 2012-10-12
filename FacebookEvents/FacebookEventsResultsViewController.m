//
//  FacebookEventsResultsViewController.m
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//

#import "FacebookEventsResultsViewController.h"
#import "FacebookEventsClassAppDelegate.h"

@interface FacebookEventsResultsViewController ()
-(void)reloadEvents;
@end 

@implementation FacebookEventsResultsViewController

@synthesize myData;
@synthesize myAction;
@synthesize messageLabel;
@synthesize messageView;
@synthesize _eventStore;
@synthesize myTableView;

- (id)initWithTitle:(NSString *)title data:(NSArray *)data action:(NSString *)action {
    self = [super init];
    if (self) {
        if (nil != data) {
            myData = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
        }
        self.navigationItem.title = [title retain];
        self.myAction = [action retain];
    }
    return self;
}

- (void)dealloc {
    [myData release];
    [myAction release];
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
    UIBarButtonItem *homeButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", @"") style:UIBarButtonItemStyleBordered  target:self action:@selector(addEvent:)] autorelease];
    [[self navigationItem] setRightBarButtonItem:homeButton];
    // Main Menu Table
    myTableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                            style:UITableViewStylePlain];
    [myTableView setBackgroundColor:[UIColor whiteColor]];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self.myAction isEqualToString:@"places"]) {
        UILabel *headerLabel = [[[UILabel alloc]
                                 initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)] autorelease];
        headerLabel.text = @"  Tap selection to check in";
        headerLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        headerLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                      green:248.0/255.0
                                                       blue:228.0/255.0
                                                      alpha:1];
        myTableView.tableHeaderView = headerLabel;
    }
    [self.view addSubview:myTableView];
    [myTableView release];
    
    // Message Label for showing confirmation and status messages
    CGFloat yLabelViewOffset = self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-30;
    messageView = [[UIView alloc]
                   initWithFrame:CGRectMake(0, yLabelViewOffset, self.view.bounds.size.width, 30)];
    messageView.backgroundColor = [UIColor lightGrayColor];
    
    UIView *messageInsetView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.view.bounds.size.width-1, 28)];
    messageInsetView.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                       green:248.0/255.0
                                                        blue:228.0/255.0
                                                       alpha:1];
    messageLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(4, 1, self.view.bounds.size.width-10, 26)];
    messageLabel.text = @"";
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    messageLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                   green:248.0/255.0
                                                    blue:228.0/255.0
                                                   alpha:0.6];
    [messageInsetView addSubview:messageLabel];
    [messageView addSubview:messageInsetView];
    [messageInsetView release];
    messageView.hidden = YES;
    [self.view addSubview:messageView];
    
    _eventStore = [[EKEventStore alloc] init];
    
    [self reloadEvents];
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
    EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
    controller.eventStore = _eventStore;
    controller.editViewDelegate = self;
    
    [self presentModalViewController: controller animated:YES];
    
    [controller release];
}
- (void)reloadEvents {
    CFGregorianDate gregorianStartDate, gregorianEndDate;
    CFGregorianUnits startUnits = {-1, 0, 0, 0, 0, 0};
    CFGregorianUnits endUnits = {1, 0, 0, 0, 0, 0};
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    
    gregorianStartDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits), timeZone);
    gregorianStartDate.hour = 0;
    gregorianStartDate.minute = 0;
    gregorianStartDate.second = 0;
    
    gregorianEndDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits), timeZone);
    gregorianEndDate.hour = 0;
    gregorianEndDate.minute = 0;
    gregorianEndDate.second = 0;
    
    NSDate* startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
    NSDate* endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
    
    CFRelease(timeZone);
    // calendars:nil == All calendars.
    NSPredicate* predicate = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    self._events = [_eventStore eventsMatchingPredicate:predicate];
}

- (void)didFinish {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
//    NSLog(@"Title : %@",controller.event.title);
//    NSLog(@"Startdate: %@",controller.event.startDate);
//    NSLog(@"Enddate: %@",controller.event.endDate);
//    NSLog(@"Location : %@",controller.event.location);
//    [self reloadEvents];
//    [myTableView reloadData];
//    [self dismissModalViewControllerAnimated:YES];


    NSError *error = nil;
	EKEvent *thisEvent = controller.event;
	
	switch (action) {
		case EKEventEditViewActionCanceled:
			// Edit action canceled, do nothing.
			break;
			
		case EKEventEditViewActionSaved:
			// When user hit "Done" button, save the newly created event to the event store,
			// and reload table view.
			// If the new event is being added to the default calendar, then update its
			// eventsList.
//			if (self.defaultCalendar ==  thisEvent.calendar) {
//				[self.eventsList addObject:thisEvent];
//			}
                NSLog(@"Title : %@",controller.event.title);
                NSLog(@"Startdate: %@",controller.event.startDate);
                NSLog(@"Enddate: %@",controller.event.endDate);
                NSLog(@"Location : %@",controller.event.location);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];

            NSString *stringFromDate = [formatter stringFromDate:controller.event.startDate];
            NSString *enddate = [formatter stringFromDate:controller.event.endDate];

            NSLog(@"String : %@",stringFromDate);
            FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableDictionary *params2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [delegate facebook].accessToken, @"access_token",
                                            controller.event.title, @"name",
                                            stringFromDate, @"start_time",
                                            controller.event.location,@"location",
                                            enddate,@"end_time",
                                            nil];
            
            [[delegate facebook] requestWithGraphPath:@"me/events"
                                            andParams:params2
                                        andHttpMethod:@"POST"
                                          andDelegate:self];
          //  [[delegate facebook] requestWithGraphPath:@"me/events" andDelegate:self];
            currentAPICall = kAPIGraphUserEvents1;
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			[self.myTableView reloadData];
			break;
			
		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store,
			// and reload table view.
			// If deleting an event from the currenly default calendar, then update its
			// eventsList.
//			if (self.defaultCalendar ==  thisEvent.calendar) {
//				[self.eventsList removeObject:thisEvent];
//			}
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			[self.myTableView reloadData];
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller dismissModalViewControllerAnimated:YES];

}
#pragma mark - Facebook API Calls
/*
 * Graph API: Check in a user to the location selected in the previous view.
 */
- (void)apiGraphUserCheckins:(NSUInteger)index {
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    FBSBJSON *jsonWriter = [[FBSBJSON new] autorelease];
    
    NSDictionary *coordinates = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[[myData objectAtIndex:index] objectForKey:@"location"] objectForKey:@"latitude"],@"latitude",
                                 [[[myData objectAtIndex:index] objectForKey:@"location"] objectForKey:@"longitude"],@"longitude",
                                 nil];
    
    NSString *coordinatesStr = [jsonWriter stringWithObject:coordinates];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [[myData objectAtIndex:index] objectForKey:@"id"], @"place",
                                   coordinatesStr, @"coordinates",
                                   @"", @"message",
                                   nil];
    [[delegate facebook] requestWithGraphPath:@"me/checkins"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
}


#pragma mark - Private Methods
/*
 * Helper method to return the picture endpoint for a given Facebook
 * object. Useful for displaying user, Event, or location pictures.
 */
- (UIImage *)imageForObject:(NSString *)objectID {
    // Get the object image
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",objectID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [url release];
    return image;
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
    [self hideMessage];
}

#pragma mark - UITableView Datasource and Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [myData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        // Show disclosure only if this view is related to showing nearby places, thus allowing
        // the user to check-in.
        if ([self.myAction isEqualToString:@"places"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.textLabel.text = [[myData objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 2;
    NSString *Detail =[NSString stringWithFormat:@"%@ , %@\n%@ , %@",[[myData objectAtIndex:indexPath.row] objectForKey:@"location"],[[myData objectAtIndex:indexPath.row] objectForKey:@"start_time"],[[myData objectAtIndex:indexPath.row] objectForKey:@"rsvp_status"],[[myData objectAtIndex:indexPath.row] objectForKey:@"end_time"]];
    cell.detailTextLabel.text = Detail;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    cell.detailTextLabel.numberOfLines = 2;
    // The object's image
    cell.imageView.image = [self imageForObject:[[myData objectAtIndex:indexPath.row] objectForKey:@"id"]];
    // Configure the cell.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only handle taps if the view is related to showing nearby places that
    // the user can check-in to.
    if ([self.myAction isEqualToString:@"places"]) {
        [self apiGraphUserCheckins:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
   // [self showMessage:@"Checked in successfully"];
    
    NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:1];
    NSArray *resultData = [result objectForKey:@"data"];
    switch (currentAPICall) {
        case kAPIGraphUserEvents1:
        {

        for (NSUInteger i=0; i<[resultData count] && i < 25; i++) {
            [events addObject:[resultData objectAtIndex:i]];
        }
        FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
        [[delegate facebook] requestWithGraphPath:@"me/events" andDelegate:self];
        myData = [[NSMutableArray alloc] initWithArray:events copyItems:YES];
        [myTableView reloadData];
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
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    [self showMessage:@"Oops, something went haywire."];
}

@end
