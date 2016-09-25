//
//  ImagePickerViewController.m
//  GbssApps-IOS
//
//  Created by Kevin on 15/7/27.
//
//

#import "GSImagePickerModel.h"
#import "PhotoHandleView.h"

@interface GSImagePickerModel ()
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation GSImagePickerModel

-(id)init
{
    self = [super init];
    if (self) {
        self.thumbImageSize =CGSizeZero;
    }
    
    return self;
}

- (void)show{
    // Do any additional setup after loading the view.
//    self.thumbImageSize = CGSizeZero;
    self.library = [[ALAssetsLibrary alloc] init];
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择相册", nil];
    [chooseImageSheet showInView:self.viewController.view];
    self.popoverController = nil;
//    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentModalViewController:picker animated:YES];
    
}

#pragma mark UIActionSheetDelegate MethodHFImageEditorFrameView
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self openImagePicker:buttonIndex];
        }];
       //        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
}
- (void)openImagePicker:(int)buttonIndex{

    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        [_picker setDelegate:self];
    }
    UIImagePickerControllerSourceType type;
    switch (buttonIndex) {
        case 0://Take picture
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                type = UIImagePickerControllerSourceTypeCamera;
            }else{
                NSLog(@"模拟器无法打开相机");
                return;
            }
            break;
        case 1://From album
            type = UIImagePickerControllerSourceTypePhotoLibrary;
            
            break;
    }
    [_picker setSourceType:type];
    [_picker setAllowsEditing:NO];
    _picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
    
    if (type == UIImagePickerControllerSourceTypeCamera || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.viewController presentViewController:_picker animated:YES completion:nil];
    }
    else{
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:_picker];
        popover.popoverContentSize = CGSizeMake(300, 300);
        self.popoverController = popover;
        [self.popoverController presentPopoverFromRect:CGRectMake(0, 0, self.viewController.view.bounds.size.width/2+self.viewController.view.bounds.size.width/4, self.viewController.view.bounds.size.height/2) inView:self.viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
//    [self.viewController presentViewController:_picker animated:YES completion:nil];
}

#pragma 拍照选择照片协议方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [picker dismissViewControllerAnimated:NO completion:nil];
    }
    else [self.popoverController dismissPopoverAnimated:NO];;
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        // add Suycity 2015-08-17
        CGRect rect = (CGRect){
            (CGRectGetWidth(self.viewController.view.bounds) - 200)/2,
            (CGRectGetHeight(self.viewController.view.bounds) - 200)/2,
            200,200
        };
        PhotoHandleView *photoHandle = [[PhotoHandleView alloc] initWithImage:image transFrom:rect];
        [photoHandle setDidSelectImage:^(UIImage *thumbnaiImage) {
            
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
            
            NSString *thumbPath = [NSString stringWithFormat:@"thumb%.0f.png",interval];
            NSString *orgImagePath = [NSString stringWithFormat:@"resolution%.0f.png",interval];
            
            thumbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:thumbPath];
            orgImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:orgImagePath];
            
            NSData *thumbnailData = UIImagePNGRepresentation(thumbnaiImage);
//            NSData *orgImageData = UIImagePNGRepresentation(image);
            
            // 计算文件大小
            float lengKB = (float)[thumbnailData length] / 1024;
            if (lengKB > 300) {
                thumbnailData = UIImageJPEGRepresentation(thumbnaiImage, 300.0f/[thumbnailData length]);
            }
//            thumbnailData = [self zoomData:thumbnailData :thumbnaiImage];
            
            NSError *error = nil;
            if (![thumbnailData writeToFile:thumbPath options:0 error:&error]) {
                NSLog(@"write error : %@",error);
            }
            if (self.didFinishSelelctImageWithPathBlock != nil) {
                self.didFinishSelelctImageWithPathBlock(thumbPath,thumbPath);
            }
            [self imagePickerControllerDidCancel:self.picker];
        }];
        [photoHandle setDidCancel:^{
            if (_picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                [self imagePickerControllerDidCancel:self.picker];
            }
        }];
        [photoHandle show];
        
    }else{
        [self imagePickerControllerDidCancel:self.picker];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"不允许选择视频!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}
- (NSData *)zoomData:(NSData *)thumbnailData :(UIImage *)thumbnaiImage{
    
    float lengKB = (float)[thumbnailData length] / 1024;
    if (lengKB > 150.0) {
        CGFloat max = MAX(thumbnaiImage.size.width, thumbnaiImage.size.height);
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = (max==thumbnaiImage.size.width ? size.width : size.height)/max;
        thumbnaiImage = [self image:thumbnaiImage scaleToSize:(CGSize){thumbnaiImage.size.width*scale,thumbnaiImage.size.height*scale}];
        thumbnailData = UIImagePNGRepresentation(thumbnaiImage);
        lengKB = (float)[thumbnailData length] / 1024;
        
        if (lengKB > 150.0) {
            thumbnailData = UIImageJPEGRepresentation(thumbnaiImage, 150.0f/[thumbnailData length]);
        }
    }
    return thumbnailData;
}
- (UIImage *)image:(UIImage *)image scaleToSize:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}
//// 是否支持屏幕旋转
//- (BOOL)shouldAutorotate {
//    return YES;
//}
////
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
////    return UIInterfaceOrientationIsLandscape(interfaceOrientation);;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
////
//- (NSUInteger)supportedInterfaceOrientations
//{
////    return UIInterfaceOrientationMaskLandscape;
//    return UIInterfaceOrientationMaskPortrait;
//    //        return UIInterfaceOrientationMaskLandscapeLeft;
//    //    return UIInterfaceOrientationMaskLandscapeRight;
//}
////
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//    //    return UIInterfaceOrientationLandscapeLeft;
//    //    return UIInterfaceOrientationLandscapeRight;
//    //    return UIInterfaceOrientationPortrait;
//}

-(void)dealloc
{
    self.library = nil;
    self.popoverController = nil;
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
