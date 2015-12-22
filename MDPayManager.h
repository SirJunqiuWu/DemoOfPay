//
//  MDPayManager.h
//  MovieDate
//
//  Created by 吴 吴 on 15/11/27.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDAlipayManager.h"
#import "MDWXPayManager.h"

@interface MDPayManager : NSObject <UIActionSheetDelegate>
{
    /**
     *  当前需要支付的订单（一个众筹等同于一个订单）
     */
    MDPayManager *currentPay;
}

/**
 *  订单号
 */
@property (nonatomic,strong)NSString *orderID;

/**
 *  商品名字
 */
@property (nonatomic,strong)NSString *orderName;

/**
 *  商品描述
 */
@property (nonatomic,strong)NSString *orderDescription;

/**
 *  商品价格（也可以是总价）
 */
@property (nonatomic,strong)NSString *orderPrice;



+ (MDPayManager *)sharedManager;

/**
 *  创建当前支付订单的信息对象
 *
 *  @param result 当亲支付订单的基本信息字典
 */
- (void)creatOrderWithResult:(NSDictionary *)result;

/**
 *  弹出支付选择视图
 */
- (void)showPayView;

@end
