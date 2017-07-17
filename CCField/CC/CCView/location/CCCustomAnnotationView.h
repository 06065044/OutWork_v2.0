//
//  CCCustomAnnotationView.h
//  CCField
//
//  Created by issuser on 16/4/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "CCCustomCalloutView.h"


@protocol CCCustomAnnotationViewDelegate <NSObject>

- (void)click;
@end


@interface CCCustomAnnotationView : MAPinAnnotationView

@property (nonatomic ,strong) CCCustomCalloutView *calloutView;

@property (nonatomic, weak) id<CCCustomAnnotationViewDelegate> delegate3;

-(void)transformUI;
@end
