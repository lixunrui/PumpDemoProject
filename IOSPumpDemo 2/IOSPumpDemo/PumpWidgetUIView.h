//
//  TestClick.h
//  PumpUIDemo2
//
//  Created by Raymond Li on 30/03/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EnablerApi/PumpPublic.h>

/**
 *  Contains all pump elements that use to display at pump detail page
 */
@interface PumpWidgetUIView : UIView  <UIGestureRecognizerDelegate,PumpEventDelegates, UIActionSheetDelegate>

- (void)setPump:(ENBPump*)pump;

- (void)initialization;

- (void)reloadLayout;

@end
