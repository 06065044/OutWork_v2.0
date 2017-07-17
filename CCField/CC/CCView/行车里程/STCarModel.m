//
//  STCarModel.m
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STCarModel.h"

@implementation STCarModel
-(void)setValue:(id)value forKey:(NSString *)key{
    if (value&&![value isKindOfClass:[NSNull class]]) {
        [super setValue:value forKey:key];
    }
    else{
        [super setValue:@"" forKey:key];
    }
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"description"]) {
        [super setValue:value forKey:@"description1"];
    }

}
@end
