//
//  MapAnnotation.h
//  CityChoose
//
//  Created by henghui on 2016/11/24.
//  Copyright © 2016年 henghui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MapAnnotation : NSObject<MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *subtitle;

@end
