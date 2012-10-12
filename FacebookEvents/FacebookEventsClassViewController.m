//
//  FacebookEventsClassViewController.m
//  FacebookEvents
//
//  Created by Dhanasekar Gunabalan on 10/9/12.
//  Copyright (c) 2012 Dhanasekar Gunabalan. All rights reserved.
//


#import "FacebookEventsClassViewController.h"
#import "FacebookEventsClassAppDelegate.h"
#import "FBConnect.h"
#import "FacebookEventsDetailView.h"

@implementation FacebookEventsClassViewController

@synthesize permissions;
//@synthesize backgroundImageView;

@synthesize nameLabel;
@synthesize profilePhotoImageView;
@synthesize eventbutton;

- (void)dealloc {
    [permissions release];
   // [backgroundImageView release];
    [loginButton release];
    [eventbutton release];
    [nameLabel release];
    [profilePhotoImageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Facebook API Calls
/**
 * Make a Graph API Call to get information about the current logged in user.
 */
- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic FROM user WHERE uid=me()", @"query",
                                   nil];
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] requestWithMethodName:@"fql.query"
                                     andParams:params
                                 andHttpMethod:@"POST"
                                   andDelegate:self];
}

- (void)apiGraphUserPermissions {
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] requestWithGraphPath:@"me/permissions" andDelegate:self];
}


#pragma - Private Helper Methods

/**
 * Show the logged in menu
 */

- (void)showLoggedIn {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //self.backgroundImageView.hidden = YES;
    loginButton.hidden = YES;
    eventbutton.hidden = NO;
    
    [self apiFQLIMe];
}

/**
 * Show the logged in menu
 */

- (void)showLoggedOut {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
   // self.backgroundImageView.hidden = NO;
    loginButton.hidden = NO;
    eventbutton.hidden = YES;
    // Clear personal info
    nameLabel.text = @"";
    // Get the profile image
    [profilePhotoImageView setImage:nil];
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

/**
 * Show the authorization dialog.
 */
- (void)login {
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        [[delegate facebook] authorize:permissions];
    } else {
        [self showLoggedIn];
    }
}

/**
 * Invalidate the access token and clear the cookie.
 */
- (void)logout {
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] logout];
}

/**
 * Helper method called when a menu button is clicked
 */
- (void)menuButtonClicked:(id)sender {
    FacebookEventsDetailView *controller = [[FacebookEventsDetailView alloc]
                                          initWithIndex:[sender tag]];
    pendingApiCallsController = controller;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void) viewDidLoad {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen
                                                  mainScreen].applicationFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    self.view = view;
    [view release];
    
    // Initialize permissions
    permissions = [[NSArray alloc] initWithObjects:@"offline_access", nil];
    
    // Set up the view programmatically
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"Facebook SDK";
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
//  Create A backgroung Image 
//    NSString *backgroundImageName = @"Default.png";
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
//            CGSize result = [[UIScreen mainScreen] bounds].size;
//            CGFloat scale = [UIScreen mainScreen].scale;
//            result = CGSizeMake(result.width * scale, result.height * scale);
//            if(result.height == 1136) {
//                backgroundImageName = @"Default-568h";
//            }
//        }
//    }
//    [backgroundImageView setImage:[UIImage imageNamed:backgroundImageName]];
//    //[backgroundImageView setAlpha:0.25];
//    [self.view addSubview:backgroundImageView];
    
    // Login Button
    loginButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    CGFloat xLoginButtonOffset = self.view.center.x - (318/2);
    CGFloat yLoginButtonOffset = self.view.bounds.size.height - (58 + 13);
    loginButton.frame = CGRectMake(xLoginButtonOffset,yLoginButtonOffset,318,58);
    [loginButton addTarget:self
                    action:@selector(login)
          forControlEvents:UIControlEventTouchUpInside];
    [loginButton setImage:
     [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookNormal@2x.png"]
                 forState:UIControlStateNormal];
    [loginButton setImage:
     [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookPressed@2x.png"]
                 forState:UIControlStateHighlighted];
    [loginButton sizeToFit];
    [self.view addSubview:loginButton];
    
    
    //create the Event button
    eventbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    eventbutton.frame = CGRectMake(115, 138, 84, 44);
    eventbutton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    [eventbutton setBackgroundImage:[[UIImage imageNamed:@"MenuButton.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:9]
                forState:UIControlStateNormal];
    [eventbutton setTitle:@"Users" forState:UIControlStateNormal];
    [eventbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventbutton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eventbutton];
    eventbutton.hidden = YES;
    
    //The profilePhotoImageView Initialization
    CGFloat xProfilePhotoOffset = self.view.center.x - 25.0;
    profilePhotoImageView = [[UIImageView alloc]
                             initWithFrame:CGRectMake(xProfilePhotoOffset, 20, 50, 50)];
    profilePhotoImageView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:profilePhotoImageView];
    
    //Username Label Initialization 
    nameLabel = [[UILabel alloc]
                 initWithFrame:CGRectMake(0, 75, self.view.bounds.size.width, 20.0)];
    nameLabel.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    nameLabel.textAlignment = UITextAlignmentCenter;
    nameLabel.text = @"";
    [self.view addSubview:nameLabel];
        
    pendingApiCallsController = nil;
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        [self showLoggedOut];
    } else {
        [self showLoggedIn];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)addEvent: (id)sender {

}


- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    [self showLoggedIn];
    
    FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
    
    [pendingApiCallsController userDidGrantPermission];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
   [pendingApiCallsController userDidNotGrantPermission];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    pendingApiCallsController = nil;
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self showLoggedOut];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [alertView release];
    [self fbDidLogout];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([result objectForKey:@"name"]) {
        // If basic information callback, set the UI objects to
        // display this.
        nameLabel.text = [result objectForKey:@"name"];
        // Get the profile image
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"pic"]]]];
        
        // Resize, crop the image to make sure it is square and renders
        // well on Retina display
        float ratio;
        float delta;
        float px = 100; // Double the pixels of the UIImageView (to render on Retina)
        CGPoint offset;
        CGSize size = image.size;
        if (size.width > size.height) {
            ratio = px / size.width;
            delta = (ratio*size.width - ratio*size.height);
            offset = CGPointMake(delta/2, 0);
        } else {
            ratio = px / size.height;
            delta = (ratio*size.height - ratio*size.width);
            offset = CGPointMake(0, delta/2);
        }
        CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                     (ratio * size.width) + delta,
                                     (ratio * size.height) + delta);
        UIGraphicsBeginImageContext(CGSizeMake(px, px));
        UIRectClip(clipRect);
        [image drawInRect:clipRect];
        UIImage *imgThumb = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [profilePhotoImageView setImage:imgThumb];
        
        [self apiGraphUserPermissions];
    } else {
        // Processing permissions information
        FacebookEventsClassAppDelegate *delegate = (FacebookEventsClassAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate setUserPermissions:[[result objectForKey:@"data"] objectAtIndex:0]];
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}

@end
