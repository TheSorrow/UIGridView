//
//  ViewController.m
//  UIGridView
//
//  Created by Amen on 02/11/2014.
//  Copyright (c) 2014 thesorrow. All rights reserved.
//

#import "ViewController.h"
#import "UIGridView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIGridView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.scrollView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
