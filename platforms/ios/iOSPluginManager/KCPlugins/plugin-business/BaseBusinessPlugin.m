//
//  BaseBusinessPlugin.m
//  BUPM
//
//  Created by Kevin on 16/8/25.
//
//

#import "BaseBusinessPlugin.h"
#import "JSONKit.h"
#import <UIKit/UIKit.h>

#pragma mark 插件类名常量
const NSString *LoginPluginName = @"LoginPlugin";
const NSString *GetPasswordPluginName = @"GetPasswordPlugin";
const NSString *ModifyPasswordPluginName =@"ModifyPasswordPlugin";
const NSString *ProtocolPluginName = @"ProtocolPlugin";



#pragma mark 插件之间通知常量
/**
 *  登录成功通知
 */
const NSString *Notification_LoginSucessed = @"Notification_LoginSucessed";
/**
 *  注销成功通知
 */
const NSString *Notification_LogoutSucessed = @"Notification_LogoutSucessed";



@implementation BaseBusinessPlugin

-(instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    
    return self;
}


/**
 *  显示插件界面，需要在子类实现该方法
 *
 *  @param command
 */
-(void)showView:(CDVInvokedUrlCommand *)command{
    //TODO: 显示插件界面，需要在子类实现该方法
}

/**
 *  调用插件
 *
 *  @param viewController 控制器
 *  @param className      调用的插件名称
 *  @param method         调用的方法
 *  @param params         传递的参数
 *  @param success        成功回调
 *  @param fail           失败回调
 */
+(BaseBusinessPlugin *) execByViewController:(UIViewController *) viewController className:(NSString *)className method:(NSString *)method params:(NSArray *)params success:(void (^) (NSDictionary* result)) success fail:(void (^) (NSDictionary* error)) fail{
    
    Class class = NSClassFromString(className);
    if([class isSubclassOfClass:[BaseBusinessPlugin class]]){
        BaseBusinessPlugin *plugin = [[class alloc] initWithViewController:viewController] ;
        plugin.successBlock = success;
        plugin.failBlock = fail;
        SEL start = NSSelectorFromString(method);
        if([plugin respondsToSelector:start]){
            CDVInvokedUrlCommand * command = [[CDVInvokedUrlCommand alloc] initWithArguments:params callbackId:kNativePluginCallBackId className:className methodName:method];
            [plugin performSelectorOnMainThread:start withObject:command waitUntilDone:YES];
            return plugin;
        }else{//没有该方法
            fail([self getResultDicByStatus:CDVCommandStatus_ILLEGAL_ACCESS_EXCEPTION msg:[NSString stringWithFormat:@"%@插件,没有%@方法",className,method]]);
        }
        
        
    }else{
        fail([self getResultDicByStatus:CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION msg:[NSString stringWithFormat:@"找不到%@插件",className]]);
    }
    return nil;

}

/**
 *  调用插件方法
 *
 *  @param method  调用的方法
 *  @param params  传递的参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
-(void)execBymethod:(NSString *)method params:(NSArray *)params success:(void (^) (NSDictionary* result)) success fail:(void (^) (NSDictionary* error)) fail{
    
    SEL start = NSSelectorFromString(method);
    if([self respondsToSelector:start]){
        CDVInvokedUrlCommand * command = [[CDVInvokedUrlCommand alloc] initWithArguments:params callbackId:@"infinitus-app" className:NSStringFromClass([self class]) methodName:method];
        [self performSelectorOnMainThread:start withObject:command waitUntilDone:YES];
        
    }else{//没有该方法
        fail([BaseBusinessPlugin getResultDicByStatus:CDVCommandStatus_ILLEGAL_ACCESS_EXCEPTION msg:[NSString stringWithFormat:@"%@插件,没有%@方法",NSStringFromClass([self class]),method]]);
    }

}

/**
 *  发送回调方法
 *
 *  @param result     回调内容
 *  @param callbackId 回调ID
 */
- (void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId{
    if([callbackId isEqualToString:@"kc-app"]){//原生回调
        if([result.status integerValue] == CDVCommandStatus_OK){//成功
            
            self.successBlock([[result argumentsAsJSON] objectFromJSONString]);
        }else{//失败
            self.failBlock(@{});
        }
        
        
    }else{//html5 回调
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}


+ (NSDictionary *) getResultDicByStatus:(int) status msg:(NSString *)msg{
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:status],@"code",msg,@"msg", nil];
    return dic;
}

/**
 * 生成简单的接口回调内容
 *
 *  @param status 插件状态
 *  @param code   执行状态
 *  @param msg    说明文字
 *
 *  @return CDVPluginResult
 */
+(CDVPluginResult *) simplePluginResultStatus:(int )status code:(int) code msg:(NSString *)msg{
    return [CDVPluginResult resultWithStatus:status messageAsDictionary:@{@"code":[NSNumber numberWithInt:code],@"msg":msg}];

}




-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _successBlock = nil;
    _failBlock = nil;
}


@end
