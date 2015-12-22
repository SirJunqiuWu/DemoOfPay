//
//  MDAlipayManager.m
//  MovieDate
//
//  Created by 吴 吴 on 15/11/26.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import "MDAlipayManager.h"

static MDAlipayManager *myManager = nil;
@implementation MDAlipayManager

+ (MDAlipayManager *)sharedManager {
    @synchronized(self)
    {
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            myManager = [[self alloc]init];
        });
    }
    return myManager;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)creatTempPayOrderWithTradeNO:(NSString *)tradeNO ProductName:(NSString *)productName ProductDescription:(NSString *)productDescription Amount:(NSString *)amount {
    /**
     * 生成订单信息及签名 将商品信息赋予AlixPayOrder的成员变量
     * 构造阿里支付订单model
     */
    tempOrder = [[Order alloc] init];
    
    tempOrder.partner = PayPartner;
    tempOrder.seller = PaySeller;
    tempOrder.tradeNO = tradeNO;
    tempOrder.productName = productName;
    tempOrder.productDescription = productDescription;
    tempOrder.amount = amount;

    /**
     *  本地服务器用来查询用户支付订单是否支付成功的api
     */
    tempOrder.notifyURL =  @"http://66.175.219.100/xampp/jiayidian/config/alipay/notify_url.php";
    
    /**
     *  以下设置参数均为官网文档给出的数据http://doc.open.alipay.com/doc2/detail?spm=0.0.0.0.sM2O2s&treeId=59&articleId=103660&docType=1
     */
    tempOrder.service = @"mobile.securitypay.pay";
    tempOrder.paymentType = @"1";
    tempOrder.inputCharset = @"utf-8";
    tempOrder.itBPay = @"30m";
    tempOrder.showUrl = @"m.alipay.com";
}

- (void)payOrderWithCallback:(void(^)(NSDictionary * resultDic))callback {
    /**
     *  将当前订单拼接成字符串
     */
    NSString *orderSpec = [tempOrder description];
    
    /**
     *  获取私钥并将当前支付订单信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串进行base64编码和UrlEncode
     */
    id<DataSigner> signer = CreateRSADataSigner(PayPrivate);
    NSString *signedString = [signer signString:orderSpec];
    
    /**
     *  将签名成功的字符串格式化为订单字符串（请严格按照该格式）
     */
    if (signedString != nil)
    {
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:@"zmbb" callback:^(NSDictionary *resultDic) {
            callback(resultDic);
        }];
    }
}


- (void)processOrderWithPaymentResult:(NSURL *)url Callback:(void (^)(BOOL))callback {
    
    /**
     *  同步返回的数据，对于商户在服务端没有收到异步通知的时候，可以依赖服务端对同步返回的结果来进行判断是否支付成功。同步返回的结果中，sign字段描述了请求的原始数据和服务端支付的状态一起拼接的签名信息。验证这个过程包括两个部分：1、原始数据是否跟商户请求支付的原始数据一致（必须验证这个）；2、验证这个签名是否能通过。上述1、2通过后，在sign字段中success=true才是可信的。
     *
     */
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        DLog(@"支付结果 reslut = %@",resultDic);
        
        NSString *resultStatus =[resultDic getStringValueForKey:@"resultStatus"];
        NSString *success = [resultDic getStringValueForKey:@"success"];
        
        if ([resultStatus isEqualToString:@"9000"] && [success isEqualToString:@"true"])
        {
            DLog(@"支付成功");
            if (callback) {
                callback(YES);
            }
        }
        else
        {
            DLog(@"支付失败");
            if (callback) {
                callback(NO);
            }
        }
    }];
}

@end
