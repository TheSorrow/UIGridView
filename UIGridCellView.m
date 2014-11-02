//
//  UIGridCellView.m
//  HorizontalGridView
//
//  Created by Amen on 02/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import "UIGridCellView.h"

@implementation UIGridCellView


- (id)init
{
    self = [super init];
    if(self)
    {
        self.title = [[UITextView alloc] init];
        [self addSubview:self.title];
        self.title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0f];
        self.title.textColor = [UIColor whiteColor];
        self.title.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.title.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
