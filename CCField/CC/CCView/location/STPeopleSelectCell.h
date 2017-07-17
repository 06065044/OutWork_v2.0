//
//  STPeopleSelectCell.h
//  CCField
//
//  Created by 马伟恒 on 2017/2/8.
//  Copyright © 2017年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STRaceModel.h"
@class RATreeView;
@protocol CellClickProtocol <NSObject>
-(void)cellClick:(STRaceModel *)raceModel;
@end
@interface STPeopleSelectCell : UITableViewCell
@property (weak)id<CellClickProtocol> delegateA;
@property(strong,nonatomic) STRaceModel *modelDic;
@property(assign)NSInteger sectionTag;
-(void)addSub;
+ (instancetype)treeViewCellWith:(RATreeView *)treeView;
-(void)makeValueWithDic:(STRaceModel *)dic andLevel:(NSInteger)level;
-(void)switchInter:(UIButton *)button;
-(void)whetherSelected:(STRaceModel *)model;
@end
