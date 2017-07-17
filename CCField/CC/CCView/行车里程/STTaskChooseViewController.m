//
//  STTaskChooseViewController.m
//  CCField
//
//  Created by 马伟恒 on 16/8/2.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STTaskChooseViewController.h"
#import <BaiduMapKit/BaiduMapAPI_Search/BMKSuggestionSearch.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>
#import "CCUtil.h"
@interface STTaskChooseViewController()<UITableViewDataSource,BMKPoiSearchDelegate,UITableViewDelegate,UISearchBarDelegate,BMKSuggestionSearchDelegate>
{
    UITableView *table;
    BMKSuggestionSearch *search;
    NSArray *cityArray;
    BMKPoiSearch *_poiSearch;
    NSMutableArray *arrResult;
}
@end
@implementation STTaskChooseViewController
NSArray *dic;
-(void)viewDidLoad{
    [super viewDidLoad];
    arrResult = [NSMutableArray array];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+30, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
      [self.view addSubview:table];
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    UISearchBar *sarch = [[UISearchBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 30)];
    sarch.delegate = self;
    sarch.placeholder = @"请输入关键词";
    [self.view addSubview:sarch];
    //poisearch
    _poiSearch = [[BMKPoiSearch alloc]init];
    _poiSearch.delegate =self;
    
    
}
-(void)startSugestSearch:(NSString *)str{
    BMKSuggestionSearchOption *_searchersuggestion = [[BMKSuggestionSearchOption alloc]init];
    _searchersuggestion.keyword = str;
    _searchersuggestion.cityname = @"";
    
    search = [[BMKSuggestionSearch alloc]init];
    search.delegate = self;
    BOOL flag = [search suggestionSearch:_searchersuggestion];
    if(flag)
    {
        NSLog(@"建议检索发送成功");
    }
    else
    {
        NSLog(@"建议检索发送失败");
    }


}
-(void)beginSearch:(NSString *)string{
    BMKNearbySearchOption *optom = [[BMKNearbySearchOption alloc]init];
    optom.location=self.coor;
    optom.keyword = string;
    BOOL flag = [_poiSearch poiSearchNearBy:optom];
    if (!flag) {
        NSLog(@"fail");
    }
  }

#pragma mark --poisearch
-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //  正常
        arrResult = poiResult.poiInfoList.mutableCopy;
        [table reloadData];

    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"未查到相关地址"];
    }
    else{
        NSLog(@"fail");
    }

}
-(void)viewWillDisappear:(BOOL)animated{
    
    _poiSearch.delegate = nil;
    search.delegate = nil;
}
#pragma mark -- suggestSearch
-(void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //success
        cityArray = result.keyList;
        
    }
    else{
    }
}


#pragma mark -- search bar
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self beginSearch:searchBar.text];

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}
-(void)setBlock:(choseDone)blockA{
    _block =blockA;
}
#pragma mark -- table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrResult.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuser = @"reuser";
    UITableViewCell *Cell  =[table dequeueReusableCellWithIdentifier:reuser];
    if (!Cell) {
        Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuser];
    }
      if ([arrResult[0] isKindOfClass:[BMKPoiInfo class]]) {
        //  poi
        
        BMKPoiInfo *info = arrResult[indexPath.row];
        Cell.textLabel.text = info.name;
        Cell.detailTextLabel.text = info.address;
    }
//    else if(arrResult[0] isKindOfClass:[])
    
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKPoiInfo *Info = arrResult[indexPath.row];
    NSArray *arr = @[Info.address,@(Info.pt.latitude),@(Info.pt.longitude)];
    if (_block) {
        _block(arr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)returnBack{
    _block(@[@""]);
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    if (!self.view.window&&self.isViewLoaded) {
        for (UIView *subView in self.view.subviews) {
            [subView removeFromSuperview];
        }
        self.view = nil;
        
    }
}
@end
