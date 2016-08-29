//
//  WHBKWaitView.m
//  WHBKPicTool
//
//  Created by paykee on 16/7/17.
//  Copyright © 2016年 jpy. All rights reserved.
//

#import "BLWaitView.h"

#define suitableRadius rect.size.width / 2 < rect.size.height / 2 ? rect.size.width / 2 : rect.size.height / 2

@interface BLWaitView()


@end

@implementation BLWaitView

-(void)setDownLoadSchedule:(NSString *)downLoadSchedule{
    _downLoadSchedule = downLoadSchedule;
    [self setNeedsDisplay];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor]set];
    CGContextAddArc(ctr, rect.size.width / 2, rect.size.height / 2, suitableRadius * 0.8, 0, M_PI / 0.5 , 0);
    CGContextSetLineWidth(ctr, suitableRadius * 0.1);
    CGContextStrokePath(ctr);
    
    [[UIColor whiteColor]set];
    double downScale = 0.0;
    if(self.downLoadSchedule != nil && ![self.downLoadSchedule isEqualToString:@""]){
        downScale = [self.downLoadSchedule doubleValue];
    }
    CGContextAddArc(ctr,rect.size.width / 2, rect.size.height / 2, suitableRadius * 0.8, 0,  M_PI / 0.5 * downScale, 0);
    CGContextSetLineWidth(ctr, suitableRadius * 0.1);
    CGContextSetLineCap(ctr, kCGLineCapRound);
    CGContextStrokePath(ctr);
}

@end
