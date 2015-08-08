//
//  XFormViewController.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLForm.h"
#import "XForms.h"

@interface XFormViewController : XLFormViewController <UIAlertViewDelegate>

- (instancetype)initWithForm:(XForms *)form WithIndex:(int)index;

@end
