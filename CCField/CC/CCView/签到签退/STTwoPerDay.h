//
//  STTwoPerDay.h
//  CCField
//
//  Created by 马伟恒 on 16/6/23.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTwoPerDay : UITableViewCell
{
    NSArray *dicCopy;
}
@property(strong,nonatomic)UILabel *timeTitle;
@property(assign)NSInteger indexRow;
@property(assign)NSInteger dayNow;
-(void)resetButtonTitle;
-(void)clearButtonTitle;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)confirmWIthDIc:(NSArray *)dic;
@end
