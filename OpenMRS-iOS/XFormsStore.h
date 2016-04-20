//
//  XFormsLoader.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/4/15.
//

#import <Foundation/Foundation.h>
#import "MRSPatient.h"

@class XForms;
@interface XFormsStore : NSObject

@property (nonatomic, strong) MRSPatient *patient;

+ (instancetype)sharedStore;
- (void)loadForms:(void (^)(NSArray *forms, NSError *error))completion;
- (void)loadForm:(NSString *)formID andFormName:(NSString *)formName completion:(void (^)(XForms *xform, NSError *error))completion;
- (void)saveFilledForm:(XForms *)form;
- (NSArray *)loadFilledFiles;
- (void)deleteBlankForm:(XForms *)form;
- (void)deleteFilledForm:(XForms *)form;
- (void)clearFilledForms;
- (void)clearBlankForms;

@end
