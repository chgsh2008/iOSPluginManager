//
//  ImagePickerViewController.h
//  GbssApps-IOS
//
//  Created by Kevin on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "CaptureViewController.h"


@interface GSImagePickerModel : NSObject<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


/**
 *  选择图片完成后返回的Image
 */
@property (nonatomic, copy) DidFinishSelelctImageWithImageBlock didFinishSelelctImageWithImageBlock;

/**
 *  选择图片完成后返回的的Image的路径
 */
@property (nonatomic, copy) DidFinishSelelctImageWithPathBlock didFinishSelelctImageWithPathBlock;


/**
 *  缩略图大小
 */
@property (nonatomic, assign) CGSize thumbImageSize;


@property (nonatomic, retain) UIPopoverController *popoverController;

@property(nonatomic, retain) ALAssetsLibrary *library;


@property (nonatomic, strong) UIViewController *viewController;

- (void)show;
@end
