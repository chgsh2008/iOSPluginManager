//
//  CaptureViewController.h
//  GbssApps-IOS
//
//  Created by Kevin on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "AGSimpleImageEditorView.h"
//#import "PassImageDelegate.h"
//#import "Utility.h"

//@protocol PassImageDelegate <NSObject>
//
//-(void)passImage:(UIImage *)image;
//
//@end

typedef void (^DidFinishSelelctImageWithImageBlock)(UIImage *oriImage, UIImage *thumbImage);
typedef void (^DidFinishSelelctImageWithPathBlock)(NSString *oriImagePath, NSString *thumbImagePath);

@interface CaptureViewController : UIViewController


@property(nonatomic,strong) UIImage *image;

//@property(strong,nonatomic) NSObject<PassImageDelegate> *delegate;

/**
 *  选择图片完成后返回的Image
 */
@property (nonatomic, copy) DidFinishSelelctImageWithImageBlock didFinishSelelctImageWithImageBlock;

/**
 *  选择图片完成后返回的的Image的路径
 */
@property (nonatomic, copy) DidFinishSelelctImageWithPathBlock didFinishSelelctImageWithPathBlock;

/**
 *  保持原来的长宽比，生成一个缩略图
 *
 *  @param image 图片
 *  @param asize 大小
 *
 *  @return 图片
 */
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;


/**
 *  缩略图大小
 */
@property (nonatomic, assign) CGSize thumbImageSize;

@end

