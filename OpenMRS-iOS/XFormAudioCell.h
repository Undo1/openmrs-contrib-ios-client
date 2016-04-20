//
//  XFormAudioCell.h
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 8/9/15.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "XLForm.h"

extern NSString * const XLFormRowDescriptorTypeAudioInLine;

@interface XFormAudioCell : XLFormBaseCell <AVAudioPlayerDelegate, AVAudioPlayerDelegate, UINavigationControllerDelegate>

@end
