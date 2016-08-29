//
//  BLImageTool.h
//  BLToolBox
//
//  Created by paykee on 16/8/16.
//  Copyright © 2016年 jpy. All rights reserved.
//

/**
 使用说明
 #import "BLImage.h"
 NSString *jpgPicStr = @"http://ww3.sinaimg.cn/thumbnail/673c0421jw1e9a6au7h5kj218g0rsn23.jpg";
 NSString *pngPicStr = @"http://uploadpic.55.la/upload/temp/2016/07/12/16/42809637016487.png";
 NSString *gifPicStr = @"http://ww3.sinaimg.cn/mw690/60d02b59jw1evjnbthyipg20go09ehe2.gif";
 
 
 UIView *placeHoldView = [[UIView alloc]init];
 self.placeHoldView = placeHoldView;
 self.placeHoldView.backgroundColor = [UIColor redColor];
 [self.view addSubview:self.placeHoldView];
 
 WHBKImage *whbkImage = [[WHBKImage alloc]init];
 [self.placeHoldView addSubview:[whbkImage showImageWithURL:gifPicStr andPicType:GifImage andShowScale:0.2 andPicSize:^(CGSize picSize) {
        NSLog(@"w = %f, h = %f",picSize.width,picSize.height);
        self.placeHoldView.frame = CGRectMake(20, 20, picSize.width * 0.2 , picSize.height * 0.2);
 } andDownloadPicGrogress:^(NSString *grogressScale) {
        NSLog(@"%@",grogressScale);
 } andFinishedDown:^(NSData *picData) {
 //        NSLog(@"%@",picData);
 }]];
 
 -(void)clearImage{
    [WHBKImage clearCachePicInMemory];
 }
 
 注意：图片的URL中不能带 _下划线
 
 
 */
