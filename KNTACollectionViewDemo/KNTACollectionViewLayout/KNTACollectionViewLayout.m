//
//  KNTACollectionViewLayout.m
//  KNTACollectionViewLayout
//
//  Created by Kevin on 2017/11/24.
//  Copyright © 2017年 Kevin. All rights reserved.
//

#import "KNTACollectionViewLayout.h"



#define kCollectionSize self.collectionView.bounds.size

#define kInteritemSpace(section) [self interitemSpaceOfSection:section]

#define kEdgeInsets(section) [self edgeInsetsOfSection:section]

#define kInteritemCount(section) [self interitemCountOfSection:section]

#define kItemHight(indexPath) [self heightOfItem:indexPath]

#define kMaxHight(interitemHeights, p) [self maxHeight:interitemHeights index:p]

#define kMinHight(interitemHeights, p) [self minHeight:interitemHeights index:p]

#define kLineSpace(section) [self lineSpaceOfSection:section]

#define kHeaderHeight(section) [self heightOfHeaderView:section]

#define kFooterHeight(section) [self heightOfFooterView:section]

#define kBigItemOccupySpace(indexPath) [self bigItemOccupySpaceAtIndexPath:indexPath]


@interface KNTACollectionViewLayout ()

@property (strong, nonatomic) NSMutableArray *attributesArray;

@property (strong, nonatomic) NSMutableArray *interitemHeights;

@end


#pragma mark // 缺省参数
//行距
static CGFloat const KNTACollectionViewDefaultLineSpace = 10;
//列距
static CGFloat const KNTACollectionViewDefaultInteritemSpace = 10;
//边距
static UIEdgeInsets const KNTACollectionViewDefaultEdgeInsets = {15, 15, 15, 15};
//列数
static NSInteger const KNTACollectionViewDefaultInteritemCount = 2;


@implementation KNTACollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.attributesArray = [[NSMutableArray alloc] init];
        
        self.interitemHeights = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.attributesArray.count) {
        [self.attributesArray removeAllObjects];
        [self.interitemHeights removeAllObjects];
    }
    
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    for (int i = 0; i < sectionCount; i++) {
        
        NSMutableArray *heights = [[NSMutableArray alloc] init];
        
        CGFloat maxHeight = 0;
        if (i > 0) {
            maxHeight = kMaxHight([_interitemHeights objectAtIndex:i - 1], NULL);
        }
        
        for (int interitemCount = 0; interitemCount < kInteritemCount(i); interitemCount++) {
            
            [heights addObject:@(maxHeight)];
            
        }
        
        [self.interitemHeights addObject:heights];
        
        //配置section的headerView
        if (kHeaderHeight(i) > 0) {
            [self.attributesArray addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]];
        }
        
        NSMutableArray *addHeaderHeights = [_interitemHeights objectAtIndex:i];
        for (int interitemCount = 0; interitemCount < kInteritemCount(i); interitemCount++) {
            
            addHeaderHeights[interitemCount] = @([addHeaderHeights[interitemCount] floatValue] + kEdgeInsets(i).top);
            
        }
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:i];
        
        for (int j = 0 ; j < itemCount; j++) {
            [self.attributesArray addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]];
        }
        
        //配置section的footerView
        if (kFooterHeight(i) > 0) {
            [self.attributesArray addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]];
        } else {
            
            CGFloat bottomInsets = kEdgeInsets(i).bottom;
            NSMutableArray *sectionHeights = [_interitemHeights objectAtIndex:i];
            kMaxHight(sectionHeights, NULL);
            for (int interitemCount = 0; interitemCount < kInteritemCount(i); interitemCount++) {
                
                sectionHeights[interitemCount] = @([sectionHeights[interitemCount] floatValue] + bottomInsets);
            }
        }
    }
}

static int occupyCount = 0;

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (indexPath.row == 0) {
        occupyCount = 0;
    }
    
    //宽度:(屏宽 - 左边距 - 右边距 - 列距)/列数
    CGFloat itemWidth = (kCollectionSize.width - kEdgeInsets(indexPath.section).left - kEdgeInsets(indexPath.section).right - (kInteritemCount(indexPath.section) - 1) * kInteritemSpace(indexPath.section)) / kInteritemCount(indexPath.section);
    
    //高度
    CGFloat itemHeight = kItemHight(indexPath);
    
    int index = 0;
    CGFloat minY = kMinHight([_interitemHeights objectAtIndex:indexPath.section], &index);
    
    //x坐标
    CGFloat itemX = kEdgeInsets(indexPath.section).left + index * (kInteritemSpace(indexPath.section) + itemWidth);
    
    //y坐标
    CGFloat itemY = minY + (indexPath.row >= (kInteritemCount(indexPath.section) - occupyCount) ? kLineSpace(indexPath.section) : 0);
    
    //更新y坐标
    NSMutableArray *heights = [_interitemHeights objectAtIndex:indexPath.section];
    heights[index] = @(itemY + itemHeight);
    
    NSInteger occupy = kBigItemOccupySpace(indexPath);
    if (occupy > 1) {
        itemWidth = itemWidth * occupy + kInteritemSpace(indexPath.section) * (occupy - 1);
        
        occupyCount += ((int)occupy - 1);
        
        for (int i = index + 1; i < index + occupy; i++) {
            if (heights.count > i)
                heights[i] = @(itemY + itemHeight);
        }
    }
    
    attrs.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
    
    return attrs;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    CGFloat maxY = kMaxHight([_interitemHeights objectAtIndex:indexPath.section], NULL);
    
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        //section header
        CGFloat headerHeight = kHeaderHeight(indexPath.section);
        attrs.frame = CGRectMake(0, maxY, kCollectionSize.width, headerHeight);
        
        //更新y坐标
        NSMutableArray *heights = [_interitemHeights objectAtIndex:indexPath.section];
        for (int i = 0; i < heights.count; i++) {
            CGFloat f = [heights[i] floatValue];
            heights[i] = @(f + headerHeight);
        }
        
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        //section footer
        CGFloat footerHeight = kFooterHeight(indexPath.section);
        attrs.frame = CGRectMake(0, maxY + kEdgeInsets(indexPath.section).bottom, kCollectionSize.width, footerHeight);
        
        //更新y坐标
        NSMutableArray *heights = [_interitemHeights objectAtIndex:indexPath.section];
        for (int i = 0; i < heights.count; i++) {
            CGFloat f = [heights[i] floatValue];
            heights[i] = @(f + footerHeight + kEdgeInsets(indexPath.section).bottom);
        }
    }
    
    return attrs;
}

- (CGSize)collectionViewContentSize
{
    CGFloat height = kMaxHight(_interitemHeights.lastObject, NULL);
    CGSize size = CGSizeMake(0, height);
    
    return size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    for (UICollectionViewLayoutAttributes *attributes in _attributesArray) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            NSInteger numberOfItemInSection = [self.collectionView numberOfItemsInSection:attributes.indexPath.section];
            NSInteger indexOfHeader = [_attributesArray indexOfObject:attributes];
            
            UICollectionViewLayoutAttributes *firstCellAttributes, *lastCellAttributes;
            if (numberOfItemInSection > 0) {
                firstCellAttributes = [_attributesArray objectAtIndex:1 + indexOfHeader];
                lastCellAttributes = [_attributesArray objectAtIndex:numberOfItemInSection + indexOfHeader];
            } else {
                firstCellAttributes = [[UICollectionViewLayoutAttributes alloc] init];
                
                CGFloat y = CGRectGetMaxY(attributes.frame) + kEdgeInsets(attributes.indexPath.section).top;
                firstCellAttributes.frame = CGRectMake(0, y, 0, 0);
                lastCellAttributes = firstCellAttributes;
            }
            
            CGRect rect = attributes.frame;
            
            CGFloat offset = self.collectionView.contentOffset.y + 64;
            
            CGFloat headerY = firstCellAttributes.frame.origin.y - rect.size.height - kEdgeInsets(attributes.indexPath.section).top;
            
            
            CGFloat maxY = MAX(offset,headerY);
            
            CGFloat headerMissingY = CGRectGetMaxY(lastCellAttributes.frame) + kEdgeInsets(attributes.indexPath.section).bottom - rect.size.height;
            
            rect.origin.y = MIN(maxY,headerMissingY);
            
            attributes.frame = rect;
            
            attributes.zIndex = 7;
            
        }
    }
    
    return _attributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark // get data from delegate

- (CGFloat)heightOfHeaderView:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:referenceSizeForHeaderInSection:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section].height;
        
    }
    
    return 0;
}

- (CGFloat)heightOfFooterView:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:referenceSizeForFooterInSection:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self referenceSizeForFooterInSection:section].height;
        
    }
    
    return 0;
}

- (NSInteger)interitemCountOfSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:interitemCountAtSection:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self interitemCountAtSection:section];
        
    }
    return KNTACollectionViewDefaultInteritemCount;
}

- (UIEdgeInsets)edgeInsetsOfSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:insetForSectionAtIndex:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return KNTACollectionViewDefaultEdgeInsets;
}

- (CGFloat)lineSpaceOfSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return KNTACollectionViewDefaultLineSpace;
}

- (CGFloat)interitemSpaceOfSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return KNTACollectionViewDefaultInteritemSpace;
}

- (CGFloat)heightOfItem:(NSIndexPath *)indexPath
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:itemHightAtIndexPath:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self itemHightAtIndexPath:indexPath];
    }
    return 0;
}

- (NSInteger)bigItemOccupySpaceAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(kCollectionView:layout:bigItemOccupySpaceAtIndexPath:)]) {
        
        return [self.dataSource kCollectionView:self.collectionView layout:self bigItemOccupySpaceAtIndexPath:indexPath];
    }
    return 0;
}

#pragma mark // util

- (CGFloat)minHeight:(NSMutableArray *)heights index:(int *)index
{
    if (!heights.count) {
        return 0;
    }
    CGFloat minHeight = [heights[0] floatValue];
    if (index) {
        *index = 0;
    }
    
    for (int i = 1; i < heights.count; i++) {
        if (minHeight > [heights[i] floatValue]) {
            minHeight = [heights[i] floatValue];
            
            if (index) {
                *index = i;
            }
        }
    }
    return minHeight;
}

- (CGFloat)maxHeight:(NSMutableArray *)heights index:(int *)index
{
    if (!heights.count) {
        return 0;
    }
    CGFloat maxHeight = [heights[0] floatValue];
    if (index) {
        *index = 0;
    }
    
    for (int i = 1; i < heights.count; i++) {
        if (maxHeight < [heights[i] floatValue]) {
            maxHeight = [heights[i] floatValue];
            
            if (index) {
                *index = i;
            }
            
        }
    }
    return maxHeight;
}


@end
