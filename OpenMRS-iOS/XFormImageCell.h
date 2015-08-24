//
//  XFormImageCell.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLForm.h"

extern NSString * const XLFormRowDescriptorTypeImageInLine;

@interface XFormImageCell : XLFormBaseCell <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *image;

@end
