//
//  ScrollBarView.h
//  IOSPumpDemo
//
//  Created by ITL on 22/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScrollView;
/**
 *  Scroll View Protocol:
 */
@protocol ScrollViewDelegate <NSObject>
/**
 *  Return the item size that going to display inside the scroll view
 *
 *  @param scrollView scroll view
 *
 *  @return item size
 */
- (CGSize)itemSizeInScrollView:(ScrollView*)scrollView;

@optional
/**
 *  Indicate the current item after each slide operation
 *
 *  @param itemNumber current item number
 *  @param scrollView scroll view
 */
- (void)didScrollToItem:(NSInteger)itemNumber inScrollView:(ScrollView*)scrollView;

@end

/**
 *  Scroll view data source protocol
 */
@protocol ScrollViewDataSource <NSObject>

/**
 *  Returns the number of items that are going to be contained inside the scroll view
 *
 *  @param scrollView scroll view
 *
 *  @return number of items
 */
- (NSInteger)numberOfItemsInScrollView:(ScrollView*)scrollView;

/**
 *  Return each cell that contains a single item
 *
 *  @param scrollView scroll view
 *  @param index      index of a cell
 *
 *  @return a cell view
 */
-(UIView*)scrollView:(ScrollView*)scrollView
  cellForItemAtIndex:(NSInteger)index;

@end

/**
 *  Enumeration of the scroll view orientation
 */
typedef NS_ENUM(NSInteger, ScrollViewOrientation){
    /**
     *  Horizontal view
     */
    ScrollViewOrientationHorizontal,
    /**
     *  Vertical view
     */
    ScrollViewOrientationVertical,
};
@interface ScrollView : UIView <UIScrollViewDelegate>

@property(nonatomic, assign) id<ScrollViewDataSource>dataSource;
@property(nonatomic, assign) id<ScrollViewDelegate>delegate;

@property ScrollViewOrientation orientation;
@property(readonly) NSInteger currentIndex;

- (void)reloadData;

- (UIView *)dequeueReuseableCellFromIndex:(NSInteger)index;

- (void)scrollToItem:(NSInteger)itemNumber;

- (void)initialize;

- (void)initializeWithItemNumber:(NSInteger)itemNumber;

@end
