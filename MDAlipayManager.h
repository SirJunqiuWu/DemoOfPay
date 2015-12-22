//
//  MDAlipayManager.h
//  MovieDate
//
//  Created by 吴 吴 on 15/11/26.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "Order.h"

@interface MDAlipayManager : NSObject
{
    Order *tempOrder;
}

+ (MDAlipayManager *)sharedManager;

/**
 *  生成订单信息及签名 将商品信息赋予AlixPayOrder的成员变量,构造阿里支付订单model
 *
 *  @param tradeNO            订单号
 *  @param productName        商品名称
 *  @param productDescription 商品描述
 *  @param amount             商品价格
 */
- (void)creatTempPayOrderWithTradeNO:(NSString *)tradeNO
                            ProductName:(NSString *)productName
                     ProductDescription:(NSString *)productDescription
                                 Amount:(NSString *)amount;


/**
 * 支付订单
 *
 *  @param order    当前商户准备请求支付的订单
 *  @param callback 支付结果回调（用户此时kill程序也没关系）
 */
- (void)payOrderWithCallback:(void(^)(NSDictionary * resultDic))callback;




/**
 *  确认订单是否支付成功（在支付过程结束后，会通过callbackBlock同步返回支付结果。）
 *
 *  @param url      确认订单是否支付成功的本地服务器api
 *  @param callback YES，支付成功;反正失败
 */
- (void)processOrderWithPaymentResult:(NSURL *)url Callback:(void(^)(BOOL success))callback;


@end
