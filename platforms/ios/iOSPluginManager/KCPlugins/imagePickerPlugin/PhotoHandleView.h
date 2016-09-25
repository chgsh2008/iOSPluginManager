//
//  PhotoHandleView.h
//  iOSPluginManager
//
//  Created by Kevin on 16/9/23.
//
//

#import <UIKit/UIKit.h>

@interface PhotoHandleView : UIView

@property (nonatomic , retain) UIImage *image;
@property (nonatomic , assign) CGRect fromRect;

@property (nonatomic, copy) void(^didSelectImage)(UIImage *image);
@property (nonatomic, copy) void(^didCancel)();

- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from;
- (id)initWithImage:(UIImage *)image transFrom:(CGRect)from target:(id)target;

- (void)show;

@end
