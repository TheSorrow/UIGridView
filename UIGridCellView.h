//
//  UIGridCellView.h
//  HorizontalGridView
//
//  Created by Amen on 02/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGridCellView : UIView
@property(nonatomic,assign)NSInteger cellIndex;
@property(nonatomic,assign)NSInteger sectionIndex;
@property(nonatomic,strong)UITextView *title;
@property(nonatomic,strong)UIImageView *imageView;
@end
