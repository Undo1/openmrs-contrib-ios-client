//
//  XFormAudioCell.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormAudioCell.h"

@interface CustomButton : UIButton

@property (nonatomic, strong) CAShapeLayer *customLayer;
@property (nonatomic, strong) UIColor *color;

- (void)drawCircleButton:(UIColor *)color;

@end

@implementation CustomButton

- (void)drawCircleButton:(UIColor *)color
{
    self.color = color;
    
    [self setTitleColor:color forState:UIControlStateNormal];
    
    self.customLayer = [CAShapeLayer layer];
    
    [self.customLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.customLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.customLayer setStrokeColor:[color CGColor]];
    
    [self.customLayer setLineWidth:2.0f];
    [self.customLayer setFillColor:[self.color CGColor]];
    
    [self.customLayer setPath:[path CGPath]];
    
    [[self layer] addSublayer:self.customLayer];
}

- (void)drawTriangleButton:(UIColor *)color {
    self.customLayer = [CAShapeLayer layer];
    self.color = color;
    
    [self setTitleColor:color forState:UIControlStateNormal];
    
    [self.layer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                     [self bounds].size.height)];
    [self.layer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, CGRectGetHeight(self.frame));
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)/2);
    CGPathCloseSubpath(path);
    self.customLayer.path = path;
    
    [self.customLayer setStrokeColor:[color CGColor]];
    
    [self.customLayer setLineWidth:2.0f];
    [self.customLayer setFillColor:[self.color CGColor]];
    
    [[self layer] addSublayer:self.customLayer];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted)
    {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.customLayer setFillColor:self.color.CGColor];
    }
    else
    {
        [self.customLayer setFillColor:[UIColor clearColor].CGColor];
        self.titleLabel.textColor = self.color;
    }
}

@end


NSString * const XLFormRowDescriptorTypeAudioInLine = @"AudioInLine";

@interface XFormAudioCell ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) CustomButton *record;
@property (nonatomic, strong) CustomButton *play;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIButton *remove;

@end

@implementation XFormAudioCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XFormAudioCell class] forKey:XLFormRowDescriptorTypeAudioInLine];
}

- (void)update {
    [super update];
    self.title.text = self.rowDescriptor.title;
}

- (void)configure {
    [super configure];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureViews];
    [self configureContraints];
}

- (void)configureViews {
    self.title = [[UILabel alloc] init];
    self.title.text = self.rowDescriptor.title;
    self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [self.title sizeToFit];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.title];
    
    
    self.middleView = [[UIView alloc] init];
    
    self.record = [CustomButton buttonWithType:UIButtonTypeCustom];
    [self.record setBackgroundImage:[UIImage imageNamed:@"reocrd_plain"] forState:UIControlStateNormal];
    [self.record setTitle:NSLocalizedString(@"Record", @"Label record") forState:UIControlStateNormal];
    [self.record setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.record.translatesAutoresizingMaskIntoConstraints = NO;
    [self.middleView addSubview:self.record];

    self.play = [[CustomButton alloc] init];
    [self.play setBackgroundImage:[UIImage imageNamed:@"play_button_active"] forState:UIControlStateNormal];
    [self.play setBackgroundImage:[UIImage imageNamed:@"play_button_disabled"] forState:UIControlStateDisabled];
    self.play.translatesAutoresizingMaskIntoConstraints = NO;
    self.play.enabled = NO;
    [self.middleView addSubview:self.play];
    
    self.middleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.middleView];
    
    self.remove = [[UIButton alloc] init];
    [self.remove setTitle:NSLocalizedString(@"Remove", @"Label remove") forState:UIControlStateNormal];
    [self.remove setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.remove.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.remove];
}

- (void)configureContraints {
    NSDictionary *viewsDict = @{
                                @"title": self.title,
                                @"middleView": self.middleView,
                                @"record": self.record,
                                @"play": self.play,
                                @"remove": self.remove
                                };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[title(35)]-5-[middleView(100)]-10-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[record(100)]-20-[play(100)]-5-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[record]-5-|" options:0 metrics:nil views:viewsDict]];
    [self.middleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[play]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[title]-0-|" options:0 metrics:nil views:viewsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[remove]-0-|" options:0 metrics:nil views:viewsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.middleView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
}

@end
