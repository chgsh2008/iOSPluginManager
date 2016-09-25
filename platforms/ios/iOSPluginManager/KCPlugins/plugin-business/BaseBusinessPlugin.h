//
//  BaseBusinessPlugin.h
//  BUPM
//
//  Created by Kevin on 16/8/25.
//
//

//#import "CDV.h"
#import <Cordova/CDV.h>

#import "BusinessPluginProtocol.h"
//原生调用插件 callBackId 标识
#define kNativePluginCallBackId @"kc-app"



#pragma mark 插件类名常量

/**
 *  登录插件类名
 */
extern const NSString *LoginPluginName;
/**
 *  获取密码插件类名
 */
extern const NSString *GetPasswordPluginName;
/**
 *  修改密码插件类名
 */
extern const NSString *ModifyPasswordPluginName;
/**
 *  协议插件插件类名
 */
extern const NSString *ProtocolPluginName;




#pragma mark 插件之间通知常量
/**
 *  登录成功通知
 */
extern const NSString *Notification_LoginSucessed;
/**
 *  注销成功通知
 */
extern const NSString *Notification_LogoutSucessed;



#pragma mark BaseBusinessPlugin

@interface BaseBusinessPlugin : CDVPlugin{

}


/**
 *  成功回调
 */
@property(nonatomic,copy) void (^ successBlock)(NSDictionary * result);
/**
 *  失败回调
 */
@property(nonatomic,copy) void (^ failBlock)(NSDictionary * error);


-(instancetype)initWithViewController:(UIViewController *)viewController;


/**
 *  显示插件界面，需要在子类实现该方法
 *
 *  @param command
 */
-(void)showView:(CDVInvokedUrlCommand *)command;


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
+(BaseBusinessPlugin *) execByViewController:(UIViewController *) viewController className:(NSString *)className method:(NSString *)method params:(NSArray *)params success:(void (^) (NSDictionary* result)) success fail:(void (^) (NSDictionary* error)) fail;

/**
 *  调用插件方法
 *
 *  @param method  调用的方法
 *  @param params  传递的参数
 *  @param success 成功回调
 *  @param fail    失败回调
 */
-(void)execBymethod:(NSString *)method params:(NSArray *)params success:(void (^) (NSDictionary* result)) success fail:(void (^) (NSDictionary* error)) fail ;

/**
 *  发送回调方法
 *
 *  @param result     回调内容
 *  @param callbackId 回调ID
 */
- (void)sendPluginResult:(CDVPluginResult*)result callbackId:(NSString*)callbackId;

/**
 * 生成简单的接口回调内容
 *
 *  @param status 插件状态
 *  @param code   执行状态
 *  @param msg    说明文字
 *
 *  @return CDVPluginResult
 */
+(CDVPluginResult *) simplePluginResultStatus:(int )status code:(int) code msg:(NSString *)msg;


@end
