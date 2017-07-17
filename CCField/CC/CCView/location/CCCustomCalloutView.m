//
//  CCCustomCalloutView.m
//  CCField
//
//  Created by issuser on 16/4/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCCustomCalloutView.h"
#import "CSDataService.h"
#import "ASIHTTPRequest.h"
@interface CCCustomCalloutView ()
@property (nonatomic, strong) UIButton *portraitView;

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CCCustomCalloutView
#pragma mark - draw rect
#define kPortraitMargin     5
#define kPortraitWidth      70
#define kPortraitHeight     60

#define kTitleWidth         120
#define kTitleHeight        20


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnClick)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
   
    
    // 添加标题，即商户名
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width,47)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.text = @"";
     [self addSubview:self.titleLabel];
    
    // 添加副标题，即商户地址
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2,CGRectGetMaxY(self.titleLabel.frame)-5, self.frame.size.width, 20)];
  
    self.subtitleLabel.font = [UIFont systemFontOfSize:11];
    self.subtitleLabel.textColor = [UIColor redColor];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"small"]) {
        self.subtitleLabel.frame = CGRectMake(2, CGRectGetHeight(self.frame)-28, self.frame.size.width, 20);
        self.subtitleLabel.textColor = [UIColor whiteColor];
    }
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.text = @"";
    [self addSubview:self.subtitleLabel];
    
}
-(void)refreshFrame{
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.subtitleLabel.frame =CGRectMake(2,CGRectGetMaxY(self.titleLabel.frame)-5, self.frame.size.width, 20);
    self.subtitleLabel.hidden = YES;
}

- (void)btnClick{
    NSLog(@"1");
    if (_block) {
        _block();
    }
}


- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}
- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
}
- (void)getDrawPath:(CGContextRef)context
{
#define kArrorHeight        5
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}


- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

@end
