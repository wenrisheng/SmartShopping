//
//  WSPromotionCouponInStoreCollectionViewCell.m
//  SmartShopping
//
//  Created by wrs on 15/4/23.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSPromotionCouponOutStoreCollectionViewCell.h"
#import "WSLocationDetailViewController.h"
#import "WSStoreDetailViewController.h"
#import "WSProductDetailViewController.h"
#import "WSInStoreNoSignScopeViewController.h"
#import "CollectSucView.h"
#import "WSNoInStoreViewController.h"
#import "WSInStoreNoSignViewController.h"

@implementation WSPromotionCouponOutStoreCollectionViewCell
@synthesize dic;

- (void)setModel:(NSMutableDictionary *)modelDic
{
    self.dic = modelDic;

    NSString *shopLogo= [dic objectForKey:@"shopLogo"];
    [_loginImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:shopLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    NSString *isSign  = [dic stringForKey:@"isSign"];
    NSString *userIsSign = [dic stringForKey:@"userIsSign"];
    NSString *signImage = nil;
    if ([isSign isEqualToString:@"1"] && [userIsSign isEqualToString:@"N"]) {
        signImage = @"gainpeas_icon-06";
    } else {
        signImage = @"gainpeas_icon-04";
    }
    [_signupBut setBackgroundImage:[UIImage imageNamed:signImage] forState:UIControlStateNormal];
    
    _storeNameLabel.text = [dic objectForKey:@"shopName"];
    _addressLabel.text = [dic objectForKey:@"address"];
    NSString *distance = [dic stringForKey:@"distance"];

    _distanceLabel.text = [WSProjUtil converDistanceWithDistanceStr:distance];
    _couponNumLabel.text = [NSString stringWithFormat:@"共有%@促销", [dic objectForKey:@"saleCount"]];
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSString *FgoodsScan = nil;
    NSString *FisCollect = nil;
    NSString *FgoodsEndDate = nil;
    NSString *FgoodsLogo = nil;
    NSString *FgoodsName = @"";
    
    NSString *SgoodsScan = nil;
    NSString *SisCollect = nil;
    NSString *SgoodsEndDate = nil;
    NSString *SgoodsLogo = nil;
    NSString *SgoodsName = @"";
    if (goodsList.count > 0) {
        NSDictionary *FDic = [goodsList objectAtIndex:0];
        FgoodsEndDate = [FDic objectForKey:@"goodsEndDate"];
        FgoodsLogo = [FDic objectForKey:@"goodsLogo"];
        FgoodsName = [FDic objectForKey:@"goodsName"];
        FgoodsScan = [FDic stringForKey:@"goodsScan"];
        FisCollect = [FDic objectForKey:@"isCollect"];
        _leftProductView.hidden = NO;
    } else {
        _leftProductView.hidden = YES;
    }
   
    if (goodsList.count > 1) {
        NSDictionary *SDic = [goodsList objectAtIndex:1];
        SgoodsEndDate = [SDic objectForKey:@"goodsEndDate"];
        SgoodsLogo = [SDic objectForKey:@"goodsLogo"];
        SgoodsName = [SDic objectForKey:@"goodsName"];
        SgoodsScan = [SDic stringForKey:@"goodsScan"];
        SisCollect = [SDic objectForKey:@"isCollect"];
        _rightProductView.hidden = NO;
    } else {
        _rightProductView.hidden = YES;
    }

    if ([FgoodsScan isEqualToString:@"1"]) {
        _leftScanImageView.hidden = NO;
    } else {
        _leftScanImageView.hidden = YES;
    }
    _leftValidDateLabel.text = [self getValidateWithDateStr:FgoodsEndDate];
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:FgoodsLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (_downloadImageFinish) {
            _downloadImageFinish();
        }
    }];
    // 没有收藏
    if ([FisCollect isEqualToString:@"N"]) {
        [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
       
    } else {
        [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
       
    }
    
    if ([SgoodsScan isEqualToString:@"1"]) {
        _rightScanImageView.hidden = NO;
    } else {
        _rightScanImageView.hidden = YES;
    }
    _rightValidDateLabel.text = [self getValidateWithDateStr:SgoodsEndDate];
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:[WSInterfaceUtility getImageURLWithStr:SgoodsLogo]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"radom_%d", [WSProjUtil gerRandomColor]]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (_downloadImageFinish) {
            _downloadImageFinish();
        }
    }];
    // 没有收藏
    if ([SisCollect isEqualToString:@"N"]) {
        [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
    } else {
        [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
    }
}

- (NSString *)getValidateWithDateStr:(NSString *)dateStr
{
    if (!dateStr) {
        return @"有效日期未知";
    }
    NSArray *array = [dateStr componentsSeparatedByString:@"-"];
    if (array.count < 3) {
        return  @"有效日期未知";
    }
    NSString *month = [array objectAtIndex:1];
    int monthInt = [month intValue];
    NSString *day = [array objectAtIndex:2];
    int dayInt = [day intValue];
    NSString *result = [NSString stringWithFormat:@"%d月%d日前有效", monthInt, dayInt];
    return result;
}

- (void)awakeFromNib {
    // Initialization code
    self.dealInCell = YES;
    NSArray *array = @[_leftProductView, _rightProductView];
    for (UIView *view in array) {
        [view setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithRed:0.867 green:0.875 blue:0.878 alpha:1.000] cornerRadius:5];
    }
}

- (IBAction)distanceButAction:(id)sender
{
    NSString *lat = [dic stringForKey:@"lat"];
    NSString *lon = [dic stringForKey:@"lon"];
    NSString *shopName = [dic stringForKey:@"shopName"];
    NSString *address = [dic objectForKeyedSubscript:@"address"];
    WSLocationDetailViewController *locationDetailVC = [[WSLocationDetailViewController alloc] init];
    locationDetailVC.latitude = [lat doubleValue];
    locationDetailVC.longitude = [lon doubleValue];
    locationDetailVC.locTitle = shopName;
    locationDetailVC.address = address;
    [self.viewController.navigationController pushViewController:locationDetailVC animated:YES];
}

- (IBAction)signupButAction:(id)sender
{
    // 跳到3.3.1 不在签到范围内
//    WSInStoreNoSignScopeViewController *inStoreNoSignScopeVC = [[WSInStoreNoSignScopeViewController alloc ] init];
//    [self.viewController.navigationController pushViewController:inStoreNoSignScopeVC animated:YES];
    NSString *isSign  = [dic stringForKey:@"isSign"];
    NSString *userIsSign = [dic stringForKey:@"userIsSign"];
    if ([isSign isEqualToString:@"1"] && [userIsSign isEqualToString:@"N"]) {
        CLBeacon *beacon = [WSRunTime sharedWSRunTime].validBeacon;
        
        [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
            BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
            // 在店内
            if (isInStore) {
                NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
                NSString *isSign = [shop stringForKey:@"isSign"];
                //  没签到
                if ([isSign isEqualToString:@"Y"]) {
                    WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
                    inStoreNoSignVC.shop = shop;
                    [self.viewController.navigationController pushViewController:inStoreNoSignVC animated:YES];
                } else {
                    WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                    storeDetailVC.shop = dic;
                    [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
                }
                // 不在店内
            } else {
                WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                storeDetailVC.shop = dic;
                [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
            }
        }];

    } else {
        WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
        storeDetailVC.shop = dic;
        [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
    }
    
//    // 可以签到
//    NSString *isSign = [dic stringForKey:@"isSign"];
//    if ([isSign isEqualToString:@"1"]) {
//        [WSUserUtil actionAfterLogin:^{
//           
//                CLBeacon *beacon = [WSRunTime sharedWSRunTime].validBeacon;
//                [WSProjUtil isInStoreWithIBeacon:beacon callback:^(id result) {
//                    BOOL  isInStore = [[result objectForKey:IS_IN_SHOP_FLAG] boolValue];
//                    // 在店内
//                    if (isInStore) {
//                        NSString *userIsSign = [dic stringForKey:@"userIsSign"];
//                        // 用户已经签到
//                        if ([userIsSign isEqualToString:@"Y"]) {
//                            WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
//                            storeDetailVC.shop = dic;
//                            [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
//                        } else {
//                            NSDictionary *shop = [result objectForKey:IS_IN_SHOP_DATA];
//                            WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
//                            inStoreNoSignVC.shop = shop;
//                            [self.viewController.navigationController pushViewController:inStoreNoSignVC animated:YES];
//                        }
//                        // 不在店内
//                    } else {
//                        //不在签到范围内
//                        WSInStoreNoSignScopeViewController *noSignScopeVC = [[WSInStoreNoSignScopeViewController alloc] init];
//                        [self.viewController.navigationController pushViewController:noSignScopeVC animated:YES];
//                    }
//                }];
//
//            }];
//        
//    // 不可以签到
//    } else {
//        //不在签到范围内
//        WSInStoreNoSignScopeViewController *noSignScopeVC = [[WSInStoreNoSignScopeViewController alloc] init];
//        [self.viewController.navigationController pushViewController:noSignScopeVC animated:YES];
//    }
}

- (IBAction)lookMoreButAction:(id)sender
{
    if (_dealInCell) {
        WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
        storeDetailVC.shop = dic;
        [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
    }

}

- (IBAction)leftProductButAction:(id)sender
{
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    if (goodsList.count == 0) {
        return;
    }
    NSDictionary *FDic = [goodsList objectAtIndex:0];
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [FDic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = shopId;
    [self.viewController.navigationController pushViewController:productDetailVC animated:YES];
}

- (IBAction)leftCollectButAction:(id)sender
{
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    if (goodsList.count == 0) {
        return;
    }
    NSMutableDictionary *goodDic = [goodsList objectAtIndex:0];
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *userType = user.userType;
    if ([userType isEqualToString:@"1"]) {
        NSString *isCollect = [goodDic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [goodDic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [goodDic setValue:@"Y" forKey:@"isCollect"];
                    [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                    [CollectSucView showCollectSucViewInView:self.viewController.view];
                }

            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            } showMessage:YES];
        // 已收藏 取消收藏
        } else {
            NSString *goodsid = [goodDic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:param tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
                float flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [self.viewController.view makeToast:@"已取消收藏！"];
                    [goodDic setValue:@"N" forKey:@"isCollect"];
                    [_leftCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
                }
            } failCallBack:^(id error) {
                [SVProgressHUD showErrorWithStatus:@"操作失败！" duration:TOAST_VIEW_TIME];
            } showMessage:YES];
            
                }
    } else {
        [WSUserUtil actionAfterLogin:^{
            if (_refreshPage) {
                _refreshPage();
            }
        }];
    }

}

- (IBAction)leftShareButAction:(id)sender
{
    
    
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    if (goodsList.count == 0) {
        return;
    }
    NSDictionary *goodDic = [goodsList objectAtIndex:0];
    NSString *goodsName = [goodDic objectForKey:@"goodsName"];
    NSString *shopName = [dic objectForKey:@"shopName"];
    NSString *goodsLogo = [WSInterfaceUtility getImageURLWithStr:[goodDic objectForKey:@"goodsLogo"]];
    NSString *url = [goodDic objectForKey:@"h5Url"];
    
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    
    [shareDic setValue:goodsName forKey:GOODS_NAME];
    [shareDic setValue:shopName forKey:SHOP_NAME];
    [shareDic setValue:goodsLogo forKey:GOODS_LOGO];
    [shareDic setValue:url forKey:GOODS_URL];
    [WSProjShareUtil shareGoodsDetails:shareDic];
}

- (IBAction)rightProductButAction:(id)sender
{
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    NSDictionary *SDic = [goodsList objectAtIndex:1];
    if (goodsList.count < 2) {
        return;
    }
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSProductDetailViewController *productDetailVC = [[WSProductDetailViewController alloc] init];
    NSString *goodsId = [SDic stringForKey:@"goodsId"];
    productDetailVC.goodsId = goodsId;
    productDetailVC.shopId = shopId;
    [self.viewController.navigationController pushViewController:productDetailVC animated:YES];
}

- (IBAction)rightCollectButAction:(id)sender
{
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    if (goodsList.count < 2) {
        return;
    }
    NSMutableDictionary *goodDic = [goodsList objectAtIndex:1];
    NSString *shopId = [dic stringForKey:@"shopId"];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    NSString *userType = user.userType;
    if ([userType isEqualToString:@"1"]) {
        NSString *isCollect = [goodDic stringForKey:@"isCollect"];
        // 没有收藏  白色安心
        if ([isCollect isEqualToString:@"N"]) {
            NSString *goodsid = [goodDic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [SVProgressHUD show];
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCollectGoods] data:param tag:WSInterfaceTypeCollectGoods sucCallBack:^(id result) {
                BOOL flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                    [goodDic setValue:@"Y" forKey:@"isCollect"];
                    [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
                    [CollectSucView showCollectSucViewInView:self.viewController.view];
                }
                
            } failCallBack:^(id error) {
                [SVProgressHUD dismissWithError:@"收藏失败！" afterDelay:TOAST_VIEW_TIME];
            } showMessage:YES];
            // 已收藏 取消收藏
        } else {
            NSString *goodsid = [goodDic stringForKey:@"goodsId"];
            NSDictionary *param = @{@"uid": user._id, @"goodsid":  goodsid, @"shopid": shopId};
            [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeDeleteCollect] data:param tag:WSInterfaceTypeDeleteCollect sucCallBack:^(id result) {
                float flag = [WSInterfaceUtility validRequestResult:result];
                if (flag) {
                     [self.viewController.view makeToast:@"已取消收藏！"];
                    [goodDic setValue:@"N" forKey:@"isCollect"];
                    [_rightCollectBut setBackgroundImage:[UIImage imageNamed:@"uncollect"] forState:UIControlStateNormal];
                }
            } failCallBack:^(id error) {
                [SVProgressHUD showErrorWithStatus:@"操作失败！" duration:TOAST_VIEW_TIME];
            } showMessage:YES];

        }
    } else {
        [WSUserUtil actionAfterLogin:^{
            if (_refreshPage) {
                _refreshPage();
            }
        }];
    }
}

- (IBAction)rightShareButAction:(id)sender
{
    NSArray *goodsList = [dic objectForKey:@"goodsList"];
    if (goodsList.count >= 2) {
        return;
    }
    NSDictionary *goodDic = [goodsList objectAtIndex:1];
    NSString *goodsName = [goodDic objectForKey:@"goodsName"];
    NSString *shopName = [dic objectForKey:@"shopName"];
    NSString *goodsLogo = [WSInterfaceUtility getImageURLWithStr:[goodDic objectForKey:@"goodsLogo"]];
    NSString *url = [goodDic objectForKey:@"h5Url"];
    
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    
    [shareDic setValue:goodsName forKey:GOODS_NAME];
    [shareDic setValue:shopName forKey:SHOP_NAME];
    [shareDic setValue:goodsLogo forKey:GOODS_LOGO];
    [shareDic setValue:url forKey:GOODS_URL];
    [WSProjShareUtil shareGoodsDetails:shareDic];
}

#pragma mark - 请求商店详情
- (void)requestStoreDetailWithShopId:(NSString *)shopId
{
    //请求商店详情接口获取商店名
    NSDictionary *locationDic = [WSBMKUtil sharedInstance].locationDic;
    float longtide = [[locationDic objectForKey:LOCATION_LONGITUDE] doubleValue];
    float latitude = [[locationDic objectForKey:LOCATION_LATITUDE] doubleValue];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    WSUser *user = [WSRunTime sharedWSRunTime].user;
    if (user) {
        [params setValue:user._id forKey:@"uid"];
    }
    [params setValue:shopId forKey:@"shopid"];
    [params setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lat"];
    [params setValue:[NSString stringWithFormat:@"%f", longtide] forKey:@"lon"];
    [params setValue:[NSString stringWithFormat:@"%d",  1] forKey:@"pages"];
    [params setValue:WSPAGE_SIZE forKey:@"pageSize"];
    [params setValue:[NSString stringWithFormat:@"%d", 1] forKey:@"pages"];
    [WSService post:[WSInterfaceUtility getURLWithType:WSInterfaceTypeCheckMoreGoodsList] data:params tag:WSInterfaceTypeCheckMoreGoodsList sucCallBack:^(id result) {
        [SVProgressHUD dismiss];
        BOOL flag = [WSInterfaceUtility validRequestResult:result];
        if (flag) {
            
            //  2. GPS定位在店内但还未签到时跳到 WSInStoreNoSignViewController
            //  3. 在店内已签到 跳到 WSStoreDetailViewController
            NSDictionary *shop = [[result objectForKey:@"data"] objectForKey:@"shop"];
            NSString *isSign = [shop stringForKey:@"isSign"];
            // 没有签到
            if ([isSign isEqualToString:@"1"]) {
                WSInStoreNoSignViewController *inStoreNoSignVC = [[WSInStoreNoSignViewController alloc] init];
                inStoreNoSignVC.shop = shop;
                [self.viewController.navigationController pushViewController:inStoreNoSignVC animated:YES];
                // 已经签到
            } else {
                WSStoreDetailViewController *storeDetailVC = [[WSStoreDetailViewController alloc] init];
                storeDetailVC.shop = shop;
                [self.viewController.navigationController pushViewController:storeDetailVC animated:YES];
            }
        }
    } failCallBack:^(id error) {
       
    } showMessage:YES];
}


@end
