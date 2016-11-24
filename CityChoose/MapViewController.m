//
//  MapViewController.m
//  CityChoose
//
//  Created by henghui on 2016/11/21.
//  Copyright © 2016年 henghui. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *manager;  // 管理器
@property (assign, nonatomic) CGFloat longitude; // 经度
@property (assign, nonatomic) CGFloat latitude; // 纬度
@property (strong, nonatomic) MKMapView *mapView;  // 地图




@end

@implementation MapViewController

- (CLLocationManager *)manager{
    
    if (!_manager) {
        
        self.manager = [[CLLocationManager alloc]init];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadSubView];
    
    
}


- (IBAction)backToView:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    
    // 根据传过来的数据设置导航栏标题
    self.title = self.titleStr;
    
}


- (void)loadSubView{
    
    // 创建地图
    self.mapView = [[MKMapView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    // 设置地图类型
    _mapView.mapType = MKMapTypeStandard;
    
    // 设置代理
    _mapView.delegate = self;
    
    // 初始化管理器对象
    self.manager = [[CLLocationManager alloc]init];
    
    // 判断是否开启定位
    if (![CLLocationManager locationServicesEnabled]) {
        
        NSLog(@"设备未打开定位");
        
        // 使用时授权定位
        [_manager requestWhenInUseAuthorization];
        
    }
    
    // 设置代理
    _manager.delegate = self;
    
    // 设置定位精度
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // 设置定位频率(10米定位一次)
    CLLocationDistance distance = 10;
    
    // 给精度赋值
    _manager.distanceFilter = distance;
    
    // 开启定位
    [_manager startUpdatingLocation];
    
    // 地理编码
    [self geocoder];
    
    [self.view addSubview:_mapView];
    
    
}

#pragma mark - 位置发生改变时调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    // 取出第一个位置
    CLLocation *location = [locations firstObject];
    
    NSLog(@"%@",location.timestamp);
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    NSLog(@"***纬度：%f***經度：%f",coordinate.latitude,coordinate.longitude);
    
    // 关闭定位服务
    [_manager stopUpdatingLocation];
    
}

#pragma mark - 地理编码（根据地址获取相应的经纬度）
- (void)geocoder{
    
    // 创建地理编码对象
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    [geocoder geocodeAddressString:self.titleStr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        // 创建placemark对象
        CLPlacemark *placemark = [placemarks firstObject];
        
        self.latitude = placemark.location.coordinate.latitude;
        
        self.longitude = placemark.location.coordinate.longitude;
        
        NSLog(@"===经度：%f===纬度%f===地址%@",placemark.location.coordinate.longitude,placemark.location.coordinate.latitude,placemark.name);
        
        CLLocationCoordinate2D theCoordinate;
        
        // 设置位置的经纬度
        theCoordinate.latitude = self.latitude;
        
        theCoordinate.longitude = self.longitude;
        
        // 设定显示范围
        MKCoordinateSpan theSpan;
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        // 设置地图显示的中心及范围
        MKCoordinateRegion theRegion;
        
        theRegion.center=theCoordinate;
        
        theRegion.span=theSpan;
        
        [_mapView setRegion:theRegion animated:YES];
        
        
        // 地理反编码
        [self loadGeocoder];
        
    }];
    
}


#pragma mark - 地理反编码（根据经纬度获取详细的信息地址）
- (void)loadGeocoder{
    
    // 创建编码对象
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    // 创建位置
    CLLocation *location = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        // 判断是否有错误或者地址为空时返回
        if (error != nil || placemarks.count == 0) {
            
            NSLog(@"error:%@",error);
            
            return;
            
        }
        
        for (CLPlacemark *placemark in placemarks) {
            
            NSLog(@"++++++详细地址：%@",placemark.name);
            
            // 添加大头针
            MapAnnotation *annotation = [[MapAnnotation alloc]init];
            
            annotation.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
            
            annotation.title = self.titleStr;
            
            annotation.subtitle = placemark.name;
            
            [self.mapView addAnnotation:annotation];

        }
        
       
        
    }];
    
    
}

#pragma mark - 点击屏幕时添加大头针
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // 获取点击屏幕的位置
    CGPoint point = [[touches anyObject]locationInView:self.mapView];
    
    // 蒋具体位置转换为经纬度
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    // 添加大头针
    MapAnnotation *annotation = [[MapAnnotation alloc]init];
    
    // 设置大头针的经纬度
    annotation.coordinate = coordinate;
    
    // 反地理编码
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error != nil || placemarks.count == 0) {
            
            NSLog(@"%@",error);
            
            return;
        }
        
       // 获取地标信息
        CLPlacemark *placemark = [placemarks firstObject];
        
        annotation.title = placemark.locality;
        
        annotation.subtitle = placemark.name;
        
        [self.mapView addAnnotation:annotation];
        
    }];
    
    
}


#pragma mark - 创建大头针时设置大头针样式
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    
    // 设置大头针颜色
    pin.pinTintColor = [UIColor orangeColor];
    
    // 设置掉落动画
    pin.animatesDrop = YES;
    
    // 设置显示详情
    pin.canShowCallout = YES;
    
    return pin;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
