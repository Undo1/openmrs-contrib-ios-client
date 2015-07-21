//
//  XFormsParser.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XForms.h"

@class GDataXMLDocument;
@interface XFormsParser : NSObject

+ (XForms *)parseXFormsXML:(GDataXMLDocument *)doc withID:(NSString *)formID andName:(NSString *)name;

@end
