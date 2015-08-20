//
//  XForm.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>
#import "GDataXMLNode.h"
#import "MRSPatient.h"

@interface XForms : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *XFormsID;
@property (nonatomic, strong) GDataXMLDocument *doc;
@property (nonatomic, strong) NSMutableArray *forms;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSString *notSupportedType;
@property (nonatomic, strong) MRSPatient *patient;
@property (nonatomic) BOOL loadedLocaly;
@property (nonatomic) BOOL isForPatient;
@property (nonatomic) BOOL isSupported;

- (instancetype)initFormFromFile:(NSString *)fileName andURL:(NSURL *)url Patient:(MRSPatient *)patient;
- (NSData *)getModelFromDocument;
- (XLFormDescriptor *)getReviewFormWithTitle:(NSString *)title;

@end
