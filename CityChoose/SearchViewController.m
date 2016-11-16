//
//  SearchViewController.m
//  CityChoose
//
//  Created by henghui on 2016/11/15.
//  Copyright © 2016年 henghui. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong,nonatomic) NSMutableArray *dataSoure;

@property (strong,nonatomic) UISearchController *searchController;

@property (strong,nonatomic) NSMutableArray *searchResults;

@end

@implementation SearchViewController

- (NSMutableArray *)dataSoure{
    
    if (!_dataSoure) {
        
        self.dataSoure = [NSMutableArray array];
    }
    return _dataSoure;
}

- (NSMutableArray *)searchResults{
    
    if (!_searchResults) {
        
        self.searchResults = [NSMutableArray array];
    }
    
    return _searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchBar.hidden = YES;
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    self.dataSoure = @[@"九尾妖狐：阿狸（Ahri）",@"暗影之拳：阿卡丽（Akali）",@"殇之木乃伊：阿木木（Amumu",@"冰晶凤凰：艾尼维亚（Anivia）",@"黑暗之女：安妮（Annie)",@"寒冰射手：艾希（Ashe）",@"蒸汽机器人：布里茨（Blitzcrank)",@"复仇焰魂：布兰德（Brand）",@"皮城女警：凯特琳（Caitlyn）",@"魔蛇之拥：卡西奥佩娅（Cassiopeia）",@"虚空恐惧：科’加斯（ChoGath",@"英勇投弹手：库奇（Corki）",@"诺克萨斯之手：德莱厄斯（Darius）",@"皎月女神：黛安娜：（Diana）",@"祖安狂人：蒙多医生（DrMundo）",@"荣耀行刑官：德莱文（Delevin）",@"蜘蛛女皇：伊莉斯（Elise）",@"末日使者：费德提克（Fiddlesticks）",@"无双剑姬：剑姬（Fiora）",@"德玛西亚之力：盖伦（Garen）",@"法外狂徒：格雷福斯（Graves）",@"战争之影：赫卡里姆 （Hecarim）",@"大发明家：黑默丁格（Heimerdinger",@"刀锋意志：伊瑞利亚（Irelia）",@"风暴之怒：迦娜（Janna）",@"审判天使：凯尔（Kayle）",@"诡术妖姬：乐芙兰（LeBlanc）",@"盲僧：李青（Lee sin）",@"仙灵女巫：璐璐（lulu）",@"熔岩巨兽：墨菲特（Malphite）",@"赏金猎人：厄运小姐（MissFortune）",@"狂野女猎手：奈德丽（Nidalee）",@"雪人骑士：努努（Nunu）",@"发条魔灵：奥莉安娜（Orianna",@"放逐之刃：瑞文（Rivan）"].mutableCopy;
   
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self setSearchControllerView];

}

- (void)setSearchControllerView{
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    
    self.searchController.searchBar.frame = CGRectMake(0, 0, 0, 44);
    
    self.searchController.dimsBackgroundDuringPresentation = false;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self.searchController.searchBar sizeToFit];
    //背景颜色
    self.searchController.searchBar.backgroundColor = [UIColor orangeColor];
    
    self.searchController.searchResultsUpdater = self;


}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    [self.searchResults removeAllObjects];
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@",searchController.searchBar.text];
    
    self.searchResults = [[self.dataSoure filteredArrayUsingPredicate:searchPredicate]mutableCopy];
    //刷新表格
    [self.tableView reloadData];
    
    
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return (!self.searchController.active) ? self.dataSoure.count : self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    
    if (indexPath.row > 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.textLabel.text = (!self.searchController.active) ? self.dataSoure[indexPath.row] : self.searchResults[indexPath.row];
    
    
    return cell;
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
