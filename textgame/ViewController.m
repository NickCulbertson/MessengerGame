//
//  ViewController.m
//  textgame
//
//  Created by Nick Culbertson on 12/8/17.
//  Copyright © 2017 Nick Culbertson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //first one
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(45, 30, 200, 40)];
    tf.textColor = [UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0];
    tf.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    tf.backgroundColor=[UIColor whiteColor];
    tf.text=@"Hello World";
    
    
    //second one
    UITextField *tf1 = [[UITextField alloc] initWithFrame:CGRectMake(45, tf.frame.origin.y+75, 200, 40)];
    tf1.textColor = [UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0];
    tf1.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    tf1.backgroundColor=[UIColor whiteColor];
    tf1.text=@"second field";
    
    //and so on adjust your view size according to your needs
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 400, 400)];
    [view addSubview:tf];
    [view addSubview:tf1];
    
    [self.view addSubview:view];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
