//
//  WHBKImageTool.m
//  WHBKPicTool
//
//  Created by paykee on 16/7/13.
//  Copyright © 2016年 jpy. All rights reserved.
//

#import "BLImageTool.h"
#import <ImageIO/ImageIO.h>
NSString *const pngRangeValue = @"bytes=16-23";
NSString *const jpgRangeValue = @"bytes=0-209";
NSString *const gifRangeValue = @"bytes=6-9";

@interface BLImageTool()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property(nonatomic,strong) NSURLSession *sizeSession;

@property(nonatomic,strong) NSURLSession *downLoadCacheSession;

@property(nonatomic,assign) CGFloat lastScale;

@end


@implementation BLImageTool

-(void)picProgressBlock:(DownloadPicGrogressBlock)downloadPicGrogressBlock{
    self.downloadPicProgressBlock = downloadPicGrogressBlock;
}

-(void)picFinishBlock:(DownloadPicFinishBlock)downloadPicFinishBlock{
    self.downloadPicFinishBlock = downloadPicFinishBlock;
}

-(NSURLSession *)sizeSession{
    //创建NSURLSession
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sizeSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return sizeSession;
}

-(NSURLSession *)downLoadCacheSession{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *downLoadCacheSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return downLoadCacheSession;
}

//获取下载图片的尺寸
+(void)getDownLoadPicSizeWithURL:(NSString *)urlStr andPicType:(ImageType)picType andFinished:(void(^)(CGSize picSize))picSizeBlock{
    if(picType == JpgImage){
        [[self alloc] getPicSizeWithWithPicRangeValue:jpgRangeValue andURL:urlStr andPicType:JpgImage andPicSize:^(CGSize picSize) {
            picSizeBlock(picSize);
        }];
    }else if(picType == PngImage){
        [[self alloc] getPicSizeWithWithPicRangeValue:pngRangeValue andURL:urlStr andPicType:PngImage andPicSize:^(CGSize picSize) {
            picSizeBlock(picSize);
        }];
    }else if(picType == GifImage){
        [[self alloc] getPicSizeWithWithPicRangeValue:gifRangeValue andURL:urlStr andPicType:GifImage andPicSize:^(CGSize picSize) {
            picSizeBlock(picSize);
        }];
    }
}

-(void)getPicSizeWithWithPicRangeValue:(NSString *const)picRangeValue andURL:(NSString *)urlStr andPicType:(ImageType)picType andPicSize:(void(^)(CGSize picSize))picSize{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:1.0];
    //放宽最大接受范围
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:picRangeValue forHTTPHeaderField:@"Range"];
    NSURLSessionDownloadTask *sessionDownLoadTask = [self.sizeSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",location);
        NSData *data = [NSData dataWithContentsOfURL:location];
        if(picType == JpgImage){
            picSize(jpgImageSizeWithHeaderData(data));
        }else if( picType == PngImage){
            picSize(pngImageSizeWithHeaderData(data));
        }else{
            picSize(gifImageSizeWithHeaderData(data));
        }
    }];
    [sessionDownLoadTask resume];
}


CGSize pngImageSizeWithHeaderData(NSData *data){
    int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
    [data getBytes:&w1 range:NSMakeRange(0, 1)];
    [data getBytes:&w2 range:NSMakeRange(1, 1)];
    [data getBytes:&w3 range:NSMakeRange(2, 1)];
    [data getBytes:&w4 range:NSMakeRange(3, 1)];
    int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
    
    int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
    [data getBytes:&h1 range:NSMakeRange(4, 1)];
    [data getBytes:&h2 range:NSMakeRange(5, 1)];
    [data getBytes:&h3 range:NSMakeRange(6, 1)];
    [data getBytes:&h4 range:NSMakeRange(7, 1)];
    int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
    
    return CGSizeMake(w, h);
}

static CGSize jpgImageSizeWithExactData(NSData *data){
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(2, 1)];
    [data getBytes:&w2 range:NSMakeRange(3, 1)];
    short w = (w1 << 8) + w2;
    
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(0, 1)];
    [data getBytes:&h2 range:NSMakeRange(1, 1)];
    short h = (h1 << 8) + h2;
    
    return CGSizeMake(w, h);
}

CGSize jpgImageSizeWithHeaderData(NSData *data){
#ifdef DEBUG
    // @"bytes=0-209"
    assert([data length] == 210);
#endif
    short word = 0x0;
    [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
    if (word == 0xdb) {
        [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
        if (word == 0xdb) {
            NSData *exactData = [data subdataWithRange:NSMakeRange(0xa3, 0x4)];
            return jpgImageSizeWithExactData(exactData);
        } else {
            NSData *exactData = [data subdataWithRange:NSMakeRange(0x5e, 0x4)];
            return jpgImageSizeWithExactData(exactData);
        }
    } else {
        return CGSizeZero;
    }
}

CGSize gifImageSizeWithHeaderData(NSData *data){
    short w1 = 0, w2 = 0;
    [data getBytes:&w1 range:NSMakeRange(1, 1)];
    [data getBytes:&w2 range:NSMakeRange(0, 1)];
    short w = (w1 << 8) + w2;
    
    short h1 = 0, h2 = 0;
    [data getBytes:&h1 range:NSMakeRange(3, 1)];
    [data getBytes:&h2 range:NSMakeRange(2, 1)];
    short h = (h1 << 8) + h2;
    
    return CGSizeMake(w, h);
}

/**
 *  异步下载图片带缓存（带百分比）
 *  在使用该方法的时候记得配合downloadPicProgressBlock和downloadPicFinishBlock使用
 */
-(void)downLoadCachePicWithURL:(NSString *)urlStr{
    self.lastScale = 0.00;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    NSURLSessionDownloadTask *sessionDownLoadTask = [self.downLoadCacheSession downloadTaskWithRequest:request];
    [sessionDownLoadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:[downloadTask.currentRequest.URL.absoluteString lastPathComponent]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:savePath]){//存在该图片
        NSData *data = [NSData dataWithContentsOfFile:savePath];
        self.downloadPicFinishBlock(data);
        [downloadTask cancel];
    }else{//不存在该图片，需要下载
        CGFloat scale = (totalBytesWritten * 1.0) / totalBytesExpectedToWrite;
        if(scale - self.lastScale >= 0.01){
            self.lastScale = scale;
            self.downloadPicProgressBlock([NSString stringWithFormat:@"%.2f",scale]);
        }
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSError *error;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *savePath = [cachePath stringByAppendingPathComponent:[downloadTask.currentRequest.URL.absoluteString lastPathComponent]];
    NSURL *saveUrl = [NSURL fileURLWithPath:savePath];
    // 通过文件管理 复制文件
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveUrl error:&error];
    if (error) {
        NSLog(@"Error is %@", error.localizedDescription);
    }else{
        NSData *data = [NSData dataWithContentsOfFile:savePath];
        self.downloadPicFinishBlock(data);
    }
}


/**
 *  压缩图片的大小(压缩之后图片将会变成jpg,因为jpg压缩图片的效率高于png的效率，故才用jpg的图片压缩方式)
 *  @parameter picData       需要压缩的图片
 *  @parameter compressBytes 指定压缩后的图片大小范围以下(在设置范围的时候最好事先找到最小零界值，因为一旦达到最小零界值就不再会被压缩)
 *
 */
+(NSData *)compressPicQualityWith:(UIImage *)picImage andCompressBytesLow:(int)compressBytesLow{
    NSData *data = UIImageJPEGRepresentation(picImage,1.0);
    NSUInteger size = data.length / 1024;
    while(size > compressBytesLow){
        UIImage *image = [UIImage imageWithData:data];
        data = UIImageJPEGRepresentation(image, 0.9);;
        size = data.length/1024;
    }
    return data;
}

/**
 *  压缩图片的尺寸
 *  @parameter orignalImage  需要压缩的图片
 *  @parameter compressSize  压缩的尺寸
 */
+(UIImage *)compressPicSizeWithOrignalImage:(UIImage *)orignalImage andCompressSize:(CGSize)compressSize{
    UIGraphicsBeginImageContext(compressSize);
    [orignalImage drawInRect:CGRectMake(0, 0, compressSize.width, compressSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  清除缓存图片
 */
+(void)clearCachePic{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //遍历文件
    NSArray *fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    for (NSString *fileName in fileArr) {
        if([fileName containsString:@".png"] || [fileName containsString:@".jpg"] || [fileName containsString:@".gif"]){
            [[NSFileManager defaultManager] removeItemAtPath:[cachePath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}


#pragma mark start------------------该部分借鉴SDWebImage
/**
 * 由于没有找到合适的解决方法，借鉴SDWebImage的实现方法
 */
+ (UIImage *)animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self durationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)durationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

#pragma mark end------------------该部分借鉴SDWebImage


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

@end
