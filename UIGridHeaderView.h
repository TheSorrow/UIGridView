//
//  UIGridHeaverView.h
//  HorizontalGridView
//
//  Created by Amen on 02/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGridHeaderView : UIView

@property(nonatomic,assign)NSInteger sectionIndex;

- (void)updateSticky:(CGFloat)contentOffset;
- (void)setHeaderText:(NSString*)text;
@end
