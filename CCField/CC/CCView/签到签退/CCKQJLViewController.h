//
//  CCKQJLViewController.h
//  CCField
//
//  Created by 马伟恒 on 14/10/20.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "RDVCalendarView.h"

@interface CCKQJLViewController : CCRootViewController<RDVCalendarViewDelegate>
/**
 * Returns the calendar view managed by the controller object.
 */
@property (nonatomic, strong) RDVCalendarView *calendarView;

/**
 * A Boolean value indicating if the controller clears the selection when the calendar appears.
 */
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;
/**
 *  考勤时间数组
 */
@property(nonatomic,strong)NSArray *signTimeArray;
/**
 *  服务器时间
 */
@property(nonatomic,strong,nonnull)NSDate *currDate;
@end
