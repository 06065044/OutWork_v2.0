//
//  STPeopleSelectCell.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/8.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STPeopleSelectCell.h"
#import <RATreeView.h>
#import "CCUtil.h"
@implementation STPeopleSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    kFullScreenSizeHeght;
}
+ (instancetype)treeViewCellWith:(RATreeView *)treeView
{
    STPeopleSelectCell *cell = [treeView dequeueReusableCellWithIdentifier:@"RaTreeViewCell"];
    
    if (cell == nil) {
        
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"ModelCell" owner:nil options:nil] firstObject];
        cell = [[STPeopleSelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RaTreeViewCell"];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
   
    
    return cell;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)init{
    if (self = [super init]) {
     
       
    }
    return self;
}
-(void)whetherSelected:(STRaceModel *)modelC{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
    NSArray *dic_mu = [NSKeyedUnarchiver unarchiveObjectWithFile:docDir];
     UIButton *igv=[self.contentView viewWithTag:_sectionTag+300];
 
    
     [igv setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    for (int t=0; t<dic_mu.count; t++) {
        STRaceModel *modelA = dic_mu[t];
        if ([modelA.ids isEqualToString:modelC.ids]) {
            [igv setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
            break;
        }
    }

}
-(void)addSub{
//    UIImageView *igvLeft = [self.contentView viewWithTag:231];
//    if (!igvLeft) {
//        igvLeft = [[UIImageView alloc]initWithFrame:CGRectMake(20, 15, 15, 15)];
//        igvLeft.tag = 231;
//        if (_modelDic.children) {
//            [igvLeft setImage:[UIImage imageNamed:@"ups"]];
//        }
//        [self.contentView addSubview:igvLeft];
//    }
//    
 
    
    //左边的点击按钮
 
    UIButton *igv=[self.contentView viewWithTag:_sectionTag+300];
    if (!igv) {
    igv= [UIButton buttonWithType:UIButtonTypeCustom];
    [igv setFrame:CGRectMake(kFullScreenSizeWidth-50, 15, 20, 20)];
    igv.tag = _sectionTag+300;
        
    [igv addTarget:self action:@selector(switchInter:) forControlEvents:UIControlEventTouchUpInside];
        
        
     [self.contentView addSubview:igv];
    }
    
      //头像
    UIImageView *igv_head = [self.contentView viewWithTag:301];
    if (!igv_head) {
    igv_head = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 30, 30)];
     igv_head.tag = 301;
    igv_head.layer.cornerRadius = 15;
    igv_head.layer.masksToBounds = YES;
    [self.contentView addSubview:igv_head];
    }
    //名字
    UILabel *nameTitle =[self.contentView viewWithTag:302];
    if (!nameTitle) {
     nameTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(igv_head.frame)+13, 20, 200, 30)];
    nameTitle.tag = 302;
    nameTitle.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:nameTitle];
    }
 
 }
#pragma mark ==按钮点击
-(void)switchInter:(UIButton *)button{
    
    STRaceModel *model = self.modelDic;
    
    
    
//    NSInteger section_tag = button.tag-300;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
//     NSMutableDictionary *dic_mu = [[NSKeyedUnarchiver unarchiveObjectWithFile:docDir]mutableCopy];
//
//    if (!dic_mu) {
//        dic_mu = [NSMutableDictionary dictionary];
//    }
//  
//   //改变人数
//     if (!dic_mu[@(section_tag)]) {
//        [dic_mu setObject:[NSMutableArray array] forKey:@(section_tag)];
//    }
//    NSMutableArray *curArr = [dic_mu[@(section_tag)] mutableCopy];
//    
//    if (![curArr containsObject:_modelDic]) {
//        //表示选中
//        
//        [curArr addObject:_modelDic];
//        [button setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
//    }
//    else{
//        [button setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
//        [curArr removeObject:_modelDic];
//    }
//    [dic_mu setObject:curArr forKey:@(section_tag)];
//   
//    [NSKeyedArchiver archiveRootObject:dic_mu toFile:docDir];
    //计算数组
    if (self.delegateA&&[self.delegateA respondsToSelector:@selector(cellClick:)]) {
        [self.delegateA cellClick:self.modelDic];
    }
}
#pragma mark ==cell赋值
-(void)makeValueWithDic:(STRaceModel *)dic andLevel:(NSInteger)level{
       //设置头像
    
    UIImageView *igvLeft = [self.contentView viewWithTag:231];
    igvLeft.frame =CGRectMake(20+level*30, 20, 15, 10);

    
    UIImageView *image_head = [self.contentView viewWithTag:301];
    if (!dic.children) {
        image_head.image = [CCUtil getLogoFrom:dic.name];
        image_head.frame =CGRectMake(20+25*level, 10, 30, 30);
        image_head.layer.cornerRadius = 15;
        image_head.layer.masksToBounds = YES;
    }
    else{
        [image_head setImage:[UIImage imageNamed:@"ups"]];
        image_head.frame = CGRectMake(20+25*level, 15, 15, 15);
        image_head.layer.cornerRadius = 0;
    
    }
  
    //设置名字
    UILabel *nameTitle = [self.contentView viewWithTag:302];
    nameTitle.text = dic.name;
    nameTitle.frame = CGRectMake(CGRectGetMaxX(image_head.frame)+13, 7, 200, 30);

 }
@end
