//
//  WHBKImageTool.h
//  WHBKPicTool
//
//  Created by paykee on 16/7/13.
//  Copyright © 2016年 jpy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,ImageType){
    PngImage = 1,
    JpgImage,
    GifImage,
};

typedef void(^DownloadPicGrogressBlock)(NSString *grogressScale);
typedef void(^DownloadPicFinishBlock)(NSData *picData);

@interface BLImageTool : NSObject

/*
 获取下载图片的尺寸
 注意：链接不能带_,不然会自动把图片下载完毕
 */
+(void)getDownLoadPicSizeWithURL:(NSString *)urlStr andPicType:(ImageType)picType andFinished:(void(^)(CGSize picSize))picSizeBlock;

/**
 *  异步下载图片带缓存（带百分比）
 *  在使用该方法的时候记得配合downloadPicProgressBlock和downloadPicFinishBlock使用
 */
-(void)downLoadCachePicWithURL:(NSString *)urlStr ;

/**
 *  压缩图片的大小(压缩之后图片将会变成jpg,因为jpg压缩图片的效率高于png的效率，故才用jpg的图片压缩方式)
 *  @parameter picData       需要压缩的图片
 *  @parameter compressBytes 指定压缩后的图片大小范围以下(在设置范围的时候最好事先找到最小零界值，因为一旦达到最小零界值就不再会被压缩)
 *
 */
+(NSData *)compressPicQualityWith:(UIImage *)picImage andCompressBytesLow:(int)compressBytesLow;

/**
 *  压缩图片的尺寸
 *  @parameter orignalImage  需要压缩的图片
 *  @parameter compressSize  压缩的尺寸
 */
+(UIImage *)compressPicSizeWithOrignalImage:(UIImage *)orignalImage andCompressSize:(CGSize)compressSize;

/**
 *  清除缓存图片
 */
+(void)clearCachePic;


/**
 *  显示gif图
 *
 */
+ (UIImage *)animatedGIFWithData:(NSData *)data;



/**
 *  获取原图,在ios7之后,tabBar上的图片会默认被渲染成蓝色
 */
+(UIImage *)imageWithRenderingWithImageName:(NSString *)imageName;

/**
 *  获取拉伸的图
 */
+(UIImage *)imageWithStretchableName:(NSString *)imageName;

#pragma mark----------------------------以下的东西不要碰
//过程的block
@property(nonatomic,copy) DownloadPicGrogressBlock downloadPicProgressBlock;
-(void)picProgressBlock:(DownloadPicGrogressBlock)downloadPicGrogressBlock;

//完成的block
@property(nonatomic,copy) DownloadPicFinishBlock downloadPicFinishBlock;
-(void)picFinishBlock:(DownloadPicFinishBlock)downloadPicFinishBlock;

@end
