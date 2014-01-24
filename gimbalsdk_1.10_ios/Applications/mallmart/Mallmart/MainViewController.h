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
#import <UIKit/UIKit.h>
#import <ContextCore/QLContextCore.h>
#import <ContextLocation/QLContextPlaceConnector.h>
#import <ContextProfiling/PRContextInterestsConnector.h>

@interface MainViewController : UIViewController <QLContextCorePermissionsDelegate, QLContextPlaceConnectorDelegate, PRContextInterestsDelegate, QLTimeContentDelegate>

@property (nonatomic, strong) QLContextCoreConnector *contextCoreConnector;
@property (nonatomic, strong) QLContextPlaceConnector *contextPlaceConnector;
@property (nonatomic, strong) PRContextInterestsConnector *contextInterestsConnector;
@property (nonatomic, strong) QLContentConnector *contentConnector;


@property (unsafe_unretained, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *enableSDKButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *contentInfoLabel;

- (IBAction)enableSDK:(id)sender;
- (IBAction)showPermissions:(id)sender;

@end
