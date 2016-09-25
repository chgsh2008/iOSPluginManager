////
////  BaseViewController.h
////
//
#import <UIKit/UIKit.h>


@class CustomButton;

#define     SPRING      @"春天"
#define     SUMMER      @"夏天"
#define     AUTUMN      @"秋天"
#define     WINTER      @"冬天"

#define     SPRINGCOLOR  @"#e7f8c2"
#define     SUMMERCOLOR  @"#e6efff"
#define     AUTUMNCOLOR  @"#fff4d4"
#define     WINTERCOLOR  @"#ffe8e8"

#define BaseAlertViewTag 10000

#define kSeasonThemeChangedNotification @"kChangedNotification"

@interface BaseViewController : UIViewController
{
    BOOL isLogout;
}




@end
