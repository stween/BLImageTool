//
//  BLImage.h
//  BLToolBox
//
//  Created by paykee on 16/8/18.
//  Copyright © 2016年 jpy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLImageTool.h"
@interface BLImage : UIView

/**
 *  异步下载图片(返回的是含带图片的View)
 *  @param urlStr 图片地址
 *  @param imageType 图片类型（jpg,gif,png仅支持三种图片类型(PngImage,JpgImage,GifImage)）
 *  @param showScale 图片显示的比例
 *  @param picSizeBlock 下载过程中获取图片的size，主要用来对图片进行位置占位。
 *  @param downloadPicGrogress  图片下载过程中的比例
 *  @param finishedDownBlock    图片下载完毕之后返回图片的data
 */
-(UIView *)showImageWithURL:(NSString *)urlStr andPicType:(ImageType)imageType andShowScale:(CGFloat)showScale andPicSize:(void(^)(CGSize picSize))picSizeBlock andDownloadPicGrogress:(void(^)(NSString *grogressScale))downloadPicGrogress andFinishedDown:(void(^)(NSData *picData))finishedDownBlock;

/**
 *  压缩图片的大小(压缩之后图片将会变成jpg,因为jpg压缩图片的效率高于png的效率，故才用jpg的图片压缩方式)
 *  @parameter picData       需要压缩的图片
 *  @parameter compressBytes 指定压缩后的图片大小范围以下(在设置范围的时候最好事先找到最小零界值，因为一旦达到最小零界值就不再会被压缩)
 *
 */
+(NSData *)imageCompressPicQualityWith:(UIImage *)picImage andCompressBytesLow:(int)compressBytesLow;


/**
 *  压缩图片的尺寸
 *  @parameter orignalImage  需要压缩的图片
 *  @parameter compressSize  压缩的尺寸
 */
+(UIImage *)imageCompressPicSizeWithOrignalImage:(UIImage *)orignalImage andCompressSize:(CGSize)compressSize;

/**
 *  获取原图,在ios7之后,tabBar上的图片会默认被渲染成蓝色
 */
+(UIImage *)imageWithRenderingWithImageName:(NSString *)imageName;

/**
 *  获取拉伸的图
 */
+(UIImage *)imageWithStretchableName:(NSString *)imageName;

/**
 *  清除缓存图片
 */
+(void)clearCachePicInMemory;

@end
