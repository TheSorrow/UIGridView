//
//  UIGridView.m
//  HorizontalGridView
//
//  Created by Amen on 01/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import "UIGridView.h"


@interface UIGridView()
{
    NSMutableArray* dataArray;
    NSMutableArray* cellIndexes;
    NSMutableArray* sectionViewHeaders;
    NSMutableArray* cellViews;
    NSMutableDictionary* recyler;
    CGSize defaultCellSize;
    NSInteger sectionStartIndex;
    CGSize lastKnownSize;
    BOOL _screenWillRotate;
}

@end

@implementation UIGridView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
        
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (void)_init
{
    _screenWillRotate = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)appWillChangeStatusBarOrientation:(NSNotification*)notif
{
    _screenWillRotate = YES;
}

- (void)reloadData
{
    sectionStartIndex = 0;
    dataArray = [NSMutableArray array];
    sectionViewHeaders = [NSMutableArray array];
    cellIndexes = [NSMutableArray array];
    cellViews = [NSMutableArray array];
    recyler = [NSMutableDictionary dictionary];
    int i = 0;
    NSArray* arr = [NSArray arrayWithObjects:@"10",@"20",@"50",@"20",@"30",@"20",@"40",@"20", nil];
    while (i<arr.count) {        NSMutableArray* section = [NSMutableArray array];
        int j = 0;
        [dataArray addObject:section];
        [cellViews addObject:[NSMutableArray array]];
        [cellIndexes addObject:[NSNumber numberWithInt:0]];
        NSInteger c = [arr[i] integerValue];
        while (j<c) {
            [section addObject:[NSString stringWithFormat:@"%d,%d",i,j]];
            j++;
        }
        i++;

    }
    
    i = 0;
    
    CGFloat cw = [self contentWidth];
    self.contentSize = CGSizeMake(cw, [self contentHeight]);
    [self render];
}

- (void)recycleItem:(NSString*)identifier view:(UIView*)item
{
    if (identifier==nil) {
        return;
    }
    NSMutableArray* items = recyler[identifier];
    if (items==nil) {
        items = [NSMutableArray array];
        recyler[identifier] = items;
    }
    
    [items addObject:item];
}
- (id)dequeueReusableItem:(NSString*)identifier
{
    NSMutableArray* items = recyler[identifier];
    if (items==nil || items.count==0) {
        return nil;
    }
    id item = items.firstObject;
    [items removeObjectAtIndex:0];
    return item;
}
- (void)pushSectionHeader:(UIGridHeaderView*)header
{
    [sectionViewHeaders addObject:header];
    [self addSubview:header];
}
- (void)unshiftSectionHeader:(UIGridHeaderView*)header
{
    [sectionViewHeaders insertObject:header atIndex:0];
    [self addSubview:header];
}

- (void)pushCellView:(UIGridCellView*)cell inSection:(NSInteger)sectionIndex
{
    NSMutableArray* array = cellViews[sectionIndex];
    [array addObject:cell];
    [self addSubview:cell];
}
- (void)unshiftCellView:(UIGridCellView*)cell inSection:(NSInteger)sectionIndex
{
    NSMutableArray* array = cellViews[sectionIndex];
    [array insertObject:cell atIndex:0];
    [self addSubview:cell];
}

- (void)removeSectionHeader:(UIGridHeaderView*)header
{
    [sectionViewHeaders removeObject:header];
    while ([self lastCellView:header.sectionIndex]) {
        [self removeCellView:[self lastCellView:header.sectionIndex] fromSection:header.sectionIndex];
    }
    [self recycleItem:@"UIGridHeaderView" view:header];
    [header removeFromSuperview];
}
- (void)removeCellView:(UIGridCellView*)view fromSection:(NSInteger)sectionIndex
{
    NSMutableArray* array = cellViews[sectionIndex];
    [self recycleItem:@"UIGridCellView" view:view];
    [array removeObject:view];
    [view removeFromSuperview];
}
- (NSInteger)sectionStartingIndex
{
    return 0;
}
- (void)render
{
    
    NSDate *start = [NSDate date];
    
    [self renderHeaders];
    NSInteger len = sectionViewHeaders.count;
    while (--len>=0) {
        UIGridHeaderView* header = sectionViewHeaders[len];
        [header updateSticky:self.contentOffset.x];
        [self renderCellsInSection:header];
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    
    NSLog(@"Execution Time: %f", executionTime);
    
    
    //[self renderCells];
}

- (void)renderCellsInSection:(UIGridHeaderView*)section
{
    NSInteger sectionIndex = section.sectionIndex;
    UIGridCellView* lastItem = [self lastCellView:sectionIndex];
    NSInteger sectionCellsStartingIndex = [cellIndexes[sectionIndex] integerValue];
    if (lastItem == nil) {
        UIGridCellView* cell = [self cellForItemAtIndex:sectionCellsStartingIndex inSection:section];
        if (cell) {
            [self pushCellView:cell inSection:sectionIndex];
        }
        
    }
    lastItem = [self lastCellView:sectionIndex];
    CGFloat frameWidth = self.frame.size.width;
    
    NSInteger cellArrayLen = [self numberOfCellsInSection:sectionIndex];
    while (lastItem && (lastItem.frame.origin.x)<(self.contentOffset.x+frameWidth) && lastItem.cellIndex<cellArrayLen-1) {
        UIGridCellView* cell = [self cellForItemAtIndex:lastItem.cellIndex+1 inSection:section];
        if (cell) {
            [self pushCellView:cell inSection:sectionIndex];
        }else break;
        lastItem = cell;
    }
    
    UIGridCellView* firstItem = [self firstCellView:sectionIndex];
    while (firstItem && (firstItem.frame.origin.x+firstItem.frame.size.width)>(self.contentOffset.x) && firstItem.cellIndex>0) {
        sectionCellsStartingIndex--;
        UIGridCellView* cell = [self cellForItemAtIndex:firstItem.cellIndex-1 inSection:section];
        if (cell) {
            [self unshiftCellView:cell inSection:sectionIndex];
        }else break;
        firstItem = cell;
    }
    
    firstItem = [self firstCellView:sectionIndex];
    
    while ( firstItem && (firstItem.frame.origin.x + firstItem.frame.size.width < self.contentOffset.x))
    {
        sectionCellsStartingIndex++;
        [self removeCellView:firstItem fromSection:sectionIndex];
        firstItem = [self firstCellView:sectionIndex];
        
    }
    lastItem = [self firstCellView:sectionIndex];
    while (lastItem && (lastItem.frame.origin.x - lastItem.frame.size.width> self.contentOffset.x + frameWidth))
    {
        [self removeCellView:lastItem fromSection:sectionIndex];
        lastItem = [self lastCellView: sectionIndex];
    }
    
    cellIndexes[sectionIndex] = [NSNumber numberWithInteger:sectionCellsStartingIndex];
}

- (void)renderHeaders
{
    //NSLog(@"contentOffset: %@", NSStringFromCGPoint(self.contentOffset));
    UIGridHeaderView* lastItem = [self lastSectionView];
    
    if (lastItem == nil) {
        UIGridHeaderView* sectionHeader = [self sectionHeaderAtIndex:sectionStartIndex];
        if (sectionHeader) {
            [self pushSectionHeader:sectionHeader];
        }
        
    }
    CGFloat frameWidth = self.frame.size.width;
    lastItem = [self lastSectionView];
    NSInteger sectionsDataLen = [self numberOfSections];
    while (lastItem && (lastItem.frame.size.width+lastItem.frame.origin.x)<(self.contentOffset.x+frameWidth) && lastItem.sectionIndex<sectionsDataLen-1) {
        UIGridHeaderView* sectionHeader = [self sectionHeaderAtIndex:lastItem.sectionIndex+1];
        if (sectionHeader) {
            [self pushSectionHeader:sectionHeader];
        }else break;
        lastItem = sectionHeader;
    }
    
    UIGridHeaderView* firstItem = [self firstSectionView];
    //NSLog(@"f: %f",f);
    while (firstItem && (firstItem.frame.origin.x)>(self.contentOffset.x) && firstItem.sectionIndex>0) {
        sectionStartIndex--;
        UIGridHeaderView* sectionHeader = [self sectionHeaderAtIndex:firstItem.sectionIndex-1];
        if (sectionHeader) {
            [self unshiftSectionHeader:sectionHeader];
        }else break;
        firstItem = sectionHeader;
    }
    
    firstItem = [self firstSectionView];
    
    while ( firstItem && (firstItem.frame.origin.x + firstItem.frame.size.width < self.contentOffset.x))
    {
        sectionStartIndex++;
        [self removeSectionHeader:firstItem];
        firstItem = [self firstSectionView];
        
    }
    lastItem = [self lastSectionView];
    while (lastItem && (lastItem.frame.origin.x - lastItem.frame.size.width> self.contentOffset.x + frameWidth))
    {
        [self removeSectionHeader:lastItem];
        lastItem = [self lastSectionView];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    //NSLog(@"ViewDidScroll: %f, %f", contentOffset.x, contentOffset.y);
    if (dataArray.count>0) {
        [self render];
    }
}


- (UIGridHeaderView*)firstSectionView
{
    if (sectionViewHeaders.count>0) {
        return sectionViewHeaders[0];
    }
    return nil;
}

- (UIGridHeaderView*)lastSectionView
{
    if (sectionViewHeaders.count>0) {
        return sectionViewHeaders[sectionViewHeaders.count-1];
    }
    return nil;
}

- (UIGridCellView*)firstCellView:(NSInteger)sectionIndex
{
    NSMutableArray* array = cellViews[sectionIndex];
    if (array.count>0) {
        return array[0];
    }
    return nil;
}

- (UIGridCellView*)lastCellView:(NSInteger)sectionIndex
{
    NSMutableArray* array = cellViews[sectionIndex];
    if (array.count>0) {
        return array[array.count-1];
    }
    return nil;
}

- (UIGridCellView*)cellForItemAtIndex:(NSInteger)cellIndex inSection:(UIGridHeaderView*)section
{
    UIGridCellView* cell =  [self dequeueReusableItem:@"UIGridCellView"];
    if(cell==nil)cell = [[UIGridCellView alloc] init];
    cell.cellIndex = cellIndex;
    cell.sectionIndex = section.sectionIndex;
    cell.title.text = [NSString stringWithFormat:@"%d,%d",cell.cellIndex,cell.sectionIndex];
    CGRect frame = [self cellFrameAtIndex:cellIndex inSection:section];
    cell.frame = frame;
    //UIColor *randomRGBColor = [[UIColor alloc] initWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0];
    cell.layer.cornerRadius = 8.0;
    cell.backgroundColor = [UIColor purpleColor];
    return cell;
}

- (CGRect)cellFrameAtIndex:(NSInteger)cellIndex inSection:(UIGridHeaderView*)section
{
    UIGridHeaderView* header = section;//sectionViewHeaders[sectionIndex];
    CGFloat startX = header.frame.origin.x;
    CGFloat startY = header.frame.origin.y+header.frame.size.height;
    int rows = floor(self.frame.size.height/defaultCellSize.height);
    CGFloat cellX = (cellIndex/rows)*defaultCellSize.width;
    CGFloat cellY = (cellIndex%rows)*defaultCellSize.height;
    return CGRectMake(startX+cellX, startY+cellY, defaultCellSize.width, defaultCellSize.height);
}

- (UIGridHeaderView*)sectionHeaderAtIndex:(NSInteger)index
{
   
    UIGridHeaderView* header =  [self dequeueReusableItem:@"UIGridHeaderView"];if(header==nil)header = [[UIGridHeaderView alloc] init];
    header.sectionIndex=index;
    header.frame = [self sectionFrameAtIndex:index];
    header.backgroundColor = [UIColor clearColor];
   [header setHeaderText:[NSString stringWithFormat:@"HEADER %ld",index]] ;
    return header;
}

- (NSInteger)numberOfSections
{
    return dataArray.count;
}
- (NSInteger)numberOfCellsInSection:(NSInteger)sectionIndex
{
    return ((NSArray*)dataArray[sectionIndex]).count;
}

- (CGRect)sectionFrameAtIndex:(NSInteger)index
{
    NSMutableArray* sectionArray = dataArray[index];
    if (defaultCellSize.height==0) {
        return CGRectZero;
    }
    double rows = floor([self contentHeight]/defaultCellSize.height);
    CGFloat s = defaultCellSize.width*ceil(sectionArray.count/rows);
    CGFloat frameX = 0.0;
    if (index>0) {
        CGRect previousFrame = [self sectionFrameAtIndex:index-1];
        frameX = previousFrame.origin.x+previousFrame.size.width;
    }
    return CGRectMake(frameX, 0, s, [self headerHeight]);
}
- (void)resizeSubViews
{
    NSInteger len = sectionViewHeaders.count;
    
    while (--len>=0) {
        UIGridHeaderView* header =  sectionViewHeaders[len];
        header.frame = [self sectionFrameAtIndex:header.sectionIndex];
        
        
        NSMutableArray* array = cellViews[header.sectionIndex];
        NSInteger cellsLen = array.count;
        while (--cellsLen>=0) {
            UIGridCellView* cell = array[cellsLen];
            cell.frame = [self cellFrameAtIndex:cell.cellIndex inSection:header];
            
            
        }
        
    }
    
    CGFloat cw = [self contentWidth];
    self.contentSize = CGSizeMake(cw, [self contentHeight]);
    [self render];
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (lastKnownSize.width!=self.frame.size.width || lastKnownSize.height != self.frame.size.height) {
        float h = self.frame.size.height-[self headerHeight];
        defaultCellSize = CGSizeMake(h/3, h/3);
        if (!_screenWillRotate) {
            [self resizeSubViews];
        }
        else{
            [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                 [self resizeSubViews];
            } completion:^(BOOL finished) {
                
            }];
            
            
        }
        
        lastKnownSize = self.frame.size;
    }
    
}

- (void)setFrame:(CGRect)frame;
{
    NSLog(@"%@", NSStringFromCGRect(frame));
    lastKnownSize = self.frame.size;
    [super setFrame:frame];
}



- (CGFloat)contentWidth
{
    NSInteger sections = [self numberOfSections];
    CGFloat cw = 0;
    while (--sections>=0) {
        cw += [self sectionFrameAtIndex:sections].size.width;
    }
    return cw;
}

- (CGFloat)contentHeight
{
    return self.bounds.size.height;
}
- (CGFloat)headerHeight
{
    return 60;
}
@end
