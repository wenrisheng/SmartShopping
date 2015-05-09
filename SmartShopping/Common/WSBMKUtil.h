//
//  BMKUtil.h
//  SmartShopping
//
//  Created by wrs on 15/5/1.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCATION_UPDATE_NOTIFICATION   @"location_update_notification"   // 位置更新通知
#define GEO_CODE_SUCCESS_NOTIFICATION  @"geo_code_success_notification"  //  反地理编码成功通知

#define LOCATION_FLAG                  @"location_flag"                  // 当前定位标志，0定位成功 1 定位失败
#define LOCATION_LATITUDE              @"location_latitude"             // 纬度
#define LOCATION_LONGITUDE             @"location_longitude"            // 经度
#define DEO_CODE_FLAG                  @"geo_code_flag"                // 反地理编码标志， 0反地理编码成功 1 发地理编码失败
#define LOCATION_PROVINCE              @"location_province"            // 省份
#define LOCATION_CITY                  @"location_city"                // 城市
#define LOCATION_DISTRICT              @"location_district"           // 区县
#define LOCATION_STREET                @"location_street"             // 街道
#define LOCATION_STREET_NUMBER         @"location_street_number"      // 街道号码

typedef void(^LocationCallBack)(NSDictionary *locationDic);
typedef void(^DeoCodeCallBack)(NSDictionary *locationDic);

@interface WSBMKUtil : NSObject <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geocodesearch;
    BMKReverseGeoCodeOption *_reverseGeocodeSearchOption;
}

@property (strong, nonatomic) NSMutableDictionary *locationDic;
@property (strong, nonatomic) LocationCallBack locationCallBack;
@property (strong, nonatomic) DeoCodeCallBack deoCodeCallBack;

+ (WSBMKUtil *)sharedInstance;

/**
 *  开始定位
 */
- (void)startUserLocationService;

/**
 *  停止定位
 */
- (void)stopUserLocationService;

@end
