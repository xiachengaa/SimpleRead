//
//  DetailViewController.m
//  单读
//
//  Created by mac on 16/2/15.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImage+GIF.h"

@interface DetailViewController () {
    UIImageView *loading;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    loading = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"圆点转圈"];
    [loading setImage:image];
}

- (void)_createTitleView {
    _titleView = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _titleView.backgroundColor = [UIColor clearColor];
    _titleView.isTranslucent = YES;
    [self.view addSubview:_titleView];
    
    UIImage *back = [UIImage imageNamed:@"back_gray"];
    back = [back imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:back forState:UIControlStateNormal];
    [_backBtn setTintColor:[UIColor whiteColor]];
    [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [_titleView setLeftBarButton:_backBtn];
}

- (void)setArticle:(ArticleModel *)article {
    if (article != nil) {
        _article = article;
        [self setLayout];
        [self _createTitleView];
    }
}

- (void)setCalendar:(MyCalendarModel *)calendar {
    if (calendar != nil) {
        _calendar = calendar;
        [self setLayout];
        [self _createTitleView];
    }
}

- (void)setLayout {
    NSInteger model = [_article.model integerValue];
    switch (model) {
        case 1:
            [self notNeedPlayLayout];
            
            break;
        case 2:
            [self needPlayLayout:[NSURL URLWithString:_article.video]];

            break;
        case 3:
            [self needPlayLayout:[NSURL URLWithString:_article.fm]];

            
            break;
        case 4:
            [self notNeedPlayLayout];
            
            break;
            
//        case 5://消息
//            [self netNeedAnyLayout:[NSURL URLWithString:@"http://static.owspace.com/wap/291667.html?client=android&device_id=357566061490511&version=1.1.0&show_video=1"]];
//            
//            break;

        default:
            break;
    }
}

//- (void)netNeedAnyLayout:(NSURL *)url {
//    _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [_webView loadRequest:request];
//}

- (void)notNeedPlayLayout {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    NSString *urlStr = [_article.html5 stringByAppendingString:@"?client=iOS"];
    NSURL *url = [NSURL URLWithString:urlStr];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webView];
}

- (void)needPlayLayout:(NSURL *)url{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.4)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:_article.thumbnail]];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    _playerVC = [[MPMoviePlayerController alloc]initWithContentURL:url];
    if ([_article.model integerValue] == 2) {
        
        _playerVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.4);
    }
    else {
        _playerVC.view.frame = CGRectMake(0, kScreenHeight * 0.4 - 40, kScreenWidth, 40);
    }
    [_playerVC prepareToPlay];
    [imageView addSubview:_playerVC.view];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kScreenHeight * 0.4, kScreenWidth, kScreenHeight * 0.6)];
    [self.view addSubview:_webView];
    _webView.delegate = self;
    NSString *urlStr = [_article.html5 stringByAppendingString:@"?client=iOS"];
    NSURL *html5 = [NSURL URLWithString:urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:html5]];
}

- (void)back:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.view addSubview:loading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loading removeFromSuperview];
}

@end
