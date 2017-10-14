//
//  CardView.m
//  YSLDraggingCardContainerDemo
//
//  Created by yamaguchi on 2015/11/09.
//  Copyright © 2015年 h.yamaguchi. All rights reserved.
//

#import "CardView.h"

@interface CardView () <CMPageControlDelegate>
// ...
@end
@implementation CardView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionImages = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width) collectionViewLayout:flowLayout];
    [_collectionImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionImages.dataSource = self;
    _collectionImages.delegate = self;
    _collectionImages.pagingEnabled = YES;
    _collectionImages.directionalLockEnabled = YES;
    [self addSubview:_collectionImages];
    
    self.pageControl = [[CMPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width - 40, 0, 40, 100)];
    self.pageControl.numberOfElements = 3;

    self.pageControl.elementBackgroundColor =[UIColor whiteColor];
    self.pageControl.elementBorderColor = [UIColor blackColor];
    self.pageControl.elementWidth = 10.0f;
    self.pageControl.elementBorderWidth = 1.0f;
    self.pageControl.elementSelectedBorderWidth = 0.0f;
    self.pageControl.elementSelectedBackgroundColor = [UIColor blackColor];
    self.pageControl.orientation = CMPageControlOrientationVertical;
    self.pageControl.delegate = self;
  
    [self addSubview: _pageControl];
   
}
- (void)scrollImages:(NSArray *)imagesArray{
    _imagesArrayLocal = imagesArray;
    [_collectionImages reloadData];
}
#pragma mark- UICollectionView DataSource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imagesArrayLocal.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = (UICollectionViewCell *)[_collectionImages dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentMode = UIViewContentModeScaleAspectFill;
    _imageView = [[UIImageView alloc]init];
    _imageView.backgroundColor = [UIColor lightGrayColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width );
    NSURL *imageUrl = [NSURL URLWithString:[_imagesArrayLocal objectAtIndex:indexPath.item]];
    [_imageView sd_setImageWithURL:imageUrl];
    [cell.contentView addSubview:_imageView];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath{
   _pageControl.currentIndex=indexPath.item;
}

// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize mElementSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width);
    return mElementSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark- PageControl Delegate Delegate

- (void)elementClicked:(CMPageControl *)pageControl atIndex:(NSInteger)atIndex{
    CGRect frame = _collectionImages.frame;
    frame.origin.x = 0;
    frame.origin.y = _collectionImages.frame.size.height *atIndex;
    [_collectionImages scrollRectToVisible:frame animated:YES];
}
//- (void)should
@end
