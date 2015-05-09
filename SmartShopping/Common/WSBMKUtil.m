//
//  BMKUtil.m
//  SmartShopping
//
//  Created by wrs on 15/5/1.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSBMKUtil.h"

@implementation WSBMKUtil

+ (WSBMKUtil *)sharedInstance
{
    static WSBMKUtil *sharedInstance;
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        sharedInstance = [[WSBMKUtil alloc] init];
        }
                  );
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _locationDic = [[NSMutableDictionary alloc] init];
        [_locationDic setValue:[NSNumber numberWithInt:1] forKey:LOCATION_FLAG];
        [_locationDic setValue:[NSNumber numberWithInt:1] forKey:DEO_CODE_FLAG];
        
        // 地理位置反编码
        _geocodesearch = [[BMKGeoCodeSearch alloc]init];
        
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        
        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        [BMKLocationService setLocationDistanceFilter:LOCATION_DISTANCE_FILTER];
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        
        _reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    }
    return  self;
}

#pragma mark - 开始定位
- (void)startUserLocationService
{
    _locService.delegate = self;
    _geocodesearch.delegate = self;
    [_locService startUserLocationService];
}

#pragma mark 停止定位
- (void)stopUserLocationService
{
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    CLLocation *location = userLocation.location;
    if (location) {
        CLLocationCoordinate2D pt = location.coordinate;
        CLLocationDegrees latitude = pt.latitude;
        CLLocationDegrees longitude = pt.longitude;
        DLog(@"当前用户位置更新 纬度latitude %f, 经度longitude %f", latitude, longitude);
        [_locationDic setValue:[NSNumber numberWithInt:0] forKey:LOCATION_FLAG];
        [_locationDic setValue:[NSNumber numberWithDouble:latitude] forKey:LOCATION_LATITUDE];
        [_locationDic setValue:[NSNumber numberWithDouble:longitude] forKey:LOCATION_LONGITUDE];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_NOTIFICATION object:_locationDic userInfo:nil];
        _reverseGeocodeSearchOption.reverseGeoPoint = pt;
        BOOL flag = [_geocodesearch reverseGeoCode:_reverseGeocodeSearchOption];
        if(flag) {
            DLog(@"反geo检索发送成功");
        } else {
            [_locationDic setValue:[NSNumber numberWithInt:1] forKey:DEO_CODE_FLAG];
            DLog(@"反地理编码失败");
        }
    } else {
        [_locationDic setValue:[NSNumber numberWithInt:1] forKey:LOCATION_FLAG];
    }
    if (_locationCallBack) {
        _locationCallBack(_locationDic);
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [_locationDic setValue:[NSNumber numberWithInt:1] forKey:LOCATION_FLAG];
    if (_locationCallBack) {
        _locationCallBack(_locationDic);
    }
    DLog(@"定位失败！！！");
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        [_locationDic setValue:[NSNumber numberWithInt:0] forKey:DEO_CODE_FLAG];
        BMKAddressComponent *addressCom = result.addressDetail;
        [_locationDic setValue:addressCom.province forKey:LOCATION_PROVINCE];
        [_locationDic setValue:addressCom.city forKey:LOCATION_CITY];
        [_locationDic setValue:addressCom.district forKey:LOCATION_DISTRICT];
        [_locationDic setValue:addressCom.streetName forKey:LOCATION_STREET];
        [_locationDic setValue:addressCom.streetNumber forKey:LOCATION_STREET_NUMBER];
        DLog(@"当前用户位置：%@%@%@%@%@", addressCom.province, addressCom.city, addressCom.district, addressCom.streetName, addressCom.streetNumber);
        [[NSNotificationCenter defaultCenter] postNotificationName:GEO_CODE_SUCCESS_NOTIFICATION object:_locationDic userInfo:nil];
    } else {
        [_locationDic setValue:[NSNumber numberWithInt:1] forKey:DEO_CODE_FLAG];
        DLog(@"反地理编码失败");
    }
    if (_locationCallBack) {
        _locationCallBack(_locationDic);
    }
}

@end
