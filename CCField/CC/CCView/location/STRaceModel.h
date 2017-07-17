//
//  STRaceModel.h
//  CCField
//
//  Created by 马伟恒 on 2017/2/20.
//  Copyright © 2017年 Field. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STRaceModel : NSObject<NSCoding,NSCopying>
@property (nonnull,nonatomic,copy) NSString *name;//标题
@property(assign)BOOL isParent;//是否父节点
@property(assign)BOOL isRootNode;//是否父节点
@property(nonnull,copy) NSString *ids;
@property(nonnull,copy) NSString *pId;
@property (nonatomic,strong,nonnull) NSArray *children;//子节点数组

//初始化一个model
- (_Nullable id)initWithName:(NSString* _Nullable )name children:(NSArray * _Nullable)array;

//遍历构造器
+ (_Nullable id)dataObjectWithName:(NSString * _Nullable)name children:(NSArray * _Nullable)children;
@end

