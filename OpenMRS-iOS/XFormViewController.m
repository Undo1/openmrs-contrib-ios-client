
//
//  XFormViewController.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormViewController.h"

@implementation XFormViewController

- (instancetype)initWithForm:(XForms *)form {
    self = [super init];
    if (self) {
        XLFormSectionDescriptor *section = form.form.formSections[0];
        
        NSLog(@"here %@", section.formRows);
        self.form = form.form;
    }
    return self;
}

@end
