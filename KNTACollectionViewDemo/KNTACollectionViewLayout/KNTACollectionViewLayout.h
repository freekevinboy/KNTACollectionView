//
//  KNTACollectionViewLayout.h
//  KNTACollectionViewLayout
//
//  Created by Kevin on 2017/11/24.
//  Copyright © 2017年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KNTACollectionViewLayoutDataSource<NSObject>

@optional

//headerView
- (CGSize)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

//footerView
- (CGSize)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

//interitem count
- (NSInteger)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemCountAtSection:(NSInteger)section;

//item height
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout itemHightAtIndexPath:(NSIndexPath *)indexPath;

//edgeInsets of section
- (UIEdgeInsets)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

//line sapce
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

//interitem space
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

//if has item bigger than normal, the item equal to nomal's count
- (NSInteger)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout bigItemOccupySpaceAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface KNTACollectionViewLayout : UICollectionViewLayout

@property (weak, nonatomic) id<KNTACollectionViewLayoutDataSource> dataSource;


@end
