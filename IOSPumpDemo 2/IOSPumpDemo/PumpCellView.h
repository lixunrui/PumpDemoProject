//
//  PumpCellView.h
//  IOSPumpDemo
//
//  Created by ITL on 27/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PumpViewController.h"
@import EnablerApi;

/**
 *  Pump Cell View on forecourt page
 */
@interface PumpCellView : UITableViewCell <PumpEventDelegates>

- (void)setupPump:(ENBPump*)pump;

@end
