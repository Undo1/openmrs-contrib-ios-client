//
//  XFormsLoader.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/4/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XForms;
@interface XFormsStore : NSObject

+ (instancetype)sharedStore;
- (void)loadForms:(void (^)(NSArray *forms, NSError *error))completion;
- (void)loadForm:(NSString *)formID andFormName:(NSString *)formName completion:(void (^)(XForms *xform, NSError *error))completion;
- (void)saveFilledForm:(XForms *)form;
- (NSArray *)loadFilledFiles;
- (void)deleteFilledForm:(XForms *)form;
@end
