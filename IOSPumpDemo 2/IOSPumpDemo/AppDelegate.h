//
//  AppDelegate.h
//  IOSPumpDemo
//
//  Created by ITL on 20/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
@class LoginViewController;
@import EnablerApi;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ForecourtDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) MainViewController* tabbarController;
@property (strong, nonatomic) UIWindow *window;
/**
 *  Forecourt object
 */
@property (nonatomic) ENBForecourt* forecourt;
/**
 *  Indicate the Forecourt connection status
 */
@property BOOL isConnected;

@end

