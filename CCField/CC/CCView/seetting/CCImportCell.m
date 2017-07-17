//
//  CCImportCell.m
//  CCField
//
//  Created by 李付 on 14/11/13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCImportCell.h"

@implementation CCImportCell

@synthesize titleLable,detaLable;


- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
    titleLable=[[UILabel  alloc]init];
    titleLable.textColor=[UIColor grayColor];
    titleLable.frame=CGRectMake(10,5, 100, 30);
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.font=[UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:titleLable];
    
    detaLable=[[UILabel  alloc]init];
    detaLable.textColor=[UIColor grayColor];
    detaLable.frame=CGRectMake(12,25, 200, 30);
    detaLable.backgroundColor=[UIColor clearColor];
    detaLable.font=[UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:detaLable];
    
//    _nameLalb=[[UILabel alloc]init];
//    _nameLalb.textColor=[UIColor redColor];
//    _nameLalb.frame=CGRectMake(250,25, 150, 30);
//    _nameLalb.backgroundColor=[UIColor redColor];
//    _nameLalb.font=[UIFont boldSystemFontOfSize:12];
//    [self.contentView addSubview:_nameLalb];
    _showPic=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-40, 15, 30, 30)];
    [_showPic setImage:[UIImage imageNamed:@"多边形-down"]];
    [self.contentView addSubview:_showPic];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
    
    // Configure the view for the selected state
}

@end
