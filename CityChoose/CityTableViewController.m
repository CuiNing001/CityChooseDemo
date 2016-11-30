//
//  CityTableViewController.m
//  CityChoose
//
//  Created by henghui on 2016/11/14.
//  Copyright © 2016年 henghui. All rights reserved.
//

#import "CityTableViewController.h"
#import "CityModel.h"
#import "MapViewController.h"
#import "MJRefresh.h"

// 当前屏幕的宽度
#define size_width [UIScreen mainScreen].bounds.size.width

// 当前屏幕的高度
#define size_height [UIScreen mainScreen].bounds.size.height

@interface CityTableViewController ()<UISearchResultsUpdating,UISearchControllerDelegate>

@property (nonatomic,strong) NSMutableArray *provincesArray; // 省份
@property (nonatomic,strong) NSMutableArray *cityArray; // 城市
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,strong) NSMutableArray *searchResults;




@end

@implementation CityTableViewController

- (NSMutableArray *)provincesArray{
    
    if (!_provincesArray) {
        
        self.provincesArray = [NSMutableArray array];
    }
    return _provincesArray;
}

- (NSMutableArray *)cityArray{
    
    if (!_cityArray) {
        
        self.cityArray = [NSMutableArray array];
    }
    return _cityArray;
}

- (UIView *)headerView{
    
    if (!_headerView) {
        
        self.headerView = [[UIView alloc]init];
    }
    return _headerView;
}

- (NSMutableArray *)searchResults{
    
    if (!_searchResults){
        
        self.searchResults = [NSMutableArray array];
    }
    return _searchResults;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubView];
    
    [self readDataFromPlist];
    
    
    
    
}

#pragma mark - 搭建视图
- (void)loadSubView{
    
    // 创建表头
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size_width, 44)];
    
    //    _headerView.backgroundColor = [UIColor orangeColor];
    
    self.tableView.tableHeaderView = _headerView;
    
    // 添加搜索框
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, size_width-15, 44)];
    
    // 提示符
    searchBar.placeholder = @"请输入想要搜索的城市";
    
    [_headerView addSubview:searchBar];
    
    // UISearchController初始化
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.delegate = self;
    
    self.searchController.searchBar.frame = CGRectMake(0, 100, size_width, 44);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // 设置为NO,可以点击搜索出来的内容
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        NSLog(@"刷新完成");
        
        self.title = @"City";
        
        [self.tableView.mj_header endRefreshing];
    }];
    
}



#pragma mark - 获取城市列表
- (void)readDataFromPlist{
    
    // 从plist文件中获取数据
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Provinces.plist" ofType:nil];
    
    NSMutableArray *array = [NSMutableArray array];
    
    // 创建数组接收数据
    array = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    for (NSDictionary *dic in array) {
        
        // 创建model接收省区数据
        CityModel *model = [[CityModel alloc]init];
        
        [model setValuesForKeysWithDictionary:dic];
        
        [self.provincesArray addObject:model];
        
        NSArray *city = [dic objectForKey:@"cities"];
        
        for (NSDictionary *cityDic in city) {
            
            // 创建model接收城市数据
            CityModel *cityModel = [[CityModel alloc]init];
            
            [cityModel setValuesForKeysWithDictionary:cityDic];
            
            [self.cityArray addObject:cityModel];
        }
    }
}

// 分区title赋值
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    
    // 定义cityModel接收省区名称
    CityModel *model = _provincesArray[section];
    
    NSString *cityProvince = @"";
    
    NSString *provincesStr = model.ProvinceName;
    
    return (!self.searchController.active) ? provincesStr : cityProvince;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (!self.searchController.active) ? _provincesArray.count : 1;
}

// 每个分区cell的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // 定义数组存储城市model
    NSMutableArray *countArr = [NSMutableArray array];
    
    for (CityModel *model in _cityArray) {
        
        // 分区下标和城市model的PID相同的数据存到数组
        if (section == model.PID.integerValue-1) {
            
            [countArr addObject:model];
        }
    }
    
    return (!self.searchController.active) ? countArr.count : self.searchResults.count;
    
}

// cell赋值
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // 定义一个数组接收城市数据
    NSMutableArray *array = [NSMutableArray array];
    
    for (CityModel *model in _cityArray) {
        
        // 分区下标和PID相同的数据存到数组中
        if (indexPath.section == model.PID.integerValue-1 ) {
            
            [array addObject:model.CityName];
            
        }
    }
    // 数组赋值
    cell.textLabel.text = (!self.searchController.active) ? array[indexPath.row] : self.searchResults[indexPath.row];
    return cell;
}

#pragma mark - 索引栏
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    NSArray *listArray = @[@"京",@"津",@"冀",@"晋",@"蒙",@"辽",@"吉",@"黑",@"沪",@"苏",@"浙",@"皖",@"闽",@"赣",@"鲁",@"豫",@"鄂",@"湘",@"粤",@"桂",@"琼",@"渝",@"川",@"黔",@"滇",@"藏",@"陕",@"甘",@"青",@"宁",@"新",@"港",@"澳",@"台"];
    
    return listArray;
    /*
     NSMutableArray *array = [NSMutableArray array];
     
     for (CityModel *model in _provincesArray) {
     
     NSString *string = model.ProvinceName;
     
     [array addObject:string];
     
     }
     
     return array;
     */
    
    
}

#pragma mark - updateSearchReasultsDelegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    [self.searchResults removeAllObjects];
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@",searchController.searchBar.text];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (CityModel *model in _cityArray) {
        
        NSString *cityStr = model.CityName;
        
        [array addObject:cityStr];
    }
    
    self.searchResults = [[array filteredArrayUsingPredicate:searchPredicate]mutableCopy];
    //刷新表格
    [self.tableView reloadData];
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.searchController.active) {
        
        NSLog(@"%@",self.searchResults[indexPath.row]);
        
        MapViewController *mapVC = [[MapViewController alloc]init];
        
        // 属性传值
        mapVC.titleStr = self.searchResults[indexPath.row];
        
        [self.navigationController pushViewController:mapVC animated:YES];

        
    }else{
        
        // 定义一个数组接收城市数据
        NSMutableArray *array = [NSMutableArray array];
        
        for (CityModel *model in _cityArray) {
            
            // 分区下标和PID相同的数据存到数组中
            if (indexPath.section == model.PID.integerValue-1 ) {
                
                [array addObject:model.CityName];
                
            }
        }
        
        NSLog(@"%@",array[indexPath.row]);
        
        MapViewController *mapVC = [[MapViewController alloc]init];
        
        // 属性传值
        mapVC.titleStr = array[indexPath.row];
        
        [self.navigationController pushViewController:mapVC animated:YES];
        
        
    }
    
}





// Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
- (void)presentSearchController:(UISearchController *)searchController{
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if([segue.identifier isEqualToString:@"toMapVC"]){
         
         
         
     }
     
     
 }

*/
@end
