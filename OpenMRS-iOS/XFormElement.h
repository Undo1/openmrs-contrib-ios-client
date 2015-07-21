//
//  XFormElement.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/20/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface XFormElement : NSObject

@property (nonatomic, strong) NSString *bindID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *items;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL required;
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) GDataXMLElement *XMLnode;

@end