//
//  ScrollBarView.m
//  IOSPumpDemo
//
//  Created by ITL on 22/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView
{
    BOOL _needsReload;
    CGSize _itemSize;

    NSInteger _itemCount;

    NSMutableArray* _cells;
    NSMutableArray* _reusableCells;

    NSRange _visibleRange;

    UIScrollView* _scrollView;
}

#pragma mark - Init functions
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)reloadData
{
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (_needsReload) {
        // clear all data and reload

        if ([_dataSource respondsToSelector:@selector(numberOfItemsInScrollView:)]) {
            _itemCount = [_dataSource numberOfItemsInScrollView:self];
        }

        if ([_delegate respondsToSelector:@selector(itemSizeInScrollView:)]) {
            _itemSize = [_delegate itemSizeInScrollView:self];
        }

        _visibleRange = NSMakeRange(0, 0);

        // fillin array
        [_cells removeAllObjects];
        [_reusableCells removeAllObjects];
        for (NSInteger index = 0; index < _itemCount; index++) {
            [_cells addObject:[NSNull null]];
            [_reusableCells addObject:[NSNull null]];
        }

        // reset content size
        switch (_orientation) {
            case ScrollViewOrientationHorizontal:
            {
                // only display one item here
                [_scrollView setFrame:self.frame];

                // set all items as the content
                [_scrollView setContentSize:CGSizeMake(_itemSize.width * _itemCount, _itemSize.height)];

                [_scrollView setContentOffset:CGPointMake(_itemSize.width * _currentIndex, 0) animated:YES];

                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
            }
                break;
            case ScrollViewOrientationVertical:
            {
                [_scrollView setFrame:self.frame];

                [_scrollView setContentSize:CGSizeMake(_itemSize.width, _itemSize.height * _itemCount)];

                [_scrollView setContentOffset:CGPointMake(0, _itemSize.height * _currentIndex) animated:YES];

                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
            }
                break;
            default:
                break;
        }
        _needsReload = NO;
    }

    [self setItemAtContentOffset:_scrollView.contentOffset];
}

#pragma mark - initialization function
- (void)initializeWithItemNumber:(NSInteger)itemNumber
{
    [self initialize];

    _currentIndex = itemNumber;
}

- (void)initialize
{
    self.clipsToBounds = YES;

    _needsReload = YES;
    _itemSize = self.bounds.size;
    _itemCount = 0;
    _visibleRange = NSMakeRange(0, 0);


    _cells = [[NSMutableArray alloc]initWithCapacity:0];
    _reusableCells = [[NSMutableArray alloc]initWithCapacity:0];

    _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;

    // add a parent view for the scroll view, cause when the scroll view changes, it wil call the layoutSubViews and [super layoutSuberViews], add a parent view to pervent the current layoutSubViews be called
    UIView* superViewForScrollView = [[UIView alloc]initWithFrame:self.bounds];
    [superViewForScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [superViewForScrollView setBackgroundColor:[UIColor clearColor]];
    [superViewForScrollView addSubview:_scrollView];
    [self addSubview: superViewForScrollView];
}

- (void)setItemAtContentOffset:(CGPoint)offset
{
    // calculate visible range
    CGPoint startPoint = CGPointMake(offset.x - _scrollView.frame.origin.x, offset.y - _scrollView.frame.origin.y);

    CGPoint endPoint = CGPointMake(startPoint.x + self.bounds.size.width, startPoint.y + self.bounds.size.height);

    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    switch (_orientation) {
        case ScrollViewOrientationHorizontal:
        {
            //NSInteger startIndex = 0;

            for (NSInteger i = 0; i<[_cells count]; i++) {
                if (_itemSize.width * (i+1) > startPoint.x) {
                    startIndex = i;
                    break;
                }
            }

            endIndex = startIndex;
            for (NSInteger i = startIndex; i< [_cells count]; i++) {
                if ((_itemSize.width * (i+1) < endPoint.x &&_itemSize.width * (i+2) >= endPoint.x) || i+2 == [_cells count]) {
                    endIndex = i+1;
                    break;
                }
            }
        }
            break;
        case ScrollViewOrientationVertical:
        {
            //NSInteger startIndex = 0;

            for (NSInteger i = 0; i<[_cells count]; i++) {
                if (_itemSize.height * (i+1) > startPoint.y) {
                    startIndex = i;
                    break;
                }
            }

            endIndex = startIndex;
            for (NSInteger i = startIndex; i< [_cells count]; i++) {
                if ((_itemSize.height * (i+1) < endPoint.y &&_itemSize.height * (i+2) >= endPoint.y) || i+2 == [_cells count]) {
                    endIndex = i+1;
                    break;
                }
            }
        }
            break;
        default:
            break;
    }

    // expand the display range, prepare them in advance, in order to same time.
    startIndex = MAX(startIndex - 1, 0);
    endIndex = MIN(endIndex + 1, [_cells count] - 1);

    _visibleRange.location = startIndex;

    _visibleRange.length = endIndex - startIndex + 1;

    for (NSInteger i = startIndex; i <=endIndex; i++) {
        [self setItemAtIndex:i];
    }

    for (NSInteger i = 0 ; i< startIndex; i++) {
        [self removeCellAtIndex:i];
    }

    for (NSInteger i = endIndex + 1; i < [_cells count]; i++) {
        [self removeCellAtIndex:i];
    }
}

- (void)setItemAtIndex:(NSInteger)index
{
    NSParameterAssert(index >=0 && index < [_cells count]);

    UIView* cell= [_cells objectAtIndex:index];

    if ((NSObject*)cell == [NSNull null]) {
        cell = [_dataSource scrollView:self cellForItemAtIndex:index];

        if (cell != nil) {
            [_cells replaceObjectAtIndex:index withObject:cell];

            switch (_orientation) {
                case ScrollViewOrientationHorizontal:
                    cell.frame = CGRectMake(_itemSize.width * index, 0, _itemSize.width, _itemSize.height);
                    break;
                case ScrollViewOrientationVertical:
                    cell.frame = CGRectMake(0, _itemSize.height* index, _itemSize.width, _itemSize.height);
                    break;
                default:
                    break;
            }

            if (!cell.superview) {
                [_scrollView addSubview:cell];
            }

        }
    }
}

- (void)removeCellAtIndex:(NSInteger)index
{
    UIView* cell = [_cells objectAtIndex:index];
    if ((NSObject*)cell == [NSNull null]) {
        return;
    }

    if (cell.superview) {
        [cell removeFromSuperview];
    }

    [_cells replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)queueReuseableCell:(UIView*)cell
                  AtIndex:(NSInteger)index
{
    //[reuseableCells addObject:cell];
    [_reusableCells replaceObjectAtIndex:index withObject:cell];
}

- (UIView *)dequeueReuseableCellFromIndex:(NSInteger)index
{
    UIView* cell = [_reusableCells  objectAtIndex:index];
    if (cell) {
        [_reusableCells replaceObjectAtIndex:index withObject:[NSNull null]];
    }

    return cell;
}

- (void)scrollToItem:(NSInteger)itemNumber
{
    if (_currentIndex == itemNumber) {
        return;
    }
    if (itemNumber < _itemCount) {
        switch (_orientation) {
            case ScrollViewOrientationHorizontal:
                [_scrollView setContentOffset:CGPointMake(_itemSize.width * itemNumber, 0) animated:YES];
                break;
            case ScrollViewOrientationVertical:
                [_scrollView setContentOffset:CGPointMake(0, _itemSize.height * itemNumber) animated:YES];
                break;
            default:
                break;
        }
        _currentIndex = itemNumber;
        [self setItemAtContentOffset:_scrollView.contentOffset];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
        newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;

        //NSLog(@"Hit test: x: %f, Y: %f", newPoint.x,newPoint.y);

        if ([_scrollView pointInside:newPoint withEvent:event]) {
            return [_scrollView hitTest:newPoint withEvent:event];
        }

        return _scrollView;
    }

    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setItemAtContentOffset:scrollView.contentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger itemIndex;

    switch (_orientation) {
        case ScrollViewOrientationHorizontal:
            itemIndex = floor(_scrollView.contentOffset.x / _itemSize.width);
            break;
        case ScrollViewOrientationVertical:
            itemIndex = floor(_scrollView.contentOffset.y / _itemSize.height);
        default:
            break;
    }

    if (itemIndex<0 || itemIndex >= _itemCount) {
        return;
    }

    if ([_delegate respondsToSelector:@selector(didScrollToItem:inScrollView:)] && _currentIndex != itemIndex) {
        _currentIndex=itemIndex;
        [_delegate didScrollToItem:itemIndex inScrollView:self];
    }
}
@end
