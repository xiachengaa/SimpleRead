//
//  HomeViewController.m
//  单读
//
//  Created by mac on 16/2/5.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "HomeViewController.h"
#import "ArticleModel.h"
#import "HomeCollectionCell.h"
#import "MyRefreshHeader.h"
#import "DetailViewController.h"

@interface HomeViewController ()
@end

@implementation HomeViewController {
    BOOL refreshFlag;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
//    注册单元格
    [self.collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.pagingEnabled = NO;
    self.articles = [NSMutableArray array];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self _createRefreshItem];
//    懒加载自定义的导航栏
    if (_navigationView == nil) {
        [self _createNavigationBar];
    }
//    懒加载获取数据
    if (_articles.count == 0) {
        [self _requestArticles];
    }
}
//创建自定义导航栏的方法
- (void)_createNavigationBar {
    _navigationView = [[TitleView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _navigationView.backgroundColor = [UIColor clearColor];
    _navigationView.title = @"单  读";
    _navigationView.isTranslucent = YES;
    
    UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    listBtn.frame = CGRectMake(0, 0, 40, 40);
    UIImage *listImg = [UIImage imageNamed:@"导航"];
    listImg = [listImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [listBtn setImage:listImg forState:UIControlStateNormal];
    [listBtn setTintColor:[UIColor whiteColor]];
    [listBtn addTarget:self action:@selector(openLeft) forControlEvents:UIControlEventTouchUpInside];
    _navigationView.leftBarButton = listBtn;
    
    UIButton *personBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    personBtn.frame = CGRectMake(0, 0, 40, 40);
    UIImage *personImg = [UIImage imageNamed:@"Profile"];
    personImg = [personImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [personBtn setImage:personImg forState:UIControlStateNormal];
    [personBtn setTintColor:[UIColor whiteColor]];
    [personBtn addTarget:self action:@selector(openRight) forControlEvents:UIControlEventTouchUpInside];
    _navigationView.rightBarButton = personBtn;
    
    [self.view addSubview:_navigationView];
}

//创建下拉条和上拉条
- (void)_createRefreshItem {
    self.collectionView.mj_header = [MyRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestArticles)];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(_requestMoreArticles)];
}

- (void)beginRefresh {
    [self.collectionView.mj_header beginRefreshing];
    [self _requestArticles];
}

#pragma mark - requestData

//请求文章数据
- (void)_requestArticles {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURL *url = [NSURL URLWithString:kRequestHomeArticle];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSArray *array = [responseObject objectForKey:@"datas"];
                [self.articles removeAllObjects];
                for (NSDictionary *dic in array) {
                    NSError *error = nil;
                    ArticleModel *article = [[ArticleModel alloc]initWithDictionary:dic error:&error];
                    [self.articles addObject:article];
                }
                if (weakSelf.collectionView.mj_header.isRefreshing) {
                    [weakSelf _reload];
                }
                [weakSelf.collectionView reloadData];
            }
        }
    }];
    [task resume];
}

- (void)_requestMoreArticles {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    int page = (int)_articles.count / 10 + 1;
    ArticleModel *article = [_articles lastObject];
    int page_id = [article.id intValue];
    int create_time = [article.create_time intValue];
    NSURL *url = [NSURL URLWithString:kRequestHomePageArticle(page, page_id, create_time)];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSArray *array = [responseObject objectForKey:@"datas"];
                for (NSDictionary *dic in array) {
                    NSError *error = nil;
                    ArticleModel *article = [[ArticleModel alloc]initWithDictionary:dic error:&error];
                    [self.articles addObject:article];
                }
                [weakSelf.collectionView.mj_footer endRefreshing];
                [self.collectionView reloadData];
            }
        }
    }];
    [task resume];
}

//刷新数据
- (void)_reload {
    refreshFlag = YES;
    [self.collectionView reloadData];
    [self.collectionView.mj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonAction

- (void)openLeft {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)openRight {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _articles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.article = _articles[indexPath.row];
    UIColor *color = [UIColor whiteColor];
    cell.backgroundColor = color;
    
    if (_articles.count - indexPath.row == 2) {
        [self _requestMoreArticles];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kScreenWidth, kScreenHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.article = _articles[indexPath.row];
    [self.navigationController showViewController:detail sender:nil];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat y = scrollView.contentOffset.y;
    if (y >= 0) {
        scrollView.pagingEnabled = YES;
        if (refreshFlag && y > 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    else {
        scrollView.pagingEnabled = NO;
        if (y < -60) {
            scrollView.contentOffset = CGPointMake(0, -60);
        }
    }
    CGFloat alpha = y>0 ? 1 : (60 + y)/60;
    self.navigationView.alpha = alpha;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    refreshFlag = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;
    if (y == -60) {
        [scrollView.mj_header beginRefreshing];
    }
}

@end
