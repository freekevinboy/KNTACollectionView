//
//  ViewController.m
//  KNTACollectionViewDemo
//
//  Created by Kevin on 2018/1/18.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "ViewController.h"
#import "KNTACollectionViewLayout.h"
#import "KNTACollectionViewCell.h"


#define kScreenSize [UIScreen mainScreen].bounds.size

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, KNTACollectionViewLayoutDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *dataSource;

@property (assign, nonatomic) CGFloat width;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _width = (kScreenSize.width - 10.0 - 5.0) /2.0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageSource" ofType:@"txt"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.dataSource = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    
    
    KNTACollectionViewLayout *layout = [[KNTACollectionViewLayout alloc] init];
    layout.dataSource = self;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionView registerClass:[KNTACollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

    [self.view addSubview:_collectionView];
    
}

#pragma mark // UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr = _dataSource[section];
    return arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    KNTACollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    
    NSDictionary *dict = _dataSource[indexPath.section][indexPath.row];
    NSString *url = dict[@"source"];
    
    [cell configureCell:url];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataSource.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    NSString *title = @"";
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        identifier = @"header";
        if (indexPath.section == 0) {
            title = @"  这是壁纸";
        } else {
            title = @"  这是美女";
        }
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        identifier = @"footer";
        title = @"  到头了";
    }
    
    UICollectionReusableView *headerFooterView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    if(headerFooterView == nil)
    {
        headerFooterView = [[UICollectionReusableView alloc] init];
    }
    
    UILabel *label = [headerFooterView viewWithTag:1024];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:headerFooterView.bounds];
        label.tag = 1024;
        [headerFooterView addSubview:label];
    }
    
    label.text = title;
    
    return headerFooterView;
}

#pragma mark // UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"click:%@", indexPath);
}


#pragma mark // KNTACollectionViewLayoutDataSource

//headerView
- (CGSize)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenSize.width, 50);
}

//footerView
- (CGSize)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(kScreenSize.width, 50);
}

//interitem count
- (NSInteger)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemCountAtSection:(NSInteger)section
{
    return 2;
}

//item height
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout itemHightAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _dataSource[indexPath.section][indexPath.row];

    CGFloat origanalWidth = [dict[@"w"] floatValue];
    CGFloat origanalHeight = [dict[@"h"] floatValue];
    
    CGFloat height = (_width / origanalWidth) * origanalHeight;

    return height;
}

//edgeInsets of section
- (UIEdgeInsets)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 5, 10, 5);
}

//line sapce
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

//interitem space
- (CGFloat)kCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

@end
