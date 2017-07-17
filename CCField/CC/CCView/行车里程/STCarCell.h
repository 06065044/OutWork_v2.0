//
//  STCarCell.h
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@interface STCarCell : UITableViewCell
@property(assign)NSInteger type;
-(void)addSub;
-(void)setData:(NSDictionary*)carModel;
-(void)confirmDic:(NSDictionary *)dic;
@end
