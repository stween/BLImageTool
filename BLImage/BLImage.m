//
//  BLImage.m
//  BLToolBox
//
//  Created by paykee on 16/8/18.
//  Copyright © 2016年 jpy. All rights reserved.
//

#import "BLImage.h"
#import "BLWaitView.h"
#import "BLImageTool.h"

@interface BLImage()

@property(nonatomic,weak) UIImageView *imageView;

@property(nonatomic,weak) BLWaitView *waitView;

@end

@implementation BLImage
/**
 *  异步下载图片
 *  @param urlStr 图片地址
 *  @param imageType 图片类型（jpg,gif,png仅支持三种图片类型(PngImage,JpgImage,GifImage)）
 *  @param showScale 图片显示的比例
 *  @param picSizeBlock 下载过程中获取图片的size，主要用来对图片进行位置占位。
 *  @param downloadPicGrogress  图片下载过程中的比例
 *  @param finishedDownBlock    图片下载完毕之后返回图片的data
 */
-(UIView *)showImageWithURL:(NSString *)urlStr andPicType:(ImageType)imageType andShowScale:(CGFloat)showScale andPicSize:(void(^)(CGSize picSize))picSizeBlock andDownloadPicGrogress:(void(^)(NSString *grogressScale))downloadPicGrogress andFinishedDown:(void(^)(NSData *picData))finishedDownBlock{
    UIView *blImageView = [[UIView alloc]init];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.imageView = imageView;
    [blImageView addSubview:self.imageView];
    
    //下载过程中获取图片的size
    [BLImageTool getDownLoadPicSizeWithURL:urlStr andPicType:imageType  andFinished:^(CGSize picSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.frame = CGRectMake(0, 0, picSize.width * showScale, picSize.height * showScale);
            picSizeBlock(picSize);
            //在这里添加下载比例图
            BLWaitView *waitView = [[BLWaitView alloc]initWithFrame:CGRectMake(0, 0, picSize.width * showScale, picSize.height * showScale)];
            self.waitView = waitView;
            [self.imageView addSubview:self.waitView];
        });
    }];
    
    BLImageTool *imageTool = [[BLImageTool alloc]init];
    //下载
    [imageTool downLoadCachePicWithURL:urlStr];
    //下载过程
    [imageTool picProgressBlock:^(NSString *grogressScale) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.waitView.downLoadSchedule = grogressScale;
            downloadPicGrogress(grogressScale);
        });
    }];
    //下载完成
    [imageTool picFinishBlock:^(NSData *picData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"orignalDataLenght = %luKB",picData.length/1024);
            finishedDownBlock(picData);
            self.imageView.image = [UIImage imageWithData:picData];
            if(imageType == GifImage){
                self.imageView.image = [BLImageTool animatedGIFWithData:picData];
            }else{
                self.imageView.image = [UIImage imageWithData:picData];
            }
            //压缩
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.waitView removeFromSuperview];
            });
        });
    }];
    return blImageView;
}

/**
 *  压缩图片的大小(压缩之后图片将会变成jpg,因为jpg压缩图片的效率高于png的效率，故才用jpg的图片压缩方式)
 *  @parameter picData       需要压缩的图片
 *  @parameter compressBytes 指定压缩后的图片大小范围以下(在设置范围的时候最好事先找到最小零界值，因为一旦达到最小零界值就不再会被压缩)
 *
 */
+(NSData *)imageCompressPicQualityWith:(UIImage *)picImage andCompressBytesLow:(int)compressBytesLow{
    NSData *compressData = [BLImageTool compressPicQualityWith:picImage andCompressBytesLow:100];
    NSLog(@"compressDataAfterLength = %luKB",compressData.length/1024);
    return compressData;
}


/**
 *  压缩图片的尺寸
 *  @parameter orignalImage  需要压缩的图片
 *  @parameter compressSize  压缩的尺寸
 */
+(UIImage *)imageCompressPicSizeWithOrignalImage:(UIImage *)orignalImage andCompressSize:(CGSize)compressSize{
    NSLog(@"newImageW = %f, newImageH = %f",orignalImage.size.width,orignalImage.size.height);
    UIImage *newSizeImage = [BLImageTool compressPicSizeWithOrignalImage:orignalImage andCompressSize:CGSizeMake(100, 100)];
    NSLog(@"newImageW = %f, newImageH = %f",newSizeImage.size.width,newSizeImage.size.height);
    return newSizeImage;
}



/**
 *  获取原图,在ios7之后,tabBar上的图片会默认被渲染成蓝色
 */
+(UIImage *)imageWithRenderingWithImageName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

/**
 *  获取拉伸的图
 */
+(UIImage *)imageWithStretchableName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
}

/**
 *  清除缓存图片
 */
+(void)clearCachePicInMemory{
    [BLImageTool clearCachePic];
}

@end
