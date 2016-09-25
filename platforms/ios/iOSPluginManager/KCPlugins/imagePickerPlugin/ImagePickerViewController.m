//
//  ImagePickerViewController.m
//  GbssApps-IOS
//
//  Created by Kevin on 15/7/27.
//
//

#import "ImagePickerViewController.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.thumbImageSize = CGSizeZero;
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
    
    
}


#pragma 拍照选择照片协议方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSData *data;
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //        //图片压缩，因为原图都是很大的，不必要传原图
        //        UIImage *scaleImage = [self scaleImage:originImage toScale:0.3];
        //
        //        //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
        //        if (UIImagePNGRepresentation(scaleImage) == nil) {
        //            //将图片转换为JPG格式的二进制数据
        //            data = UIImageJPEGRepresentation(scaleImage, 1);
        //        } else {
        //            //将图片转换为PNG格式的二进制数据
        //            data = UIImagePNGRepresentation(scaleImage);
        //        }
        //
        //        //将二进制数据生成UIImage
        //        UIImage *image = [UIImage imageWithData:data];
//        UIImage *image = originImage;
        //将图片传递给截取界面进行截取并设置回调方法（协议）
        CaptureViewController *captureView = [[CaptureViewController alloc] init];
        captureView.image = originImage;
        captureView.thumbImageSize = self.thumbImageSize;
        captureView.didFinishSelelctImageWithImageBlock = self.didFinishSelelctImageWithImageBlock;
        captureView.didFinishSelelctImageWithPathBlock = self.didFinishSelelctImageWithPathBlock;
//        captureView.didFinishSelelctImageWithImageBlock = ^(UIImage *orgImage,UIImage *thumImage){
//            NSLog(@"org image : %@, thum image:%@",orgImage,thumImage);
//        };
//        captureView.didFinishSelelctImageWithPathBlock = ^(NSString *orgImagePath, NSString *thumImagePath){
//            NSLog(@"org image path: %@,  \nthum image path:%@", orgImagePath,thumImagePath);
//        };
        //        captureView.more
        //隐藏UIImagePickerController本身的导航栏
        picker.navigationBar.hidden = YES;
        [picker pushViewController:captureView animated:YES];
        
    }
}

-(void)dealloc
{
    self.didFinishSelelctImageWithImageBlock = nil;
    self.didFinishSelelctImageWithPathBlock = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
