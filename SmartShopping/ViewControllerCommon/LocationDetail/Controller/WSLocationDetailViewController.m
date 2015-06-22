//
//  WSLocationDetailViewController.m
//  SmartShopping
//
//  Created by wrs on 15/5/3.
//  Copyright (c) 2015年 wrs. All rights reserved.
//

#import "WSLocationDetailViewController.h"
#import "PaopaoView.h"

#define TITLE_VIEW_HEIGT     20

@interface WSLocationDetailViewController () <BMKLocationServiceDelegate, BMKMapViewDelegate>
{
    BMKLocationService* _locService;
    BMKPointAnnotation* pointAnnotation;
}

@property (weak, nonatomic) IBOutlet WSNavigationBarManagerView *navigationBarManagerView;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

@end

@implementation WSLocationDetailViewController

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _navigationBarManagerView.navigationBarButLabelView.label.text = @"商家地址";
    
//    //设置定位精确度，默认：kCLLocationAccuracyBest
//    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
//    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
//    [BMKLocationService setLocationDistanceFilter:LOCATION_DISTANCE_FILTER];
//    
//    //初始化BMKLocationService
//    _locService = [[BMKLocationService alloc]init];
//    _locService.delegate = self;
//    //启动LocationService
//    [_locService startUserLocationService];

    
//    _mapView.showsUserLocation = YES;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    
    
    [_mapView setZoomLevel:19];
    _mapView.delegate = self;
    pointAnnotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = _latitude;
    coor.longitude = _longitude;
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = _locTitle;
    [_mapView addAnnotation:pointAnnotation];
    
    _mapView.centerCoordinate = coor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [[WSBMKUtil sharedInstance] stopUserLocationService];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
   // _locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _mapView.delegate = nil; // 不用时，置nil
   // _locService.delegate = nil;
    //[[WSBMKUtil sharedInstance] startUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    DLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
   [_mapView updateLocationData:userLocation];
    _mapView.centerCoordinate = userLocation.location.coordinate;
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [_locService stopUserLocationService];
    DLog(@"定位失败！！！");
    [SVProgressHUD showErrorWithStatus:@"定位失败！" duration:TOAST_VIEW_TIME];
}

#pragma mark - BMKMapViewDelegate
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if (annotation == pointAnnotation) {
        NSString *AnnotationViewID = @"renameMark";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
          //  annotationView.image = [UIImage imageNamed:@"location.png"];
            // 设置颜色
            annotationView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
            annotationView.animatesDrop = YES;
            // 设置可拖拽
            annotationView.draggable = YES;
            

            

            UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(100, 0, 100, 60)];
            [popView setBorderCornerWithBorderWidth:1 borderColor:[UIColor colorWithWhite:0.867 alpha:1.000] cornerRadius:5];
            popView.backgroundColor = [UIColor whiteColor];
            CGRect bounds = popView.bounds;
            //
            UILabel *driverName = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, bounds.size.width - 2 * 5, TITLE_VIEW_HEIGT)];
            driverName.text = _locTitle;
            driverName.backgroundColor = [UIColor clearColor];
            driverName.font = [UIFont systemFontOfSize:14];
            driverName.textColor = [UIColor colorWithWhite:0.406 alpha:1.000];
            [popView addSubview:driverName];
//            CGSize size = [driverName boundingRectWithSize:CGSizeMake(0, TITLE_VIEW_HEIGT)];
//            CGRect rect = driverName.frame;
//            rect.size.width = size.width;
//            driverName.frame = rect;
            
            UILabel *carName = [[UILabel alloc]initWithFrame:CGRectMake(5, 15, bounds.size.width - 2 * 5, bounds.size.height - TITLE_VIEW_HEIGT)];
            carName.text = _address;
            carName.numberOfLines = 0;
            carName.backgroundColor = [UIColor clearColor];
            carName.font = [UIFont systemFontOfSize:10];
            carName.textColor = [UIColor colorWithWhite:0.562 alpha:1.000];
            [popView addSubview:carName];
//            CGSize size1 = [carName boundingRectWithSize:CGSizeMake(size.width, 0)];
//            CGRect rect1= driverName.frame;
//            rect1.size.height = size1.height;
//            rect1.origin.y = size.height;
//            driverName.frame = rect1;
            
//            CGRect rect3 = popView.frame;
//            rect3.size.width = size.width;
//            rect3.size.height = rect.size.height + rect1.size.height;
//            popView.frame = rect3;
            
            BMKActionPaopaoView *actionPaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:popView];
           // actionPaopaoView.frame = CGRectMake(0, 0, 100, 60);
            annotationView.paopaoView = nil;
            annotationView.paopaoView = actionPaopaoView;
        }
        return annotationView;
    } else {
        return nil;
    }
    
    //动画annotation
//    NSString *AnnotationViewID = @"AnimatedAnnotation";
  //  MyAnimatedAnnotationView *annotationView = nil;
//    if (annotationView == nil) {
//        annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//    }//
//    NSMutableArray *images = [NSMutableArray array];
//    for (int i = 1; i < 4; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"poi_%d.png", i]];
//        [images addObject:image];
//    }
//    annotationView.annotationImages = images;
//    return annotationView;
    
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
}

@end
