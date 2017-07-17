//
//  STRaceModel.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/20.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STRaceModel.h"

@implementation STRaceModel
- (id)initWithName:(NSString *)name children:(NSArray *)children
{
    self = [super init];
    if (self) {
        self.children = children;
        self.name = name;
    }
    return self;
}
+ (id)dataObjectWithName:(NSString *)name children:(NSArray *)children
{
    return [[self alloc] initWithName:name children:children];
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.children forKey:@"children"];
    [coder encodeObject:self.ids forKey:@"ids"];
    [coder encodeObject:self.pId forKey:@"pId"];
    [coder encodeObject:@(self.isParent) forKey:@"isParent"];
    [coder encodeObject:@(self.isRootNode) forKey:@"isRootNode"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.name        =      [aDecoder decodeObjectForKey:@"name"];
        self.children     =     [aDecoder decodeObjectForKey:@"children"];
        self.ids         =          [aDecoder decodeObjectForKey:@"ids"];
        self.pId        =          [aDecoder decodeObjectForKey:@"pId"];
        self.isParent    =     (BOOL)[aDecoder decodeObjectForKey:@"isParent"];
        self.isRootNode  =   (BOOL)[aDecoder decodeObjectForKey:@"isRootNode"];
    }
    return self;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([@"id" isEqualToString:key]) {
        [super setValue:value forKey:@"ids"];
    }
    
}
- (id)copyWithZone:(nullable NSZone *)zone{
    STRaceModel *zone1 = [[self class]allocWithZone:zone];
    zone1.pId = _pId;
    zone1.name = _name;
    zone1.isRootNode = _isRootNode;
    zone1.isParent = _isParent;
    zone1.children = _children;
    zone1.ids = _ids;
    return zone1;
}
@end
