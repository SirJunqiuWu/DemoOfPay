//
//  MDPayManager.m
//  MovieDate
//
//  Created by 吴 吴 on 15/11/27.
//  Copyright © 2015年 上海佳黛品牌策划有限公司. All rights reserved.
//

#import "MDPayManager.h"
#import "VCManager.h"

static MDPayManager *myManager = nil;
@implementation MDPayManager

+ (MDPayManager *)sharedManager {
    @synchronized(self) {
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

- (void)creatOrderWithResult:(NSDictionary *)result {
    currentPay = [MDPayManager new];
    currentPay.orderID = [result getStringValueForKey:@"orderID"];
    currentPay.orderName = [result getStringValueForKey:@"orderName"];
    currentPay.orderDescription = [result getStringValueForKey:@"orderDes"];
    currentPay.orderPrice = [result getStringValueForKey:@"orderPrice"];
}

- (void)showPayView {
    UIViewController *topVC = [[VCManager shareVCManager]getTopViewController];
    if (IS_IOS_8)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择支付方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alipay = [UIAlertAction actionWithTitle:@"支付宝支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doAlipay];
        }];
        UIAlertAction *weixinPay = [UIAlertAction actionWithTitle:@"微信支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doWeixinPay];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:alipay];
        [alertVC addAction:weixinPay];
        [alertVC addAction:cancel];
        [topVC presentViewController:alertVC animated:YES completion:NULL];
    }
    else
    {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝支付",@"微信支付", nil];
        [sheet showInView:topVC.view];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self doAlipay];
    }else if (buttonIndex == 1) {
        [self doWeixinPay];
    }else{
        NSAssert(@"",nil);
    }
}

- (void)doAlipay {
    [[MDAlipayManager sharedManager]creatTempPayOrderWithTradeNO:currentPay.orderID ProductName:currentPay.orderName ProductDescription:currentPay.orderDescription Amount:currentPay.orderPrice];
    [[MDAlipayManager sharedManager]payOrderWithCallback:^(NSDictionary *resultDic) {
        DLog(@"Alipay: %@",resultDic);
    }];
}

- (void)doWeixinPay {
    NSDictionary *tempOrderDic = @{@"orderID":currentPay.orderID,
                                   @"orderName":currentPay.orderName,
                                   @"orderDes":currentPay.orderDescription,
                                   @"orderPrice":currentPay.orderPrice};
    [[MDWXPayManager shareManager]payWithDic:tempOrderDic complete:^(BOOL success, NSError *error) {
        
    } callBack:^(NSInteger code, NSString *des) {
        
    }];
}


@end
