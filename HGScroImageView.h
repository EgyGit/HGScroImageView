//
//  HGScroImageView.h
//  DMC管理助手
//
//  Created by kingxing on 2015/11/3.
//  Copyright © 2015年 Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGScroImageViewDelegate;
@interface HGScroImageView : UIView<UIScrollViewDelegate>

@property (nonatomic, weak) id<HGScroImageViewDelegate> delegate;

- (void)setImageWithImageArray:(NSArray *)array;

@end

@protocol HGScroImageViewDelegate <NSObject>

@optional

- (void)HGScroImageView:(HGScroImageView *)view didClickPageWithDataItem:(id)dateItem;

@end

