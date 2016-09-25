//
//  ImpagePickerPlugin.m
//  BUPM
//
//  Created by Kevin on 16/9/13.
//
//

#import "ImagePickerPlugin.h"
#import "GSImagePickerModel.h"
#import "JSONKit.h"

@interface ImagePickerPlugin(){
    GSImagePickerModel *_imagePicker;
}

@end

@implementation ImagePickerPlugin

-(void)showView:(CDVInvokedUrlCommand *)command
{
    NSString *funCallback =  command.callbackId;
    
    _imagePicker = [[GSImagePickerModel alloc] init];
    [_imagePicker setViewController:self.viewController];
    __weak id mySelf = self;
    _imagePicker.didFinishSelelctImageWithPathBlock  = ^(NSString *orgImagePath, NSString *thumImagePath){
        _imagePicker = nil;
        NSLog(@"org image path: %@,  \nthum image path:%@", orgImagePath, thumImagePath);

        if (funCallback) {
            NSDictionary *dic = @{@"pic" : thumImagePath ? thumImagePath : @"",
                                  @"thumb" : orgImagePath ? orgImagePath : @""};
             [[mySelf commandDelegate] sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[dic JSONString]] callbackId:command.callbackId];
        }
        
    };
    [_imagePicker show];
}


@end
