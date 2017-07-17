//
//  NSObject+CC0utString.m
//  CCField
//
//  Created by 马伟恒 on 14/10/21.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "NSObject+CC0utString.h"

@implementation NSObject (CC0utString)
-(instancetype)outString{
    if ([self isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else if([self isKindOfClass:[NSNumber class]])
    {
        
        return [NSString stringWithFormat:@"%d",[(NSNumber *)self integerValue]];
        ;
    }
    else
        return self;
    
}
@end
