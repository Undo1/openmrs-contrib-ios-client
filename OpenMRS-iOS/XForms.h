//
//  XForm.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface XForms : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *XFormsID;
@property (nonatomic, strong) XLFormDescriptor *form;
@property (nonatomic, strong) NSMutableDictionary *formElements;

@end
