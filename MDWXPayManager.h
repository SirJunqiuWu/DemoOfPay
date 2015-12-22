//
//  MDWXPayManager.h
//  MovieDate
//
//  Created by 蔡成汉 on 15/11/26.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDWXPayManager : NSObject

/**
 *  单例
 *
 *  @return 实例化之后的MDWXPayManager
 */
+(MDWXPayManager *)shareManager;

/**
 *  初始化支付配置 -- 在appDelegate里使用
 */
-(void)startManager;


/**
 *  支付
 *
 *  @param count    支付金额
 *  @param complete 支付完成
 *  @param callBack 支付回调
 */
-(void)payWithCount:(NSInteger)count complete:(void(^)(BOOL success, NSError *error))complete callBack:(void(^)(NSInteger code, NSString *des))callBack;

/**
 *  支付
 *
 *  @param dic      支付信息
 *  @param complete 支付完成
 *  @param callBack 支付回调
 */
-(void)payWithDic:(NSDictionary *)dic complete:(void(^)(BOOL success, NSError *error))complete callBack:(void(^)(NSInteger code, NSString *des))callBack;


/**
 *  handleOpenURL
 *
 *  @param url url
 *
 *  @return handle结果
 */
-(BOOL)handleOpenURL:(NSURL *)url;

@end
