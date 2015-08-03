
//
//  XFormViewController.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormViewController.h"
#import "XFormElement.h"
#import "Constants.h"
#import "XFormsParser.h"
#import "OpenMRSAPIManager.h"

@interface XFormViewController ()

@property (nonatomic, strong) XForms *XForm;
@property (nonatomic) int index;
@property (nonatomic, strong) XFormElement *repeatElement;

@end

@implementation XFormViewController

- (instancetype)initWithForm:(XForms *)form WithIndex:(int)index {
    self = [super init];
    if (self) {
        self.XForm = form;
        self.index = index;
        [self initView];
    }
    return self;
}

- (void)initView {
    XLFormDescriptor *formDescriptor = self.XForm.forms[self.index];
    self.form = formDescriptor;
    if ([self isRepeat]) {
        [self addButtons];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *leftLabel = self.index > 0 ? NSLocalizedString(@"Pervious", @"Label pervious") : NSLocalizedString(@"Cancel", @"Cancel button label");
    NSString *rightLabel =  self.index < (self.XForm.forms.count - 1) ? NSLocalizedString(@"Next", @"Label next") : NSLocalizedString(@"Submit", @"Label submit");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftLabel style:UIBarButtonItemStylePlain target:self action:@selector(pervious)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightLabel style:UIBarButtonItemStylePlain target:self action:@selector(next)];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // change cell height of a particular cell
    if ([[self.form formRowAtIndex:indexPath].tag isEqualToString:@"info"]){
        return 30.0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)pervious {
    if (self.index > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)next {
    if (self.index < (self.XForm.forms.count - 1)) {
        if ([self isValid]) {
            XFormViewController *nextForm = [[XFormViewController alloc] initWithForm:self.XForm WithIndex:self.index+1];
            [self.navigationController pushViewController:nextForm animated:YES];
        } else {
            [self showValidationWarning];
        }
    } else {
        if ([self isValid]) {
            [XFormsParser InjecValues:self.XForm];
            [OpenMRSAPIManager uploadXForms:self.XForm completion:nil];
        } else {
            [self showValidationWarning];
        }
    }
}

- (BOOL)isValid {
    return [self formValidationErrors].count == 0;
}

- (void)showValidationWarning {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Warning label error")
                                message:NSLocalizedString(@"Plese fill out all the required fields", @"Error message")
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (BOOL)isRepeat {
    //Check if already repeat, so we don't repeat repeat.
    XLFormDescriptor *form = self.XForm.forms[self.index];
    if (form.formSections.count > 1) {
        return NO;
    }
    
    NSDictionary *elements = self.XForm.groups[self.index];
    for (NSString *key in elements) {
        XFormElement *element = elements[key];
        if ([element.type isEqualToString:kXFormsRepeat]) {
            return YES;
        }
    }
    return NO;
}

- (void)addButtons {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:@"add" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Add", @"Label add")];
    row.action.formSelector = @selector(addNewSection:);
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delete" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"Remove", @"Label remove")];
    row.action.formSelector = @selector(removeSection:);
    [section addFormRow:row];
}

- (void)addNewSection:(XLFormRowDescriptor *)sender {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    NSUInteger count = form.formSections.count;
    XLFormSectionDescriptor *section = form.formSections[0];
    XLFormSectionDescriptor *newSection = [XLFormSectionDescriptor formSectionWithTitle:section.title];
    if (section.footerTitle) {
        newSection.footerTitle = section.footerTitle;
    }
    NSDictionary *group = self.XForm.groups[self.index];
    
    
    XFormElement *element;
    NSString *type;
    for (NSString *key in group) {
        element = group[key];
    }
    
    for (XLFormRowDescriptor *row in section.formRows) {
        XFormElement *subElement;
        for (NSString *tag in element.subElements) {
            if ([tag isEqualToString:row.tag]) {
                subElement = element.subElements[tag];
                type = subElement.type;
            }
        }
        if ([row.tag isEqualToString:@"info"]) {
            XLFormRowDescriptor *infoRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"info" rowType:XLFormRowDescriptorTypeInfo title:row.title];
            [infoRow.cellConfig setObject:[UIColor colorWithRed:39/255.0
                                                          green:139/255.0
                                                           blue:146/255.0
                                                          alpha:1] forKey:@"backgroundColor"];
            [infoRow.cellConfig setObject:[UIColor whiteColor] forKey:@"textLabel.textColor"];
            [infoRow.cellConfig setObject:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] forKey:@"textLabel.font"];
            [newSection addFormRow:infoRow];
            continue;
        }
        XLFormRowDescriptor *newRow = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@~NEW" , row.tag, count]
                                                                              rowType:[[Constants MAPPING_TYPES] objectForKey:type]
                                                                                title:row.title];
        if (subElement.defaultValue) {
            newRow.value = subElement.defaultValue;
        }
        if (row.selectorOptions) {
            newRow.selectorOptions = row.selectorOptions;
        }
        if (row.hidden) {
            newRow.hidden = row.hidden;
        }
        if (row.disabled) {
            newRow.disabled = row.disabled;
        }
        if (row.required) {
            newRow.required = row.required;
        }
        [newSection addFormRow:newRow];
    }
    [form addFormSection:newSection atIndex:count-1];
    [self deselectFormRow:sender];
}

- (void)removeSection:(XLFormRowDescriptor *)sender {
    XLFormDescriptor *form = self.XForm.forms[self.index];
    NSUInteger count = form.formSections.count;
    if (count > 2) {
        [form removeFormSectionAtIndex:count-2];
    }
    [self deselectFormRow:sender];
}
@end
