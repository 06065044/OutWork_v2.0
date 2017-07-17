//
//  STPeopleView.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/8.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STPeopleView.h"
#import "STPeopleSelectCell.h"
#import <RATreeView/RATreeView.h>
#import "STShowLocaViewController.h"
#import "CCUtil.h"
#import "STRaceModel.h"
#import "ZYPinYinSearch.h"
#import "ASIHTTPRequest.h"
@interface STPeopleView ()<UITableViewDelegate,UITableViewDataSource,CellClickProtocol,UISearchBarDelegate,RATreeViewDelegate,RATreeViewDataSource>
{
    NSDictionary *_arraySource;
    //下面的成员array
    NSMutableArray *_peopleArray;//按照设计，请求回来的数组是按照名字部门排好的
    //    //首字母排序后
    //    NSMutableDictionary *_sortedDic;
    //排序后的首字母
    NSArray *sortedKeys;
    //当前点击的数组
    NSArray *clickArray;
    UITableView *_table;
    UIButton * _selectedButton;
    NSMutableArray *itemArray;//存储当前所有的item
    RATreeView *_treeView;
    NSMutableArray *modelArray;
    STRaceModel *selectedModel;
    NSMutableDictionary *cellDic;//展开的单位item
    NSMutableArray *miniArray;//最小的单位model集合
    
    NSMutableArray *_dataArray;
    
    NSMutableDictionary *dicMuModel;//存储子的model
}
@end
@implementation STPeopleView
/**讲所有的model的子元素筛选出来**/
-(void)getSub:(STRaceModel *)model inArray:(NSMutableArray *)array{
    for (STRaceModel *subModel in array) {
        if ([subModel.pId isEqualToString:model.ids]) {
            //子model
            if (!dicMuModel[model.ids]) {
                [dicMuModel setObject:[NSMutableArray arrayWithCapacity:10] forKey:model.ids];
            }
            [dicMuModel[model.ids] addObject:subModel];
        }
    }
}
-(void)subForINmodel:(STRaceModel *)model{
    NSArray *Arr = dicMuModel[model.ids];
    if (Arr) {
        for (STRaceModel *modelA in Arr) {
            if (dicMuModel[modelA.ids]) {
                [self subForINmodel:modelA];
            }
            else{
                [dicMuModel[modelA.ids] removeObject:model];
                [dicMuModel[modelA.ids] addObject:model];
            }
            
        }
    }
}
#pragma mark -- 获取数据
- (void)setdata {
    //宝鸡市 (四层)
    //
    
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getSubPeople]];
            [request setTimeOutSeconds:20];
            [request setRequestMethod:@"GET"];
            [request startSynchronous];
            NSData *responseData = request.responseData;
            NSArray *Arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    
    
    
    
//    NSArray *Arr = @[
//                     @{@"id":@"101",@"pId":@"",@"name":@"测试组1",@"isLookCurrPostion":@"null",@"groupName":@"null",@"checked":@(false),@"isParent":@(true),@"isRootNode":@(true)},
//                     @{@"id":@"102",@"pId":@"101",@"name":@"测试组1-1",@"isLookCurrPostion":@"null",@"groupName":@"null",@"checked":@(false),@"isParent":@(true),@"isRootNode":@(false)},
//                     @{@"id":@"103",@"pId":@"101",@"name":@"测试组1-2",@"isLookCurrPostion":@"null",@"groupName":@"null",@"checked":@(false),@"isParent":@(true),@"isRootNode":@(false)},
//                     @{@"id":@"104",@"pId":@"102",@"name":@"测试组1-1-1",@"isLookCurrPostion":@"null",@"groupName":@"null",@"checked":@(false),@"isParent":@(true),@"isRootNode":@(false)},
//                     @{@"id":@"105",@"pId":@"",@"name":@"测试组2",@"isLookCurrPostion":@"null",@"groupName":@"null",@"checked":@(false),@"isParent":@(true),@"isRootNode":@(true)},
//                     @{@"id":@"20150707140",@"pId":@"101",@"name":@"test1001",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},
//                     @{@"id":@"20150707141",@"pId":@"101",@"name":@"test1002",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},
//                     @{@"id":@"20150707142",@"pId":@"102",@"name":@"test1003",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},
//                     @{@"id":@"20150707143",@"pId":@"102",@"name":@"test1004",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707144",@"pId":@"103",@"name":@"test1005",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707145",@"pId":@"103",@"name":@"test1006",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707146",@"pId":@"104",@"name":@"test1007",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707147",@"pId":@"104",@"name":@"test1008",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707148",@"pId":@"105",@"name":@"test1009",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707149",@"pId":@"105",@"name":@"test1010",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20150707150",@"pId":@"101",@"name":@"test1011",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20161019140",@"pId":@"101",@"name":@"RT1",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20161019141",@"pId":@"101",@"name":@"RT2",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20161019142",@"pId":@"101",@"name":@"RT3",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)},@{@"id":@"20161108140",@"pId":@"101",@"name":@"xiao",@"isLookCurrPostion":@"Y",@"groupName":@"null",@"checked":@(false),@"isParent":@(false),@"isRootNode":@(false)}];
    if (Arr.count == 1) {
        //只有自己
        STRaceModel *model = [[STRaceModel alloc]init];
        [model setValuesForKeysWithDictionary:Arr[0]];
        [modelArray addObject:model];
        return;
        
    }
    
    NSMutableArray *stModelArr = [NSMutableArray arrayWithCapacity:10];
    STRaceModel *rootModel = nil;
    for (NSDictionary *dic in Arr) {
        STRaceModel *model = [[STRaceModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        NSLog(@"%@",model.ids);
        if (model.isRootNode) {
            rootModel = model;
            [stModelArr addObject:model];
            
        }
        else
            [stModelArr addObject:model];
    }
    
    for (STRaceModel *model in stModelArr) {
        [self getSub:model inArray:stModelArr];
    }
    
    /***************先判断生成最小的一级***************************************/
    for (STRaceModel *model in stModelArr) {
        //说明是最小的节点
        
        [self subForINmodel:model];
    }
    for (STRaceModel *model in stModelArr) {
        //说明是最小的节点
        model.children = dicMuModel[model.ids];
    }
  
    /********************添加根节点**********************************/
    
    
    for (STRaceModel *model in stModelArr) {
        if (model.isRootNode) {
            [modelArray addObject:model];
            NSLog(@"%@",model.children);
        }
    }
    
    
    NSLog(@"%@",modelArray);
    //    STRaceModel *zijingcun = [STRaceModel dataObjectWithName:@"紫荆村" children:nil];
    //    STRaceModel *chengcunzheng = [STRaceModel dataObjectWithName:@"陈村镇" children:@[zijingcun]];
    //    STRaceModel *fengxiang = [STRaceModel dataObjectWithName:@"凤翔县" children:@[chengcunzheng]];
    //    STRaceModel *qishan = [STRaceModel dataObjectWithName:@"岐山县" children:nil];
    //    STRaceModel *baoji = [STRaceModel dataObjectWithName:@"宝鸡市" children:@[fengxiang,qishan]];
    //    //西安市
    //    STRaceModel *yantaqu = [STRaceModel dataObjectWithName:@"雁塔区" children:nil];
    //    STRaceModel *xinchengqu = [STRaceModel dataObjectWithName:@"新城区" children:nil];
    //    STRaceModel *xian = [STRaceModel dataObjectWithName:@"西安" children:@[yantaqu,xinchengqu]];
    //    STRaceModel *shanxi = [STRaceModel dataObjectWithName:@"陕西" children:@[baoji,xian]];
    //    modelArray = [NSMutableArray array];
    //    [modelArray addObject:shanxi];
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


//
-(instancetype)initWithFrame:(CGRect)frame andDataSource:(NSDictionary *)data withVC:(UIViewController *)superV{
    if (self = [ super initWithFrame:frame]) {
        /******************初始化************************************/
        _arraySource = [data copy];
        _superVC = superV;
        cellDic = [NSMutableDictionary dictionaryWithCapacity:10];
        miniArray = [NSMutableArray array];
        itemArray = [NSMutableArray arrayWithCapacity:10];
        dicMuModel = [NSMutableDictionary dictionaryWithCapacity:10];
        modelArray = [NSMutableArray array];
        _peopleArray = [NSMutableArray arrayWithCapacity:10];

        /******************ui初始化************************************/
        
        [self confirmSubViews];
    }
    return  self;
}
-(BOOL)inArray:(NSArray *)originArray whetherContainStrace:(NSArray *)small_array{
    STRaceModel *model = small_array[0];
    __block BOOL whether_have =NO;
    [originArray enumerateObjectsUsingBlock:^(STRaceModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.ids isEqualToString: model.ids]) {
            whether_have = YES;
            *stop = YES;
        }
        
    }];
    return whether_have;
}
/****************************************按钮点击********************************************/
-(void)cellClick:(STRaceModel *)raceModel{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
    NSArray *storedArray  =[NSKeyedUnarchiver unarchiveObjectWithFile:docDir];
    
    NSMutableArray *Arr = [NSMutableArray arrayWithCapacity:10];//所有的选择项
    [self getAllSubs:raceModel inArray:Arr];
    NSMutableArray *deleted_arr = [storedArray mutableCopy];
    
    //判断
    if ([self inArray:deleted_arr whetherContainStrace:Arr]) {
        //存在
        for (STRaceModel *name in Arr) {
            [deleted_arr enumerateObjectsUsingBlock:^(STRaceModel *  _Nonnull  obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.ids isEqualToString:name.ids]) {
                    [deleted_arr removeObject:obj];
                }
            }];
            if ([self inArray:miniArray whetherContainStrace:@[name]]) {
                [miniArray enumerateObjectsUsingBlock:^(STRaceModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.ids isEqualToString:name.ids]) {
                        [self->miniArray removeObject:obj];
                    }
                    
                }];
                
            }
        }
    }
    else{
        for (STRaceModel *model in Arr) {
            if (![self inArray:deleted_arr whetherContainStrace:@[model]]) {
                [deleted_arr addObject:model];
            }
            
        }
        
    }
    [NSKeyedArchiver archiveRootObject:deleted_arr toFile:docDir];
 
    for (int i=0; i<itemArray.count; i++) {
        STPeopleSelectCell *cell =(STPeopleSelectCell*) [_treeView cellForItem:itemArray[i]];
        if (!cell) {
            continue;
        }
        [cell whetherSelected:itemArray[i]];
    }
    if (_table&&!_table.hidden) {
        
        
        for (int i=0; i<_dataArray.count; i++) {
            STPeopleSelectCell *cellB = (STPeopleSelectCell *)[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cellB whetherSelected:_dataArray[i]];
        }
        
    }
    
    [self confirmBtnTitle];
    
}
/**
 获取一个item的所有子节点，不包括自身
 
 @param model model
 @param arr 存放的数组
 */
-(void )getAllSubs:(STRaceModel*)model inArray:(NSMutableArray *)array{
    if (model.children) {
        for (int i=0; i<model.children.count; i++) {
            if (![self inArray:array whetherContainStrace:@[model]]) {
                [array addObject:model];
            }
            [self getAllSubs:model.children[i] inArray:array];
        }
    }
    else{   
        if (![self inArray:array whetherContainStrace:@[model]]) {
            [array addObject:model];
        }
        if (![self inArray:miniArray whetherContainStrace:@[model]]) {
             [miniArray addObject:model];
        }
    }
}


-(void)getAllSubswithoutSelf:(STRaceModel *)model In:(NSMutableArray *)array {
    if (model.children) {
        for (int i=0; i<model.children.count; i++) {
            if (![self inArray:array whetherContainStrace:@[model]]) {
                [array addObject:model];
            }
            [self getAllSubswithoutSelf:model.children[i] In:array];
        }
    }
    else{
        if (![self inArray:array whetherContainStrace:@[model]]) {
            [array addObject:model];
        }
    }
}
/********************************处理数据，初始化view****************************************/

-(void)confirmSubViews{
    
    _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_selectedButton setFrame:CGRectMake(kFullScreenSizeWidth-60, 25, 50, 30)];
    [_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectedButton addTarget:self action:@selector(checkLocation:) forControlEvents:UIControlEventTouchUpInside];
    [_selectedButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.superVC.view addSubview:_selectedButton];
    
    [self.superVC.view bringSubviewToFront:_selectedButton];
    NSLog(@"%@",self.superVC.view.subviews);
    sortedKeys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];;
    sortedKeys = [_arraySource allKeys];
    [self explodeData];//处理数据,按照数组和个数分开
    //创建view
    [self createView];
}
-(void)checkLocation:(UIButton *)button{
    //按照确认的人数获取经纬度坐标
    if ([[button titleForState:UIControlStateNormal]isEqualToString:@"确定"]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请选择要查看的人"];
        return;
    }
    STShowLocaViewController *showLo = [[STShowLocaViewController alloc]init];
    showLo.peopleSelect = [miniArray copy];
    [self.superVC.navigationController pushViewController:showLo animated:YES];
}
-(void)confirmBtnTitle{
 
    NSInteger count1 = miniArray.count;
 
    NSString *button_title = [NSString stringWithFormat:@"确定(%ld)",(unsigned long)count1];
    if (count1==0) {
        button_title = @"确定";
    }
    [_selectedButton setTitle:button_title forState:UIControlStateNormal];
}

-(void)createView{
    
    UISearchBar *search = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 44)];
    search.barStyle     = UIBarStyleDefault;
    search.translucent  = YES;
    search.placeholder = @"搜索";
    search.delegate = self;
    [self addSubview:search];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self setdata];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_treeView = [[RATreeView alloc]initWithFrame:CGRectMake(0, 44, kFullScreenSizeWidth, kFullScreenSizeHeght-64-44) style:RATreeViewStylePlain];
            self->_treeView.delegate = self;
             self->_treeView.dataSource = self;
            
            [self addSubview:self->_treeView];
        });
    });
    
    
    //创建tableview
    
    
    
}
/********************************数据的模型归类****************************************/

#pragma mark == search
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kFullScreenSizeWidth, kFullScreenSizeHeght-64-44) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.hidden = false;
    [_table registerClass:[STPeopleSelectCell class] forCellReuseIdentifier:@"reuserCell"];
    [self addSubview:_table];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchBar.text isEqualToString:@""]) {
        _dataArray = nil;
        _table.hidden = YES;
    }
    else{
        _table.hidden = false;
#warning 主要功能，调用方法实现搜索
        if (_peopleArray.count==0) {
            for (STRaceModel *model in modelArray) {
                [self getAllSubswithoutSelf:model In:_peopleArray];
                if (![self inArray:_peopleArray whetherContainStrace:@[model]]) {
                    [_peopleArray addObject:model];
                }
            }
        }
        _dataArray = [[ZYPinYinSearch searchWithOriginalArray:_peopleArray andSearchText:searchBar.text andSearchByPropertyName:@"name"]mutableCopy];
    }
    [_table reloadData];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [_dataArray removeAllObjects];
    [_table removeFromSuperview];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    _table = nil;
}
#pragma mark -- table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    ;
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STRaceModel *item = _dataArray[indexPath.row];
    STPeopleSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuserCell" forIndexPath:indexPath];
    [cellDic setObject:cell forKey:item];
    [cell addSub];
    [cell whetherSelected:item];
    cell.delegateA = self;
    //当前item
    STRaceModel *model = item;
    cell.modelDic = item;
    //当前层级
    //赋值
    //    [cell setCellBasicInfoWith:model.name level:level children:model.children.count];
    [cell makeValueWithDic:model andLevel:0];
    return cell;
    
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 30)];
//
//    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth/2.0, 30)];
//    lab.text = sortedKeys[section];
//    lab.font = [UIFont systemFontOfSize:14];
//    [bgView addSubview:lab];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
//    NSMutableDictionary *dic_all = [NSKeyedUnarchiver unarchiveObjectWithFile:docDir];
//
//    clickArray = dic_all[@(section)];
//
//    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [selectBtn setFrame:CGRectMake(kFullScreenSizeWidth-50, 5, 20, 20)];
//    [selectBtn setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    ;
//    selectBtn.tag = section;
//    if (clickArray.count==0) {
//        [selectBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
//
//    }
//    [selectBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [bgView addSubview:selectBtn];
//
//    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, 29, kFullScreenSizeWidth, 1)];
//    downView.backgroundColor = [UIColor lightGrayColor];
//    [bgView addSubview:downView];
//    return bgView;
//}
#pragma mark -- 点击section按钮
-(void)clickBtn:(UIButton *)btn{
    NSInteger section = btn.tag;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
    NSMutableDictionary *dic_all = [[NSKeyedUnarchiver unarchiveObjectWithFile:docDir]mutableCopy];
    if ([dic_all[@(section)] count]>0) {
        [dic_all setObject:@[] forKey:@(section)];
    }
    else
        [dic_all setObject:_arraySource[sortedKeys[section]] forKey:@(section)];
    [NSKeyedArchiver archiveRootObject:dic_all toFile:docDir];
    [_table reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    [self confirmBtnTitle];
}


#pragma mark -- data

/**
 处理数据
 */
-(void)explodeData{
    //    _headArray   = [NSMutableArray arrayWithCapacity:10];
    
    //    [_arraySource enumerateObjectsUsingBlock:^(id  _Non@"null" obj, NSUInteger idx, BOOL * _Non@"null" stop) {
    //        if ([obj isKindOfClass:[NSArray class]]) {
    //            [self->_headArray addObject:obj];
    //        }
    //        else{
    //            [self->_peopleArray addObject:obj];
    //        }
    //    }];
    //     [self sortByFirstLetter];
}

/**
 根据字符串创造对应的logo
 
 @param stirng 字符串
 @return 返回的图片，蓝色背景，中间是第一个字符
 */

//-(NSMutableDictionary *)sortByFirstLetter{
//
//
//    [_peopleArray enumerateObjectsUsingBlock:^(NSDictionary*  _Non@"null" obj, NSUInteger idx, BOOL * _Non@"null" stop) {
//        NSString *str = obj[@"name"];
//        NSString *firstName = [[self getPinYinFromString:[str substringToIndex:1]]substringToIndex:1];
//        if (![self->_sortedDic objectForKey:firstName]) {
//            [self->_sortedDic setObject:[NSMutableArray arrayWithCapacity:10] forKey:firstName];
//        }
//        [[self->_sortedDic objectForKey:firstName]addObject:obj];
//    }
//
//       ];
//    return _sortedDic;//下面的人排序
//}

#pragma mark - All Contact
/**
 *  获取首字母
 *
 *  @return 字符串的首字母
 */
- (NSString *)getPinYinFromString:(NSString *)str
{
    NSMutableString *ms = [[NSMutableString alloc]initWithString:str];
    CFStringTransform((__bridge CFMutableStringRef)ms , 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef) ms, 0, kCFStringTransformStripDiacritics, NO);
    return [ms uppercaseString];
}
#pragma mark -----------delegate
//返回行高
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    return 50;
}
//将要展开
//- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
//    STPeopleSelectCell *cell = (STPeopleSelectCell *)[treeView cellForItem:item];
//    cell.iconView.image = [UIImage imageNamed:@"open"];
//}
//将要收缩
//- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
//    RaTreeViewCell *cell = (RaTreeViewCell *)[treeView cellForItem:item];
//    cell.iconView.image = [UIImage imageNamed:@"close"];
//}
//已经展开
- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item {
    selectedModel = item;
    NSLog(@"已经展开了");
    STPeopleSelectCell *cell =(STPeopleSelectCell*) [_treeView cellForItem:item];
     if (selectedModel.children) {
        UIImageView *ben = [cell.contentView viewWithTag:301];
        [ben setImage:[UIImage imageNamed:@"downs"]];
    }

    
}

- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(id)item{
    return UITableViewCellEditingStyleNone;
}


//已经收缩
- (void)treeView:(RATreeView *)treeView didCollapseRowForItem:(id)item {
    STPeopleSelectCell *cell =(STPeopleSelectCell*) [_treeView cellForItem:item];
    if (selectedModel.children) {
        UIImageView *ben = [cell.contentView viewWithTag:301];
        [ben setImage:[UIImage imageNamed:@"ups"]];
    }
    
     NSMutableArray *item_sub_Array = [NSMutableArray arrayWithCapacity:10];
    [self getAllSubswithoutSelf:item In:item_sub_Array];
    for (int i=0; i<item_sub_Array.count; i++) {
        STRaceModel *raceModel = item_sub_Array[i];
        if ([raceModel.ids isEqualToString:((STRaceModel *)item).ids]) {
            continue;
        }
        for (int j=0; j<itemArray.count; j++) {
            STRaceModel *raModel = itemArray[j];
            if ([raceModel.ids isEqualToString:raModel.ids]) {
                [itemArray removeObject:raModel];
            }
        }
    }
}

//# dataSource方法

//返回cell
- (STPeopleSelectCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    //获取cell
    
    STPeopleSelectCell *cell = [STPeopleSelectCell treeViewCellWith:treeView];
    [itemArray addObject:item];
   
    cell.delegateA = self;
    //当前item
    STRaceModel *model = item;
    cell.modelDic = item;
    [cell addSub];
    [cell whetherSelected:item];
    //当前层级
    [cellDic setObject:cell forKey:item];
    NSInteger level = [treeView levelForCellForItem:item];
    //赋值
    //    [cell setCellBasicInfoWith:model.name level:level children:model.children.count];
    [cell makeValueWithDic:model andLevel:level];
    return cell;
}
/**
 *  必须实现
 *
 *  @param treeView treeView
 *  @param item    节点对应的item
 *
 *  @return  每一节点对应的个数
 */
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    STRaceModel *model = item;
    if (model == nil) {
        return self->modelArray.count;
    }
    return model.children.count;
}
/**
 *必须实现的dataSource方法
 *
 *  @param treeView treeView
 *  @param index    子节点的索引
 *  @param item     子节点索引对应的item
 *
 *  @return 返回 节点对应的item
 */
- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    STRaceModel *model = item;
    if (model==nil) {
        
        return self->modelArray[index];
    }
    return model.children[index];
}
//cell的点击方法
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    //获取当前的层
    NSInteger level = [treeView levelForCellForItem:item];
    //当前点击的model
    STRaceModel *model = item;
    NSLog(@"点击的是第%ld层,name=%@",(long)level,model.name);
}
//单元格是否可以编辑 默认是YES
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
    return NO;
}
//编辑要实现的方法
- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item {
    NSLog(@"编辑了实现的方法");
}


@end
