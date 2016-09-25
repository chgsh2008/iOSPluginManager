//
//  CaptureViewController.m
//  GbssApps-IOS
//
//  Created by Kevin on 15/7/27.
//
//

#import "CaptureViewController.h"
#import "YYKit.h"

@interface CaptureViewController ()
{
    AGSimpleImageEditorView *editorView;
}
@end

@implementation CaptureViewController
//@synthesize delegate;
@synthesize image;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.thumbImageSize = CGSizeZero;
    //添加导航栏和完成按钮
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, iOS7_OR_LATER ? 64 : 44)];
    //    UINavigationBar *naviBar = [[UINavigationBar alloc] init];
    //    [naviBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:naviBar];
    
    UINavigationItem *naviItem = [[UINavigationItem alloc] init];
    [naviBar pushNavigationItem:naviItem animated:YES];
    
    //保存按钮
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton)];
    naviItem.rightBarButtonItem = doneItem;
    
    //返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButton)];
    naviItem.leftBarButtonItem = backItem;
    
    //image为上一个界面传过来的图片资源
    editorView = [[AGSimpleImageEditorView alloc] initWithImage:self.image];
    editorView.frame = CGRectMake(0, 0, self.view.frame.size.width ,  self.view.frame.size.width);
    editorView.center = self.view.center;
    
    //外边框的宽度及颜色
    editorView.borderWidth = 0.1f;
    editorView.borderColor = [UIColor colorWithRed:0.428 green:0.733 blue:0.012 alpha:1.000];
    
    //截取框的宽度及颜色
    editorView.ratioViewBorderWidth = 5.f;
    editorView.ratioViewBorderColor = [UIColor orangeColor];
    
    //截取比例，我这里按正方形1:1截取（可以写成 3./2. 16./9. 4./3.）
    editorView.ratio = 1;
    
    [self.view addSubview:editorView];
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    //    CGRect rect = [[[UIApplication sharedApplication] keyWindow]convertRect:imageView.frame fromView:[imageView superview]];
    //    SycPhotoHandleView *photoView = [[SycPhotoHandleView alloc] initWithImage:self.image transFrom:rect];
    //    [photoView show];
    [self showToolbar];
    
}

-(void)showToolbar
{
    CGSize size = (CGSize){100,50};
    CGRect rect = (CGRect){self.view.frame.size.width - size.width,self.view.frame.size.height - size.height,size};
    //    UIImage *image = [UIImage imageNamed:@"downl.png"];
    UIButton *rationBtn = ({
        UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttom setFrame:rect];
        [buttom addTarget:self action:@selector(rationBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        buttom;
    });
    [rationBtn setTitle:@"旋转90度" forState:UIControlStateNormal];
    [rationBtn setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:rationBtn];
    [self.view bringSubviewToFront:rationBtn];
    
}

- (void)rationBtnEvent:(id)sender{
    static int index = 1;
    [editorView setRotation:index animated:YES];
    
    index +=1;
    if (index > 4) {
        index = 1;
    }
}


//完成截取
-(void)saveButton
{
    //output为截取后的图片，UIImage类型
    UIImage *resultImage = editorView.output;
    UIImage *thumbImage = nil;//[self thumbnailWithImageWithoutScale:resultImage size:CGSizeMake(320, 480)];
    if (!CGSizeEqualToSize(self.thumbImageSize, CGSizeZero)) {
        thumbImage = [self thumbnailWithImageWithoutScale:resultImage size:self.thumbImageSize];
    }else if (resultImage.size.width > 320 && resultImage.size.height > 480) {
        thumbImage = [self thumbnailWithImageWithoutScale:resultImage size:CGSizeMake(320, 480)];
    }
    else{
        thumbImage = resultImage;
    }
    
    if (self.didFinishSelelctImageWithImageBlock != nil) {
        self.didFinishSelelctImageWithImageBlock(resultImage,thumbImage);
    }
    if (self.didFinishSelelctImageWithPathBlock != nil) {
        NSString *orgPath = [self saveImageToCashe:resultImage];
        NSString *thumPath = [self saveImageToCashe:thumbImage];
        self.didFinishSelelctImageWithPathBlock(orgPath, thumPath);
    }
    [self dismissModalViewControllerAnimated:YES];
    self.didFinishSelelctImageWithImageBlock = nil;
    self.didFinishSelelctImageWithPathBlock = nil;
}

-(void)backButton
{
    self.didFinishSelelctImageWithImageBlock = nil;
    self.didFinishSelelctImageWithPathBlock = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)saveImageToCashe:(UIImage *)image
{
    /**
     *  Document目录
     */
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    /**
     *  Cashe目录
     */
    NSString* root=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    root=[root stringByAppendingPathComponent:@"GbssImages"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:root]){
        [[NSFileManager defaultManager] createDirectoryAtPath:root withIntermediateDirectories:YES attributes:Nil error:nil];
    }
    NSData *data;
    NSString *name ;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    name = [dateFormatter stringFromDate:[NSDate date]];
//    name = [Utility md5:name];
    name = [name md5String];
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
        name = [NSString stringWithFormat:@"/%@.jpg",name];
        root = [root stringByAppendingString:name];
        [[NSFileManager defaultManager] createFileAtPath:root contents:data attributes:nil]; //  将图片保存为JPEG格式
    } else {
        data = UIImagePNGRepresentation(image);
        name = [NSString stringWithFormat:@"/%@.png",name];
        root = [root stringByAppendingString:name];
        [[NSFileManager defaultManager] createFileAtPath:root contents:data attributes:nil];   // 将图片保存为PNG格式
    }
    
    return root;
    
    //    UIImageWriteToSavedPhotosAlbum(image, self, @selector(didFinishSavingWithError:contextInfo:), nil);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存失败!请在设置->隐私->照片,将权限设置为允许。" ;
    }else{
        msg = @"保存成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


/**
 *  保持原来的长宽比，生成一个缩略图
 *
 *  @param image 图片
 *  @param asize 大小
 *
 *  @return 图片
 */
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return newimage;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

