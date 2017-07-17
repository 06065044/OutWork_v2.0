//
//  CCSettingCell.m
//  CCField
//
//  Created by 李付 on 14-10-15.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCSettingCell.h"

@implementation CCSettingCell

- (void)awakeFromNib {
    // Initialization code
   // [self loadSubviews];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
  self=  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.textLable=[[UILabel alloc]initWithFrame:CGRectMake(0,5,100, 40)];
    self.textLable.backgroundColor=[UIColor clearColor];
    self.textLable.textColor=[UIColor blackColor];
    self.textLable.textAlignment=NSTextAlignmentCenter;
    [self.contentView addSubview:self.textLable];
    
//    self.line=[[UIImageView alloc]initWithFrame:CGRectMake(15,50,290, 1)];
//    self.line.backgroundColor=[UIColor grayColor];
//    [self.contentView addSubview:self.line];
//    
//    self.arrowBack=[[UIImageView alloc]initWithFrame:CGRectMake(280,30, 15,15)];
//    self.arrowBack.image=[UIImage imageNamed:@"arrow"];
//    [self.contentView addSubview:self.arrowBack];
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   // [self loadSubviews];
    // Configure the view for the selected state
 

}





@end
