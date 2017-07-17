//
//  CCCustomAnnotationView.m
//  CCField
//
//  Created by issuser on 16/4/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCCustomAnnotationView.h"
@interface CCCustomCalloutView ()



@end
@implementation CCCustomAnnotationView
static bool click;
#define kCalloutWidth       200.0
#define kCalloutHeight      70.0
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    // 当前控件上的点转换到chatView上
    CGPoint chatP = [self convertPoint:point toView:self.calloutView];
    
    // 判断下点在不在chatView上
    if ([self.calloutView pointInside:chatP withEvent:event]) {
        return self.calloutView;
    }else{
        return [super hitTest:point withEvent:event];
    }
    
}


-(void)transformUI{
    click = !click;
    NSLog(@"%@",self.annotation.subtitle);
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"small"]) {
        if (!click) {
            // 说明现在是大的
            self.calloutView.frame = CGRectMake(0, 0, kCalloutWidth/2.0, 50);
            [self.calloutView refreshFrame];
           
            self.calloutView.title = self.annotation.title;
            
        }
        else{
//            self.calloutView.frame = CGRectMake(0, 0, kCalloutWidth, kCalloutHeight);
//            [self.calloutView refreshFrame];
           
            self.calloutView.title = self.annotation.subtitle;
        }
        self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                             -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
    }
    else{
        //        [self.calloutView removeFromSuperview];
        //
        //        self.calloutView = nil;
        
        [self.delegate3 click];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            
            self.calloutView = [[CCCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            
        
            if ([defaults boolForKey:@"small"]) {
                //刚开始可以变窄
                 self.calloutView = [[CCCustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth/2.0, 50)];
                
            }
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        click = false;
        self.calloutView.title = self.annotation.title;
        self.calloutView.subtitle = self.annotation.subtitle;
        [self addSubview:self.calloutView];
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"small"]) {
            [self.calloutView refreshFrame];
        }
        __weak typeof (self) weakSelf = self;
        self.calloutView.block=^(){
            [weakSelf transformUI];
        };
    }
    else
    {
        NSLog(@"34543");
        // [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}
@end
