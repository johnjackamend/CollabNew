//
//  CardView.h
//  YSLDraggingCardContainerDemo
//
//  Created by yamaguchi on 2015/11/09.
//  Copyright © 2015年 h.yamaguchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSLCardView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
@import CMPageControl;
@protocol CMPageControlDelegate;
@interface CardView : YSLCardView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) UIView * infoView;
@property (nonatomic, strong) UIButton *btnImage1;
@property (nonatomic, strong) UIButton *btnImage2;
@property (nonatomic, strong) UIButton *btnImage3;
@property (nonatomic, strong) NSArray *imagesArrayLocal;
@property (nonatomic, strong) UICollectionView *collectionImages;
@property (nonatomic, strong) CMPageControl *pageControl;

- (void)scrollImages:(NSArray*)imagesArray;

@end
