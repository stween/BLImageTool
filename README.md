# BLImageTool
网络图片工具
 注意：在上传图片的方法中，使用的是原生的上传图片方法。需要对其修改为自己服务器的配置。如果有朋友使用七牛云存储的话，该方法没有用。
 该工具仅与下载有关，第一版本没有做上传，之后版本会慢慢完善。
 
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

eg:
  
  
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
     NSLog(@"%@",picData);
 }]];
 
 
 
 
 
 
 
