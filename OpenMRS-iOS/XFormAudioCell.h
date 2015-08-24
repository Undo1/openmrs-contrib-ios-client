//
//  XFormAudioCell.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XLForm.h"

extern NSString * const XLFormRowDescriptorTypeAudioInLine;

@interface XFormAudioCell : XLFormBaseCell <AVAudioPlayerDelegate, AVAudioPlayerDelegate, UINavigationControllerDelegate>

@end
