//
//  MDWXPayManager.m
//  MovieDate
//
//  Created by 蔡成汉 on 15/11/26.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import "MDWXPayManager.h"
#import "WXApi.h"

static MDWXPayManager *manager = nil;

@interface MDWXPayManager ()<WXApiDelegate>


@property (nonatomic , copy) void(^WXPayCallBack)(NSInteger code, NSString *des);

@end

@implementation MDWXPayManager

/**
 *  单例
 *
 *  @return 实例化之后的MDWXPayManager
 */
+(MDWXPayManager *)shareManager
{
    @synchronized(manager)
    {
        if (manager == nil)
        {
            manager = [[MDWXPayManager alloc]init];
        }
    }
    return manager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

/**
 *  初始化支付配置 -- 在appDelegate里使用
 */
-(void)startManager
{
    [WXApi registerApp:@"wx38897c6066610e95" withDescription:@"电影有约微信支付"];
}


/**
 *  支付
 *
 *  @param count    支付金额
 *  @param complete 支付完成
 *  @param callBack 支付回调
 */
-(void)payWithCount:(NSInteger)count complete:(void(^)(BOOL success, NSError *error))complete callBack:(void(^)(NSInteger code, NSString *des))callBack
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"" forKey:@""];
    [self payWithDic:param complete:^(BOOL success, NSError *error) {
        complete(success,error);
    } callBack:^(NSInteger code, NSString *des) {
        callBack(code,des);
    }];
}

/**
 *  支付
 *
 *  @param dic      支付信息
 *  @param complete 支付完成
 *  @param callBack 支付回调
 */
-(void)payWithDic:(NSDictionary *)dic complete:(void(^)(BOOL success, NSError *error))complete callBack:(void(^)(NSInteger code, NSString *des))callBack
{
    self.WXPayCallBack = callBack;
    /**
     *  向服务器发送请求，获取支付参数
     */
    [[ConnetcManager shareManager]getWithUrl:@"" param:dic andSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *result, NSInteger errorCode) {
        if (errorCode == 1)
        {
            /**
             *  成功从服务器获取到请求参数 -- 发起微信支付
             */
            PayReq *req             = [[PayReq alloc] init];
            req.partnerId           = [result getStringValueForKey:@"partnerid"];
            req.prepayId            = [result getStringValueForKey:@"prepayid"];
            req.nonceStr            = [result getStringValueForKey:@"noncestr"];
            req.timeStamp           = [[result getStringValueForKey:@"timestamp"]intValue];
            req.package             = [result getStringValueForKey:@"package"];
            req.sign                = [result getStringValueForKey:@"sign"];
            [WXApi sendReq:req];
            complete(YES,nil);
        }
        else
        {
            NSError *tpError = [[NSError alloc]initWithDomain:@"请求错误" code:errorCode userInfo:nil];
            complete(NO,tpError);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"%@",error);
        complete(NO,error);
    }];
}


/**
 *  handleOpenURL
 *
 *  @param url url
 *
 *  @return handle结果
 */
-(BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate

-(void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayReq class]])
    {
        if (resp.errCode == WXSuccess)
        {
            /**
             *  支付成功
             */
            if (self.WXPayCallBack)
            {
                self.WXPayCallBack(resp.errCode ,@"支付成功");
            }
        }
        else if (resp.errCode == WXErrCodeUserCancel)
        {
            /**
             *  用户取消
             */
            if (self.WXPayCallBack)
            {
                self.WXPayCallBack(resp.errCode ,@"用户取消");
            }
        }
        else
        {
            /**
             *  支付失败
             */
            if (self.WXPayCallBack)
            {
                self.WXPayCallBack(resp.errCode ,@"支付失败");
            }
        }
    }
}

@end
