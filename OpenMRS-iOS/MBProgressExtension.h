//
//  MBProgressExtension.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/15/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MBProgressExtension : NSObject

+ (void)showBlockWithTitle:(NSString *)title inView:(UIView *)view;
+ (void)showBlockWithDetailTitle:(NSString *)detailTitle inView:(UIView *)view;
+ (void)hideActivityIndicatorInView:(UIView *)view;
+ (void)showSucessWithTitle:(NSString *)title inView:(UIView *)view;

@end
