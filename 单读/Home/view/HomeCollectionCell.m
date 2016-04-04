//
//  HomeCollectionCell.m
//  单读
//
//  Created by mac on 16/2/5.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "HomeCollectionCell.h"

static BOOL isPlay = NO;

@implementation HomeCollectionCell

- (void)awakeFromNib {
    
}

- (void)setArticle:(ArticleModel *)article {
    if (article) {
        _article = article;
        NSURL *postURL = [NSURL URLWithString:_article.thumbnail];
        [self.postView sd_setImageWithURL:postURL];
        self.tipLabel.text = [NSString stringWithFormat:@" %@",_article.category];
        [self setTipLabelAttribute];
        self.title.text = [self _clearLineBreak:article.title];
        self.lead.text = article.excerpt;
        [self setSpaceAttribute:self.title];
        [self setSpaceAttribute:self.lead];
        self.author.text = article.author;
        self.readCount.text = [NSString stringWithFormat:@"阅读数：%@",article.view];
        [self.commentBtn setTitle:article.comment forState:UIControlStateNormal];
        [self.likeBtn setTitle:article.good forState:UIControlStateNormal];
        
        if (!_playImg) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            view.center = CGPointMake(kScreenWidth/2, kScreenHeight * 0.2);
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 30;
            view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
            _playImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            [view addSubview:_playImg];
            [_postView addSubview:view];
        }
        
        switch ([_article.model integerValue]) {
            case 1:
                _play.hidden = YES;
                _playImg.superview.hidden = YES;
                break;
            case 2:
                _play.hidden = NO;
                _playImg.superview.hidden = NO;
                _playImg.image = [UIImage imageNamed:@"视频"];

                break;
            case 3:
                _play.hidden = NO;
                _playImg.superview.hidden = NO;
                _playImg.image = [UIImage imageNamed:@"音频"];

                break;
                
            default:
                
                break;
        }
    }
}

- (NSString *)_clearLineBreak:(NSString *)string {
    NSString *subStrng = [string substringWithRange:NSMakeRange(string.length - 2, 2)];
    if ([subStrng isEqualToString:@"\r\n"]) {
        string = [string substringWithRange:NSMakeRange(0, string.length - 2)];
    }
    return string;
}

- (void)setTipLabelAttribute {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:self.tipLabel.text];
    [attrString addAttribute:NSKernAttributeName value:@5 range:NSMakeRange(0, attrString.length)];
    self.tipLabel.attributedText = attrString;
}

- (void)setSpaceAttribute:(UILabel *)label {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:label.text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:12];
    [style setAlignment:NSTextAlignmentCenter];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    label.attributedText = attrString;
}

- (IBAction)play:(id)sender {
    _playImg.superview.hidden = YES;
    if (!isPlay) {
        if ([_article.model integerValue] == 2) {
            
            _playerVC = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:_article.video]];
            _playerVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.4);
        }
        else {
            _playerVC = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:_article.fm]];
            _playerVC.view.frame = CGRectMake(0, kScreenHeight * 0.4 - 40, kScreenWidth, 40);
        }
        [_playerVC prepareToPlay];
        [self insertSubview:_playerVC.view aboveSubview:_play];
        isPlay = YES;
    }
}

- (void)prepareForReuse {
    [_playerVC.view removeFromSuperview];
    [_playerVC stop];
    isPlay = NO;
}

@end
