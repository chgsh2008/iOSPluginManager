//
//  YcDrawRectView.h
//  GbssApps-IOS
//
//  Created by Suycity on 15/8/14.
//
//

#import <UIKit/UIKit.h>

@interface DrawRectView : UIView

- (void)drawFrame:(CGRect)frame;
- (void)drawSize:(CGSize)size;
- (CGRect)getDrawFrame;
@end
