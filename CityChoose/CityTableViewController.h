//
//  CityTableViewController.h
//  CityChoose
//
//  Created by henghui on 2016/11/14.
//  Copyright © 2016年 henghui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityTableViewController : UITableViewController

@property (copy,nonatomic)void (^cityNameBlock)(NSString *cityName);

@property (nonatomic,strong) NSString *string;

@end
