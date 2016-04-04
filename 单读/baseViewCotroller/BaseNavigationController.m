//
//  BaseNavigationController.m
//  单读
//
//  Created by mac on 16/2/2.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "BaseNavigationController.h"



@interface BaseNavigationController () {
    UIButton *backBtn;
}

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
//    _myNavigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
//    [self changeNavigationBarAlpha:1];
//    [self.view addSubview:_myNavigationBar];
//    [self addBackButton];
//    self.delegate = self;
}

- (void)addBackButton {
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 25, 30, 30);
    UIImage *back = [UIImage imageNamed:@"back_gray"];
    back = [back imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backBtn setImage:back forState:UIControlStateNormal];
    [backBtn setTintColor:[UIColor whiteColor]];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_myNavigationBar addSubview:backBtn];
}

- (void)changeNavigationBarAlpha:(CGFloat)alpha {
    _myNavigationBar.backgroundColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:alpha];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1) {
        backBtn.hidden = YES;
    }
    else {
        backBtn.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
