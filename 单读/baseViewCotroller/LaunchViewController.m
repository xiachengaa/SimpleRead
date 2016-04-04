//
//  LaunchViewController.m
//  单读
//
//  Created by mac on 16/2/14.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "LaunchViewController.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *device;
    if (kScreenHeight == 736) {
        device = @"6p";
    }
    else if (kScreenHeight == 568) {
        device = @"5";
    }
    else if (kScreenHeight == 667) {
        device = @"6";
    }
    else {
        device = @"4";
    }
    NSLog(@"%f",kScreenHeight);
    [self launchBegin:device];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)launchBegin:(NSString *)device {
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ruban%@",device]];
    self.frontImage.image = image;
    [self _setBackground];
}

- (void)_setBackground {
//    NSString *sandBox = NSHomeDirectory();
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"images.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        NSString *imgUrl = array[array.count - 1];
        [self.backImage sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
        [self animation];
    }
    else {
        [self _requestData:path];
    }
}

- (void)_requestData:(NSString *)path {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    NSURL *url = [NSURL URLWithString:@"http://static.owspace.com/static/picture_list.txt"];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
            NSArray *array = [responseObject objectForKey:@"images"];
            [array writeToFile:path atomically:YES];
            [weakSelf _setBackground];
        }
    }];
    [task resume];
}

- (void)animation {
    [UIView animateWithDuration:2.5 animations:^{
        self.backImage.transform = CGAffineTransformMakeTranslation(- 40, 0);
    } completion:^(BOOL finished) {
        [self launchFinish];
    }];
}

- (void)launchFinish{
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 0;
        
    } completion:^(BOOL finished) {
        UIViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"Main"];
        self.view.window.rootViewController = main;
    }];
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
