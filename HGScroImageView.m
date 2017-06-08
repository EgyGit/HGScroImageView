//
//  HGScroImageView.m
//  DMC管理助手
//
//  Created by kingxing on 2015/11/3.
//  Copyright © 2015年 Yang. All rights reserved.
//

#import "HGScroImageView.h"
#import "UIImageView+WebCache.h"

@interface HGScroImageView ()

@property (nonatomic ,strong)NSArray *array;
@property (nonatomic ,strong)UIPageControl *page;
@property (nonatomic ,strong)UIImageView *firstView;
@property (nonatomic ,strong)UIImageView *middleView;
@property (nonatomic ,strong)UIImageView *lastView;
@property (nonatomic ,assign)float viewWidth;
@property (nonatomic ,assign)float viewHeight;
@property (nonatomic ,strong)NSTimer *autoScrollTimer;
@property (nonatomic ,strong)UITapGestureRecognizer *tap;
@property (nonatomic ,strong)UIScrollView *scro;
@property (nonatomic ,assign)NSInteger currentPage;

@end



@implementation HGScroImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.array = [NSArray array];
        
        _viewWidth = self.bounds.size.width;
        _viewHeight = self.bounds.size.height;
        
        //设置scrollview
        self.scro = [[UIScrollView alloc] init];
        self.scro.delegate = self;
        self.scro.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.scro.pagingEnabled = YES;
        self.scro.showsHorizontalScrollIndicator = NO;
        self.scro.bounces = NO;
        self.scro.contentSize = CGSizeMake(_viewWidth * 3, _viewHeight);
        [self addSubview:self.scro];
        //设置分页
        self.page = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.3, self.frame.size.height-20, self.frame.size.width * 0.4, 20)];
        self.page.userInteractionEnabled = NO;
        [self addSubview:self.page];
    }
    return self;
}

- (void)setImageWithImageArray:(NSArray *)array
{
    if (!(array && array.count > 0)) return;
    self.array = array;
    self.page.numberOfPages =array.count;
    _currentPage = 0;
    
    if (self.autoScrollTimer)
    {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    
    self.page.hidden = !(array.count > 2);
    self.scro.scrollEnabled = array.count > 2;
    if (array.count > 2)
    {
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoShowNextImage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.autoScrollTimer forMode:NSDefaultRunLoopMode];
    }
    [self reloadData];
}

#pragma mark 刷新view页面
-(void)reloadData
{
    [_firstView removeFromSuperview];
    [_middleView removeFromSuperview];
    [_lastView removeFromSuperview];
    
    //从数组中取到对应的图片view加到已定义的三个view中
    _firstView = [[UIImageView alloc] init];
    _firstView.contentMode = UIViewContentModeScaleAspectFill;
    
    _middleView = [[UIImageView alloc] init];
    _middleView.contentMode = UIViewContentModeScaleAspectFill;
    
    _lastView = [[UIImageView alloc] init];
    _lastView.contentMode = UIViewContentModeScaleAspectFill;
    
    _middleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoURL)];
    [_middleView addGestureRecognizer:tap2];
    
    [self.scro addSubview:_firstView];
    [self.scro addSubview:_middleView];
    [self.scro addSubview:_lastView];
    
    if (_currentPage == 0)
    {
        [_firstView sd_setImageWithURL:[NSURL URLWithString:[[self.array lastObject] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        [_middleView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        if (self.array.count > 2)
        {
            [_lastView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage+1] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        } else
        {
            [_lastView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        }
    }else if (_currentPage == _array.count - 1)
    {
        [_firstView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage - 1] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        [_middleView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        [_lastView sd_setImageWithURL:[NSURL URLWithString:[[self.array firstObject] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        
    }else
    {
        [_firstView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage - 1] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        [_middleView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        
        if (self.array.count > 2)
        {
            [_lastView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage + 1] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        } else
        {
            [_lastView sd_setImageWithURL:[NSURL URLWithString:[self.array[_currentPage] imgUrl]] placeholderImage:[UIImage imageNamed:@"jiazai"]];
        }
    }
    _firstView.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
    _middleView.frame = CGRectMake(_viewWidth, 0, _viewWidth, _viewHeight);
    _lastView.frame = CGRectMake(_viewWidth*2, 0, _viewWidth, _viewHeight);
    _page.currentPage = _currentPage;
    
    self.scro.contentOffset = CGPointMake(_viewWidth, 0);
    
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    //得到当前页数
    float x = _scro.contentOffset.x;
    
    //往前翻
    if (x<=0) {
        if (_currentPage-1<0) {
            _currentPage = _array.count-1;
        }else{
            _currentPage --;
        }
    }
    
    //往后翻
    if (x>=_viewWidth*2) {
        if (_currentPage ==_array.count-1) {
            _currentPage = 0;
        }else{
            _currentPage ++;
        }
    }
    
    [self reloadData];
}

- (void)gotoURL
{
    if (_currentPage <= self.array.count-1)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(OtherHeadView:didClickPageWithDataItem:)])
        {
            [self.delegate OtherHeadView:self didClickPageWithDataItem:self.array[_currentPage]];
        }
    }
}

#pragma mark 自动滚动
-(void)autoShowNextImage
{
    [self.scro setContentOffset:CGPointMake(_viewWidth * 2, 0) animated:YES];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_currentPage == _array.count-1) {
        _currentPage = 0;
    }else{
        _currentPage ++;
    }
    [self reloadData];
}
#pragma mark scrollvie停止滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.autoScrollTimer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.array.count > 2)
    {
        self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoShowNextImage) userInfo:nil repeats:YES];
    }
}


@end
