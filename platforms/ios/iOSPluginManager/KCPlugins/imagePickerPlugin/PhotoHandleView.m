//
//  PhotoHandleView.m
//  iOSPluginManager
//
//  Created by Kevin on 16/9/23.
//
//

#import "PhotoHandleView.h"
#import "DrawRectView.h"
#import "VIPhotoView.h"

@interface UIImage (Category)
-(UIImage*)scaleToSize:(CGSize)size;
@end

@implementation UIImage (Category)

//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end




@interface PhotoHandleView ()<UIActionSheetDelegate>
{
    BOOL _flag;
    UIViewController *_target;
    BOOL _isShare;
}
@property (nonatomic , strong) DrawRectView *drawRectView;
@property (nonatomic, strong) VIPhotoView *photoView;
@end

@implementation PhotoHandleView{
    CGFloat _line;
}



- (id)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setImage:image];
        [self setFromRect:from];
        [self initView];
    }
    return self;
}
- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from target:(id)target
{
    if ([target isKindOfClass:[UIViewController class]]) {
        _isShare = YES;
        _target = target;
    }
    return [self initWithImage:image transFrom:from];
}
- (void)initView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [tap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tap];
    [self setBackgroundColor:[UIColor blackColor]];
    
    // 选取按钮
    NSString *title = @"选取";
    UIFont *font = [UIFont systemFontOfSize:20];
    CGSize size = [title sizeWithFont:font];
    size.width *= 2;
    size.height *= (3/2);
    CGRect rect = (CGRect){self.frame.size.width - size.width,self.frame.size.height - size.height,size};
    UIButton *saveBtn = ({
        UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttom setFrame:rect];
        [buttom addTarget:self action:@selector(saveBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [buttom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttom.titleLabel setFont:[UIFont systemFontOfSize:20]];
        buttom;
    });
    [saveBtn setTag:100];
    [saveBtn setTitle:title forState:UIControlStateNormal];
    [saveBtn setBackgroundColor:[UIColor clearColor]];
    
    title = @"翻转90°";
    size = [title sizeWithFont:font];
    size.width *= 2;
    size.height *= (3/2);
    rect = (CGRect){0,self.frame.size.height - size.height,size};
    UIButton *transfromBtn = ({
        UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttom setFrame:rect];
        [buttom addTarget:self action:@selector(transfromBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
        [buttom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttom.titleLabel setFont:[UIFont systemFontOfSize:20]];
        buttom;
    });
    [transfromBtn setTitle:title forState:UIControlStateNormal];
    [transfromBtn setTag:101];
    [transfromBtn setBackgroundColor:[UIColor clearColor]];
    
    //    _drawRectView = [[YcDrawRectView alloc] initWithFrame:self.bounds];
    //#ifdef IOS_DEVICE_PAD
    //    _line = 450;
    //#else
    //    _line = 300;
    //#endif
    //    [_drawRectView drawSize:(CGSize){_line,_line}];
    //    [_drawRectView setUserInteractionEnabled:NO];
    //    [self addSubview:_drawRectView];
    
    [self addSubview:transfromBtn];
    [self addSubview:saveBtn];
    [self bringSubviewToFront:saveBtn];
    [self bringSubviewToFront:transfromBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)show
{
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.bounds andImage:self.image];
    photoView.autoresizingMask = (1 << 6) -1;
    self.photoView = photoView;
    
    [self addSubview:photoView];
    [self sendSubviewToBack:photoView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
#pragma mark - Event
- (void)saveBtnEvent:(id)sender{
    if (_isShare) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片",@"分享图片", nil];
        [sheet showInView:[_target view]];
    }
    else{
        UIImage *img = nil;;
        if (_drawRectView) {
            [_drawRectView getDrawFrame];
            CGRect rect = [_drawRectView convertRect:rect toView:self];
            UIGraphicsBeginImageContext (self.bounds.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self.layer renderInContext:context];
            img = UIGraphicsGetImageFromCurrentImageContext();
            img = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, rect)];
            UIGraphicsEndImageContext();
        }else{
            
            img = self.image;//[self.image scaleToSize:[self scaleSize:self.image.size superSize:self.bounds.size]];
        }
        if (self.didSelectImage) {
            self.didSelectImage(img);
        }
        [self removeSelf];
        
    }
}
- (CGSize)scaleSize:(CGSize)size superSize:(CGSize)pSize{
    CGFloat maxW = MAX(size.width, size.height);
    CGFloat widthB = pSize.width;
    CGFloat heightB = pSize.height;
    CGFloat maxBW = size.width > size.height ? widthB : heightB;
    CGFloat scale = MIN(maxBW / maxW, 1);
    CGFloat width = scale * size.width;
    CGFloat height = scale * size.height;
    
    if (height == width && width > widthB) {
        scale = widthB / width;
        return (CGSize){width * scale,height * scale};
    }
    return (CGSize){width,height};
}

- (void)transfromBtnEvent:(id)sender{
    //    _photoView.rotating = YES;
    CGSize size = [self bounds].size;
    CGAffineTransform transform = CGAffineTransformRotate(_photoView.transform, M_PI * 90 / 180);
    CGFloat rotate = [self getRotate:transform];
    if ((int)rotate%180 != 0) {
        size.height = CGRectGetWidth([self bounds]);
        size.width = CGRectGetHeight([self bounds]);
    }
    [_photoView setBounds:(CGRect){
        CGPointZero,
        size
    }];
    _photoView.transform = transform;
}
- (CGFloat)getRotate:(CGAffineTransform)transform{
    CGFloat rotate = acosf(transform.a);
    if (transform.b < 0) {
        rotate += M_PI;
    }
    return rotate / M_PI * 180;
}
- (void)saveImageToPhotos
{
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
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
#pragma mark - share view comtrolelr
- (void)shareViewComtroller{
    NSArray *activityItems = @[self.image];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [_target presentViewController:activity animated:YES completion:nil];
}
#pragma mark -  UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        switch (buttonIndex) {
            case 0:
                [self saveImageToPhotos];
                break;
            case 1:
                [self shareViewComtroller];
                break;
            default:
                break;
        }
    }
}
- (void)tapEvent:(id)sender
{
    if (self.didCancel) {
        self.didCancel();
    }
    [self removeSelf];
}
- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification{
    CGFloat angle = 0.0f;
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortrait:
            angle = 0.0 / 180 * M_PI;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = 180.0 / 180 * M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -90.0 / 180 * M_PI;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = 90.0 / 180 * M_PI;
            break;
        default:
            break;
    }
    
    if (!iOS8_OR_LATER) {
        [UIView animateWithDuration:.36 animations:^{
            self.transform = CGAffineTransformMakeRotation(angle);
        } completion:^(BOOL finished) {
            [self setFrame:[[UIScreen mainScreen] bounds]];
            [_drawRectView setFrame:self.bounds];
            [_drawRectView drawSize:(CGSize){_line,_line}];
            
            UIView *btn = [self viewWithTag:100];
            CGSize size = btn.frame.size;
            CGRect rect = (CGRect){self.bounds.size.width - size.width,self.bounds.size.height - size.height,size};
            [btn setFrame:rect];
            
            btn = [self viewWithTag:101];
            size = btn.frame.size;
            rect = (CGRect){0,self.bounds.size.height - size.height,size};
            [btn setFrame:rect];
        }];
    }
}
- (void)removeSelf{
    [UIView animateWithDuration:.3 animations:^{
        [self setBackgroundColor:[UIColor clearColor]];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.photoView removeFromSuperview];
    }];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
