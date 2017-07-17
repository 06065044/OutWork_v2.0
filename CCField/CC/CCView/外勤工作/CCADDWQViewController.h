//
//  CCADDWQViewController.h
//  CCField
//
//  Created by 马伟恒 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

typedef void(^addSuccess)(void);
#import "CCRootViewController.h"
@interface CCADDWQViewController : CCRootViewController<UIActionSheetDelegate>
{
    addSuccess _addSuccessBlock;
}
-(void)setBlock:(addSuccess)add;
@end
