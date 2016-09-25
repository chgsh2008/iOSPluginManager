//
//  BusinessPluginProtocol.h
//  BUPM
//
//  Created by Kevin on 16/8/25.
//
//

#import <Foundation/Foundation.h>

@protocol BusinessPluginProtocol <NSObject>

//TODO 对于不同的插件实现相同的接口
/**
 *  显示界面插件，需要由子类实现该方法
 *
 *  @param sender 调用者
 *  @param params 参数
 */
-(void)showViewPlugin:(id)sender andParams:(id)params;



@end
