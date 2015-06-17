//
//  PumpViewController.h
//  IOSPumpDemo
//
//  Created by ITL on 27/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollView.h"
@import EnablerApi;

/**
 *  Pump Detail page
 */
@interface PumpViewController : UIViewController <PumpEventDelegates, UITableViewDataSource, UITableViewDelegate, ScrollViewDataSource,ScrollViewDelegate>

@property ENBPump* currentPump;

@end
