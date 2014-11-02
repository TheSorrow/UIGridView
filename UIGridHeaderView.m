//
//  UIGridHeaverView.m
//  HorizontalGridView
//
//  Created by Amen on 02/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import "UIGridHeaderView.h"

@interface UIGridHeaderView()
{
    CGFloat _contentOffset;
    CGSize _titleTextSize;
    CGRect _titleFrame;
}

@property(nonatomic,strong)UITextView *title;

@end

@implementation UIGridHeaderView

- (id)init
{
    self = [super init];
    if(self)
    {
        _contentOffset=0;
        self.title = [[UITextView alloc] init];
        [self addSubview:self.title];
        self.title.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:32.0f];
        self.title.textColor = [UIColor blackColor];
        self.title.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


- (void)setHeaderText:(NSString*)text
{
    self.title.text = text;
    NSDictionary *attributes = @{NSFontAttributeName: self.title.font};
    _titleTextSize = [self.title.text sizeWithAttributes:attributes];
    _titleTextSize.width+=15;
    
}

- (void)updateSticky:(CGFloat)contentOffset
{
    _contentOffset = contentOffset;
    
    
    CGFloat diff = contentOffset - self.frame.origin.x;
    if (diff<=0) {
        diff=0;
    }else
        if (self.bounds.size.width-diff<_titleTextSize.width) {
            diff=self.bounds.size.width- _titleTextSize.width;
        }
    _titleFrame.origin.x = diff;
    //_titleFrame.size.width = self.bounds.size.width-diff;
    self.title.frame = _titleFrame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self updateSticky:_contentOffset];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
