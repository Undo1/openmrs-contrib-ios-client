//
//  XFormsParser.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XFormsParser.h"
#import "XForms.h"
#import "GDataXMLNode.h"
#import "XFormElement.h"
#import "Constants.h"
#import "ImageTypeMenu.h"
#import "SimpleAudioViewController.h"
#import "MapViewController.h"
#import "CLLocationValueTrasformer.h"
#import <MapKit/MapKit.h>
#import <XLForm.h>

@implementation XFormsParser

+ (XForms *)parseXFormsXML:(GDataXMLDocument *)doc withID:(NSString *)formID andName:(NSString *)name {
    XForms *form = [[XForms alloc] init];
    form.name = name;
    form.XFormsID = formID;
    form.forms = [[NSMutableArray alloc] init];
    form.groups = [[NSMutableArray alloc] init];;
    
    GDataXMLElement *model = [doc.rootElement elementsForName:@"xf:model"][0];
    GDataXMLElement *instance = [model elementsForName:@"xf:instance"][0];

    NSArray *bindings = [model elementsForName:@"xf:bind"];

    for (GDataXMLElement *group in [doc.rootElement elementsForName:@"xf:group"]) {
        [XFormsParser parseGroup:group toForm:form bindings:bindings instance:instance doc:doc];
    }
    return form;
}

+ (void)parseGroup:(GDataXMLElement *)group toForm:(XForms *)form bindings:(NSArray *)bindings instance:(GDataXMLElement *)instance doc:(GDataXMLDocument *)doc {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
    NSString *groupLabel = @"";
    
    
    
    //labels and hints
    if ([group elementsForName:@"xf:label"]) {
        groupLabel = [(GDataXMLElement *)([group elementsForName:@"xf:label"][0]) stringValue];
    }
    if ([group elementsForName:@"xf:hint"]) {
        section.title = [(GDataXMLElement *)([group elementsForName:@"xf:hint"][0]) stringValue];
    }
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptorWithTitle:groupLabel];
    
    [formDescriptor addFormSection:section];
    [form.forms addObject:formDescriptor];
    [form.groups addObject:groupDict];

    for (GDataXMLElement *element in [group children]) {
        //handling input
        if ([element.localName isEqualToString:@"input"] ||
            [element.localName isEqualToString:kXFormsSelect] ||
            [element.localName isEqualToString:kXFormsMutlipleSelect] ||
            [element.localName isEqualToString:kXFormsUpload]) {
            [XFormsParser parseInput:element bindings:bindings instance:instance Section:section Group:groupDict Document:doc];
        }
        //handling repeat
        if ([element.localName isEqualToString:kXFormsRepeat]) {
            [XFormsParser parseRepeat:element bindings:bindings instance:instance Section:section Group:groupDict Form:form Document:doc];
        }
        // handling group
        if ([element.localName isEqualToString:kXFormsGroup]) {
            [XFormsParser parseGroup:element toForm:form bindings:bindings instance:instance doc:doc];
        }
    }
}

+ (void)parseRepeat:(GDataXMLElement *)repeat bindings:(NSArray *)bindings instance:(GDataXMLElement* )instance Section:(XLFormSectionDescriptor *)section Group:(NSMutableDictionary *)group Form:(XForms *)form Document:(GDataXMLDocument *)doc {
    XFormElement *formElement = [[XFormElement alloc] init];
    formElement.type = kXFormsRepeat;
    
    //labels and hints
    if ([repeat elementsForName:@"xf:label"]) {
        formElement.label = [(GDataXMLElement *)([repeat elementsForName:@"xf:label"][0]) stringValue];
        section.title = formElement.label;
    }
    if ([repeat elementsForName:@"xf:hint"]) {
        formElement.hint = [(GDataXMLElement *)([repeat elementsForName:@"xf:hint"][0]) stringValue];
        section.footerTitle = formElement.hint;
    }
    
    //bind ID -- used also as a tag for the row in the view.
    formElement.bindID = [(GDataXMLElement *)[repeat attributeForName:@"bind"] stringValue];
    GDataXMLElement *bindingForInput;
    for (GDataXMLElement *element in bindings) {
        if ([[[element attributeForName:@"id"] stringValue] isEqualToString:formElement.bindID]) {
            bindingForInput = element;
            break;
        }
    }

    //XMLNode
    NSString *nodeXPath = [[bindingForInput attributeForName:@"nodeset"] stringValue];
    GDataXMLElement *instanceNode = [instance nodesForXPath:[NSString stringWithFormat:@"/%@", nodeXPath] error:nil][0];
    formElement.XMLnode = instanceNode;
    
    //Sub elements
    formElement.subElements = [[NSMutableDictionary alloc] init];
    for (GDataXMLElement *element in [repeat children]) {
        NSLog(@"element id: %@", [element localName]);
        if ([element.localName isEqualToString:@"input"] ||
            [element.localName isEqualToString:kXFormsSelect] ||
            [element.localName isEqualToString:kXFormsMutlipleSelect] ||
            [element.localName isEqualToString:kXFormsUpload]) {
            //It adds the new row to the new section
            [XFormsParser parseInput:element bindings:bindings instance:instance Section:section Group:formElement.subElements Document:doc];
        }
    }
    [group setObject:formElement forKey:formElement.bindID];
    NSLog(@"Group: %@", formElement.subElements);
}

+ (void)parseInput:(GDataXMLElement *)input bindings:(NSArray *)bindings instance:(GDataXMLElement* )instance Section:(XLFormSectionDescriptor *)section Group:(NSMutableDictionary *)group Document:(GDataXMLDocument *)doc {
    XFormElement *formElement = [[XFormElement alloc] init];
    //labels and hints
    if ([input elementsForName:@"xf:label"]) {
        formElement.label = [(GDataXMLElement *)([input elementsForName:@"xf:label"][0]) stringValue];
    }
    if ([input elementsForName:@"xf:hint"]) {
        formElement.hint = [(GDataXMLElement *)([input elementsForName:@"xf:hint"][0]) stringValue];
    }
    
    //bind ID -- used also as a tag for the row in the view.
    formElement.bindID = [(GDataXMLElement *)[input attributeForName:@"bind"] stringValue];
    GDataXMLElement *bindingForInput;
    for (GDataXMLElement *element in bindings) {
        if ([[[element attributeForName:@"id"] stringValue] isEqualToString:formElement.bindID]) {
            bindingForInput = element;
            break;
        }
    }
    
    //Type
    if ([[[bindingForInput attributeForName:@"type"] stringValue] isEqualToString:kXFormsString]) {
        if ([bindingForInput attributeForName:@"format"]) {
            formElement.type = kXFormsGPS;
        } else if ([input.localName isEqualToString:@"select1"]) {
            formElement.type = kXFormsSelect;
        } else if ([input.localName isEqualToString:@"select"]) {
            formElement.type = kXFormsMutlipleSelect;
        }else {
            formElement.type = kXFormsString;
        }
        
    } else if ([[[bindingForInput attributeForName:@"type"] stringValue] isEqualToString:kXFormBase64]) {
        if ([[[bindingForInput attributeForName:@"format"] stringValue] isEqualToString:kXFormsAudio]) {
            formElement.type = kXFormsAudio;
        } else if ([[[bindingForInput attributeForName:@"format"] stringValue] isEqualToString:kXFormsImage]) {
            formElement.type = kXFormsImage;
        }
    } else {
        formElement.type = [[bindingForInput attributeForName:@"type"] stringValue];
    }
    /* Sufficent data here to create the row */
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:formElement.bindID
                                                                     rowType:[[Constants MAPPING_TYPES] objectForKey:formElement.type]
                                                                       title:formElement.label];
    /* #TODO:That breaks it some investigation has to be done here */
    //[row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    
    if ([formElement.type isEqualToString:kXFormsImage]) {
        row.action.viewControllerClass = [ImageTypeMenu class];
    }
    if ([formElement.type isEqualToString:kXFormsAudio]) {
        row.action.viewControllerClass = [SimpleAudioViewController class];
    }
    if ([formElement.type isEqualToString:kXFormsGPS]) {
        row.action.viewControllerClass = [MapViewController class];
        row.valueTransformer = [CLLocationValueTrasformer class];
        row.value = [[CLLocation alloc] initWithLatitude:-33 longitude:-56];
    }

    // Items
    if ([formElement.type isEqualToString:kXFormsSelect] || [formElement.type isEqualToString:kXFormsMutlipleSelect]) {
        formElement.items = [[NSMutableArray alloc] init];
        NSMutableArray *labels = [[NSMutableArray alloc] init];
        for (GDataXMLElement *item in [input elementsForName:@"xf:item"]) {
            NSString *label = [(GDataXMLElement *)([item elementsForName:@"xf:label"][0]) stringValue];
            NSString *value =[(GDataXMLElement *)([item elementsForName:@"xf:value"][0]) stringValue];
            [labels addObject:label];
            [formElement.items addObject:[XLFormOptionsObject formOptionsObjectWithValue:value displayText:label]];
        }
        row.selectorOptions = formElement.items;
    }
    
    //Locked
    if ([bindingForInput attributeForName:@"locked"]) {
        if ([[[bindingForInput attributeForName:@"locked"] stringValue] isEqualToString:@"true()"]) {
            formElement.locked = YES;
            row.disabled = @YES;
        } else {
            formElement.locked = NO;
            row.disabled = @NO;
        }
    }
    //Visible
    if ([bindingForInput attributeForName:@"visible"]) {
        if ([[[bindingForInput attributeForName:@"visible"] stringValue] isEqualToString:@"true()"]) {
            formElement.visible = YES;
            row.hidden = @NO;
        } else {
            formElement.visible = NO;
            row.hidden = @YES;
        }
    }
    //Required
    if ([bindingForInput attributeForName:@"required"]) {
        if ([[[bindingForInput attributeForName:@"required"] stringValue] isEqualToString:@"true()"]) {
            formElement.required = YES;
            row.required = @YES;
        } else {
            formElement.required = NO;
            row.required = @NO;
        }
    }
    
    NSString *nodeXPath = [[bindingForInput attributeForName:@"nodeset"] stringValue];
    GDataXMLElement *instanceNode = [instance nodesForXPath:[NSString stringWithFormat:@"/%@", nodeXPath] error:nil][0];
    formElement.XMLnode = instanceNode;
    
    
    //Adding default value.. now only strings
    if ([formElement.type isEqualToString:kXFormsString]) {
        formElement.defaultValue = instanceNode.stringValue;
        row.value = formElement.defaultValue;
    } else if ([formElement.type isEqualToString:kXFormsSelect] || [formElement.type isEqualToString:kXFormsMutlipleSelect]) {
        for (XLFormOptionsObject *opObj in formElement.items) {
            NSString *value = opObj.valueData;
            if ([value isEqualToString:instanceNode.stringValue]) {
                row.value = opObj;
                break;
            }
        }
    }
    [group setObject:formElement forKey:formElement.bindID];
    [section addFormRow:row];
}

@end
