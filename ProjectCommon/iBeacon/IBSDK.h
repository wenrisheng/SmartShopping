//
//  IBSDK.h
//  IBSDK
//
//  Created by SeaSea_Leung on 15/4/24.
//  Copyright (c) 2015年 SeaSea_Leung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface IBSDK : NSObject

//iBeaocn的标识符
@property (strong, nonatomic) NSUUID *UUID;
//搜索到的iBeacons
@property (strong, nonatomic) NSArray *beaconsArray;



//开始检测
-(void)startLocation;
//停止检测
-(void)stopLocation;


@end
