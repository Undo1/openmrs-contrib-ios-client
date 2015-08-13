//
//  XFormsLoader.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/4/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormsStore.h"
#import "XForms.h"
#import "OpenMRSAPIManager.h"
#import "Constants.h"
#import "GDataXMLNode.h"

@interface XFormsStore ()

@property (nonatomic, strong) NSString *blank_path;
@property (nonatomic, strong) NSString *filled_path;

@end

@implementation XFormsStore

+ (instancetype)sharedStore {
    static XFormsStore *store = nil;
    static dispatch_once_t once_b;
    dispatch_once(&once_b, ^{
        store = [[self alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        store.blank_path = [userDefaults objectForKey:UDblankForms];
        store.filled_path = [userDefaults objectForKey:UDfilledForms];
    });
    return store;
}

- (void)loadForms:(void (^)(NSArray *forms, NSError *error))completion {
    
    // load from internet
    [OpenMRSAPIManager getXFormsList:^(NSArray *forms, NSError *error) {
        if (!error) {
            completion(forms, nil);
        } else {
            // If failed load from file system
            error = nil;
            NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.blank_path error:&error];
            if (error) {
                completion(nil, error);
                return;
            }
            NSMutableArray *blankForms = [[NSMutableArray alloc] init];
            NSURL *blankFormsURL = [NSURL URLWithString:self.blank_path];

            NSLog(@"Blank forms found %lu at documents directory %@", (unsigned long)directoryContent.count, self.blank_path);
            for (int i=0;i<directoryContent.count;i++) {
                NSString *fileName = directoryContent[i];
                XForms *xforms = [[XForms alloc] initFormFromFile:fileName andURL:blankFormsURL Patient:self.patient];
                [blankForms addObject:xforms];
                NSLog(@"blank form: %@", directoryContent[i]);
            }
            completion(blankForms, nil);
        }
    }];
}

- (void)loadForm:(NSString *)formID andFormName:(NSString *)formName completion:(void (^)(XForms *xform, NSError *error))completion {
    [OpenMRSAPIManager getXformWithID:formID andName:formName Patient:self.patient completion:^(XForms *form, NSError *error) {
        NSString *fileName = [NSString stringWithFormat:@"%@~%@", formName, formID];
        fileName = [fileName stringByAppendingPathExtension:@"xml"];
        NSString *absFileName = [self.blank_path stringByAppendingPathComponent:fileName];
        NSURL *blankFormsURL = [NSURL URLWithString:self.blank_path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (!error) {
            if ([fileManager fileExistsAtPath:absFileName]) {
                [fileManager removeItemAtPath:absFileName error:nil];
            }
            error = nil;
            [fileManager createFileAtPath:absFileName contents:form.doc.XMLData attributes:nil];
            [form.doc.XMLData writeToFile:absFileName options:NSDataWritingAtomic error:&error];
            completion(form, nil);
        } else {
            if ([fileManager fileExistsAtPath:absFileName]) {
                XForms *form = [[XForms alloc] initFormFromFile:fileName andURL:blankFormsURL Patient:self.patient];
                if (form.doc)
                    completion(form, nil);
                else
                    completion(nil, error);
            } else {
                completion(nil, error);
            }
        }
    }];
}

- (void)saveFilledForm:(XForms *)form {
    NSString *fileName = [NSString stringWithFormat:@"%@~%@", form.name, form.XFormsID];
    fileName = [fileName stringByAppendingPathExtension:@"xml"];
    NSString *absFileName = [self.filled_path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:absFileName]) {
        [fileManager removeItemAtPath:absFileName error:nil];
    } else {
        [fileManager createFileAtPath:absFileName contents:form.doc.XMLData attributes:nil];
    }
    [form.doc.XMLData writeToFile:absFileName options:NSDataWritingAtomic error:nil];
}

- (NSArray *)loadFilledFiles {
    NSMutableArray *forms = [[NSMutableArray alloc] init];
    NSURL *filledFormsURL = [NSURL URLWithString:self.filled_path];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error = nil;
    NSArray *filledFormsFiles = [fileManager contentsOfDirectoryAtPath:self.filled_path error:&error];
    if (error) {
        NSLog(@"Loading filled error :%@", error);
        return nil;
    }
    for (NSString *fileName in filledFormsFiles) {
        NSLog(@"Filled form: %@", fileName);
        XForms *form = [[XForms alloc] initFormFromFile:fileName andURL:filledFormsURL Patient:self.patient];
        form.loadedLocaly = YES;
        [forms addObject:form];
    }
    return forms;
}

- (void)deleteFilledForm:(XForms *)form {
    NSString *fileName = [[NSString stringWithFormat:@"%@~%@", form.name, form.XFormsID] stringByAppendingPathExtension:@"xml"];
    NSString *absFileName = [self.filled_path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:self.filled_path error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    if ([fileManager fileExistsAtPath:absFileName]) {
        [fileManager removeItemAtPath:absFileName error:nil];
    }
}

- (void)clearFilledForms {
    
    [self clearAtDir:self.filled_path];
}

- (void)clearBlankForms {
    
    [self clearAtDir:self.blank_path];
}

- (void)clearAtDir:(NSString *)dir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:dir error:NULL];
    for (int count = 0; count < (int)[directoryContent count]; count++) {
        NSString *fileName = directoryContent[count];
        NSString *fileAbsName = [dir stringByAppendingPathComponent:fileName];
        [fileManager removeItemAtPath:fileAbsName error:nil];
    }
}

@end
