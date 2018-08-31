//
//  KNTACollectionViewCell.m
//  KNTACollectionViewDemo
//
//  Created by Kevin on 2018/1/22.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "KNTACollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface KNTACollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation KNTACollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
    }
    return self;
}

- (void)configureCell:(NSString *)imgUrl
{
    self.imageView.frame = self.bounds;

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

@end
