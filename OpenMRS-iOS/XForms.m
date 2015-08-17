//
//  XForm.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XForms.h"
#import "Constants.h"
#import "XFormsParser.h"
#import "MRSPatient.h"

@implementation XForms

- (instancetype)initFormFromFile:(NSString *)fileName andURL:(NSURL *)url Patient:(MRSPatient *)patient {
    self = [super init];
    if (self) {
        NSString *form = [fileName stringByDeletingPathExtension];
        
        /* format: [formname]~[formID].xml */
        NSArray *formInfo = [form componentsSeparatedByString:@"~"];
        self.name = formInfo[0];
        self.XFormsID = formInfo[1];
        
        NSString *path = [url.absoluteString stringByAppendingPathComponent:fileName];
        NSError* error = nil;
        NSData *fileData = [NSData dataWithContentsOfFile:path options: 0 error: &error];
        NSLog(@"Reading errror: %@", error);
        error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:fileData encoding:NSUTF8StringEncoding error:&error];
        self = [XFormsParser parseXFormsXML:doc withID:self.XFormsID andName:self.name Patient:patient];
    }
    return self;
}

- (NSData *)getModelFromDocument {
    GDataXMLElement *model = [self.doc.rootElement elementsForName:@"xf:model"][0];
    GDataXMLElement *instance = [model elementsForName:@"xf:instance"][0];
    
    GDataXMLElement *form = [instance children][0];
    NSDictionary *attributesStrings = @{@"xmlns:xf": @"http://www.w3.org/2002/xforms",
                                        @"xmlns:jr": @"http://openrosa.org/javarosa",
                                        @"xmlns:xs": @"http://www.w3.org/2001/XMLSchema",
                                        @"xmlns:xsi": @"http://www.w3.org/2001/XMLSchema-instance"
                                        };
    if (!self.loadedLocaly) {
        for (NSString *attributesKey in attributesStrings) {
            if (![form attributeForName:attributesKey]) {
                GDataXMLNode *node = [GDataXMLNode attributeWithName:attributesKey stringValue:attributesStrings[attributesKey]];
                [form addAttribute:node];
            }
        }
    }
    NSString *ModelString = form.XMLString;
    if (![form.XMLString hasPrefix:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>%@"]) {
        ModelString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>%@", form.XMLString];
    }
    NSLog(@"sent string: %@", ModelString);
    return [ModelString dataUsingEncoding:NSUTF8StringEncoding];
}

- (XLFormDescriptor *)getReviewForm {
    XLFormDescriptor *reviewForm = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"Summary", @"Title summary")];
    XLFormSectionDescriptor *reviewSection = [XLFormSectionDescriptor formSection];
    [reviewForm addFormSection:reviewSection];

    for (XLFormDescriptor *form in self.forms) {
        for (XLFormSectionDescriptor *section in form.formSections) {
            XLFormRowDescriptor *row = section.formRows[0];
            if (![row.tag isEqualToString:@"add"]) {
                [reviewForm addFormSection:section];
            }
        }
    }
    reviewForm.disabled = YES;
    return reviewForm;
}

@end
