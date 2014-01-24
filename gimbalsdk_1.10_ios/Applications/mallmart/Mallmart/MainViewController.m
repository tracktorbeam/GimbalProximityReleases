/**
 * Copyright (C) 2011 Qualcomm Retail Solutions, Inc. All rights reserved.
 *
 * This software is the confidential and proprietary information of Qualcomm Retail Solutions, Inc.
 *
 * The following sample code illustrates various aspects of the Gimbal SDK.
 *
 * The sample code herein is provided for your convenience, and has not been
 * tested or designed to work on any particular system configuration. It is
 * provided AS IS and your use of this sample code, whether as provided or with
 * any modification, is at your own risk. Neither Qualcomm Retail Solutions, Inc. nor any
 * affiliate takes any liability nor responsibility with respect to the sample
 * code, and disclaims all warranties, express and implied, including without
 * limitation warranties on merchantability, fitness for a specified purpose,
 * and against infringement.
 */
#import "MainViewController.h"
#import "ContentViewController.h"

#import <ContextLocation/QLPlace.h>
#import <ContextLocation/QLPlaceEvent.h>
#import <ContextLocation/QLContentDescriptor.h>

#import <ContextProfiling/PRProfile.h>


@interface MainViewController ()

- (void)displayLastKnownPlaceEvent;
- (void)savePlaceEvent:(QLPlaceEvent *)placeEvent;
- (void)displaceLastKnownContentDescriptor;

@end

@implementation MainViewController

@synthesize contextCoreConnector;
@synthesize contextPlaceConnector;
@synthesize contextInterestsConnector;

@synthesize enableSDKButton;
@synthesize contentInfoLabel;
@synthesize placeNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.title = @"Mallmart";
        
        self.contextCoreConnector = [[QLContextCoreConnector alloc] init];
        self.contextCoreConnector.permissionsDelegate = self;
        
        self.contextPlaceConnector = [[QLContextPlaceConnector alloc] init];
        self.contextPlaceConnector.delegate = self;
        
        self.contextInterestsConnector = [[PRContextInterestsConnector alloc] init];
        self.contextInterestsConnector.delegate = self;
        
        NSLog(@"Initializing connector");
        
        self.contentConnector = [[QLContentConnector alloc] init];
        self.contentConnector.delegate = self;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
#endif
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self.contextCoreConnector checkStatusAndOnEnabled:^(QLContextConnectorPermissions *contextConnectorPermissions) {
        if (contextConnectorPermissions.subscriptionPermission)
        {
            if (contextPlaceConnector.isPlacesEnabled)
            {
                [self displayLastKnownPlaceEvent];
            }
        }
    }
                                              disabled:^(NSError *error) {
                                                  NSLog(@"%@", error);
                                                  if (error.code == QLContextCoreNonCompatibleOSVersion)
                                                  {
                                                      NSLog(@"%@", @"SDK Requires iOS 5.0 or higher");
                                                  }
                                                  else
                                                  {
                                                      enableSDKButton.enabled = YES;
                                                      self.placeNameLabel.text = nil;
                                                      self.contentInfoLabel.text = nil;
                                                  }
                                              }];
}

- (void)viewDidUnload
{
    [self setEnableSDKButton:nil];
    [self setPlaceNameLabel:nil];
    [self setContentInfoLabel:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    NSLog(@"dealloc called in view controller");
}

- (IBAction)enableSDK:(id)sender
{
    [contextCoreConnector enableFromViewController:self.navigationController
                                           success:^{
                                               enableSDKButton.enabled = NO;
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"%@", error);
                                           }];
}

- (IBAction)showPermissions:(id)sender
{
    [contextCoreConnector showPermissionsFromViewController:self success:NULL failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)displayLastKnownPlaceEvent
{
    self.placeNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PlaceEventKey"];
}

- (void)savePlaceEvent:(QLPlaceEvent *)placeEvent
{
    NSString *placeTitle = nil;
    switch (placeEvent.eventType)
    {
        case QLPlaceEventTypeAt:
            placeTitle = [NSString stringWithFormat:@"At %@", placeEvent.place.name];
            break;
        case QLPlaceEventTypeLeft:
            placeTitle = [NSString stringWithFormat:@"Left %@", placeEvent.place.name];
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:placeTitle forKey:@"PlaceEventKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)displaceLastKnownContentDescriptor
{
    [self.contextPlaceConnector requestContentHistoryAndOnSuccess:^(NSArray *contentHistories) {
        if ([contentHistories count] > 0)
        {
            QLContentDescriptor *lastKnownContentDescriptor = [contentHistories objectAtIndex:0];
            self.contentInfoLabel.text = lastKnownContentDescriptor.title;
        }
    }
                                                          failure:^(NSError *error) {
                                                              NSLog(@"Failed to fetch content: %@", [error localizedDescription]);
                                                          }];
}

- (void)postOneContentDescriptorLocalNotification:(QLContentDescriptor *)contentDescriptor
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertAction = NSLocalizedString(@"Foo", nil);
    localNotification.alertBody = [NSString stringWithFormat:@"%@", contentDescriptor.title];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


#pragma mark - QLContextCorePermissionsDelegate methods

- (void)subscriptionPermissionDidChange:(BOOL)subscriptionPermission
{
    if (subscriptionPermission)
    {
        if (contextPlaceConnector.isPlacesEnabled)
        {
            [self displayLastKnownPlaceEvent];
        }
        else
        {
            self.placeNameLabel.text = @"";
        }
        enableSDKButton.enabled = NO;
    }
    else
    {
        self.placeNameLabel.text = @"";
        self.contentInfoLabel.text = @"";
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self.contextCoreConnector checkStatusAndOnEnabled:NULL
                                                  disabled:^(NSError *error) {
                                                      enableSDKButton.enabled = YES;
                                                  }];
    }
}


#pragma mark - QLContextPlaceConnectorDelegate methods

- (void)didGetPlaceEvent:(QLPlaceEvent *)placeEvent
{
    NSLog(@"Got place event");
    [self savePlaceEvent:placeEvent];
    [self displayLastKnownPlaceEvent];
}

- (void)didGetContentDescriptors:(NSArray *)contentDescriptors
{
    self.contentInfoLabel.text = [[contentDescriptors lastObject] title];
    
    [self displaceLastKnownContentDescriptor];
    
    for (QLContentDescriptor *contentDescriptor in contentDescriptors)
    {
        [self postOneContentDescriptorLocalNotification:contentDescriptor];
    }
    
}

- (void)placesPermissionDidChange:(BOOL)placesPermission
{
    if (placesPermission)
    {
        [self displayLastKnownPlaceEvent];
        [self displaceLastKnownContentDescriptor];
    }
    else
    {
        self.placeNameLabel.text = @"Location Permission turned off by user";
        self.contentInfoLabel.text = @"";
    }
}

-(void) didReceiveNotification:(QLContentNotification *)notification
                      appState:(QLNotificationAppState)appState
{
    NSLog(@"mallmart: didReceiveNotification: %@ - %d", notification.message, appState);
    [self.contentConnector contentWithId:notification.contentId
                                 success:^(QLContent *content)
     {
         NSLog(@"requestContentForId: success: %@", content.title);
         
         ContentViewController *contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
         contentViewController.content = content;
         
         [self.navigationController presentModalViewController:contentViewController animated:YES];
     }
                                 failure:^(NSError *error)
     {
         NSLog(@"requestContentForId: error: %@", error);
     }];
}

@end
